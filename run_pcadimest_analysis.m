function results = run_pcadimest_analysis(analysis_num)
% Main function for analyses 1 and 2 in Hope et al., PCA-based latent space
% under-estimation with uncorrelated latent variables', Brain, 2023. This
% script was written with Matlab 2022a, though I don't believe it uses
% especially new libraries or functions (so might well work with older
% versions).

% The paper is a short Letter to Brain, inspired by an earlier paper by
% Sperber and colleagues in the same journal, which considers the
% unexpectedly low-dimensional results typically found when PCA is applied
% to scores from batteries of tests of post-stroke impairment severity.
% Even though these task batteries could in principal capture many 
% dissociable impairments as latent dimensions, these studies typically
% find no more than 5 latent dimensions, and sometimes only 1. These
% findings MIGHT tell us something important about the latent structure of
% pot-stroke impairment, or they might be artefactual, or both.
% 
% Sperber and colleagues suggested that artefactual low-dimensionality
% might occur because of the spatial structure of natural stroke-induced 
% lesion distributions, which could induce even independent impairments to 
% be correlated. 
% 
% My co-authors and I wondered if another factor might also encourage
% artefactual latent space dimensionality under-estimation, via PCA: task
% impurity. This is the code used to illustrate the effect, and a possible
% mitigation: having lots more tasks.

% INPUTS: analysis_num: just a number representing the analysis you want (1
% or 2)

% OUTPUTS: results: a table recording dimensions counted for each
% simulation, along with the key parameters of that simulation. Actually,
% the main outputs are just figures, graphing summaries of the results
% table, which are essentially similar to those in the paper.

% To run Analysis 1: results = run_pcadimest_analysis(1);
% To run analysis 2: results = run_pcadimest_analysis(2);

reps = 1000; % results are less noisy with more reps
sample_size = 300; % As in Sperber et al., Brain 2023, to which our paper refers

if(analysis_num == 1)
    % Analysis 1:
    num_latents = 1:22; % We look at a range of real latent dimensionalities
    num_scores = 22; % Selected only because there are 22 language scores in the Comprehensive Aphasia Test (Swinburn & Howard, 2004)
    weight_sparsity = [0,0.95]; % Run both with and without sparsity in latent-to-behavioural weights: more sparsity = less task impurity
elseif(analysis_num == 2)
    % Analysis 2:
    num_latents = 1:22; % We look at a (smaller) range of real latent dimensionalities
    num_scores = 40:20:100; % Selected only because there are 22 language scores in the Comprehensive Aphasia Test (Swinburn & Howard, 2004)
    weight_sparsity = 0; % No sparisty, this time
end

% The script is structure to run in parallel. This next bit just assembles
% the required analyses into a bunch of jobs.

warning off
num_jobs = length(sample_size)*length(num_latents)*length(num_scores)*length(weight_sparsity);
jobs = cell(num_jobs,1);
ind = 0;
for a=sample_size
    for b=num_latents
        for c=num_scores
            for d=weight_sparsity
                ind = ind+1;
                jobs{ind,1} = single([a,b,c,d,reps]);
            end
        end
    end
end

% Now we actually run the jobs, in parallel. Since the jobs themselves are
% quick, I bundle all of the repetitions for the same parameter
% configurations (num_latents and num_scores) into a single job. Otherwise
% the overhead on job starting outweighs the benefit of parallelism (on my
% setup).
parfor_progress(ind); % this is a separate function, which implements a progress bar
parfor pf=1:ind
    % Get the arguments that define the job
    args = jobs{pf};
    jobs{pf}=[];
    a = args(1); b = args(2); c = args(3); d = args(4); reps = args(5);
    warning off
    res_local = cell(reps,1);
    warning off
    for x=1:reps
        % generate the data based on the specified numbers of latents, and
        % scores, and participants
        tmp = generate_data_for_PCA(a,b,c,d); % set up the data generator
        [Scores,~] = tmp.get_scores(); % get the scores
        [~,~,latent,~,~,~]=pca(normalize(Scores)); % run PCA on the normalized scores
        latent_real = latent > 0.7; % count with the Joliffe criterion
        latent_real2 = latent > 1.0; % count with the Kaiser criterion
        num_found = length(find(latent_real)); 
        num_found2 = length(find(latent_real2));
        tmp = [a,b,c,d,x,num_found,num_found2]; % record the results
        res_local{x}=single(tmp); % store the results in a big cell array
    end 
    parfor_progress(); % basic progress bar
    
    jobs{pf} = cell2mat(res_local); % keep all results over parfor loops
end
results = cell2mat(jobs); % turn the cell array into a 2D matrix

% Graph the results (figures 1 and 2 in the paper). I made some cosmetic
% adjustments to those figures that were not scripted, but these figures
% still have the key information in them, that is presented in the paper.
if(analysis_num == 1)
    % Figure 1A:
    selector = results(:,4) < 0.1;
    tmp = results(selector, :);
    means = []; stds = [];
    for i=1:length(num_latents)
        selector = tmp(:,2) == num_latents(i);
        means(i,1) = mean(tmp(selector,6));
        stds(i,1) = std(tmp(selector,6));
        means(i,2) = mean(tmp(selector,7));
        stds(i,2) = std(tmp(selector,7));
    end
    figure,errorbar(means,stds,'LineWidth',2);
    title('SPARSITY = 0')
    legend([{'JOLIFFE'},{'KAISER'}])
    % Figure 1B:
    selector = results(:,4) > 0.1;
    tmp = results(selector, :);
    means = []; stds = [];
    for i=1:length(num_latents)
        selector = tmp(:,2) == num_latents(i);
        means(i,1) = mean(tmp(selector,6));
        stds(i,1) = std(tmp(selector,6));
        means(i,2) = mean(tmp(selector,7));
        stds(i,2) = std(tmp(selector,7));
    end
    figure,errorbar(means,stds,'LineWidth',2);
    title('SPARSITY = 0.95')
    legend([{'JOLIFFE'},{'KAISER'}])
elseif(analysis_num == 2)
    % Figure 2:
    means = []; stds = [];
    for i=1:length(num_latents)
        for j=1:length(num_scores)
            selector = results(:,2) == num_latents(i) & results(:,3) == num_scores(j);
            means(i,j,1) = mean(results(selector,6));
            stds(i,j,1) = std(results(selector,6));
            means(i,j,2) = mean(results(selector,7));
            stds(i,j,2) = std(results(selector,7));
        end
    end
    figure,errorbar(squeeze(means(:,:,1)),squeeze(stds(:,:,1)),'LineWidth',2);
    title('JOLIFFE')
    legend([{'40'},{'60'},{'80'},{'100'}])
    figure,errorbar(squeeze(means(:,:,2)),squeeze(stds(:,:,2)),'LineWidth',2);
    title('KAISER')
    legend([{'40'},{'60'},{'80'},{'100'}])
end

end