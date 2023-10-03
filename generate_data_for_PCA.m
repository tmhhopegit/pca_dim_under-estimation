classdef generate_data_for_PCA
    % This object creates a data generating architecture with defined
    % numbers of latent variables and behavioural variables. Behavioural
    % variables are construed as weighted linear sums of latent variable
    % values. The latent variable values might represent the intactness or
    % preservation of cognitive subsystems, for example, and the
    % behavioural variables could represent scores on standardised
    % assessments of impairment. But this data generating architecture
    % could represent any data to which PCA canapplied.
    properties
        NumLatents = 0; % the number of latent variables
        NumSubj = 0; % the number of participants
        NumScores = 0; % the number of behavioural score variables
        Weights = []; % the weights between latent and score variables
        Latents = []; % the latent variables
        Scores = []; % the score variables
    end
    methods
        function obj = set_weights(obj)
            % Set the weights from the latent variables to the empirical
            % (or behavioural) variables. Weights are set as random
            % uniform numbers in the range 0-1.

            % The intuition here is that latent variable represent the
            % function of some cognitive system, with higher values
            % representing greater function - and we presume that no
            % behavioural performance is worse when an underlying,
            % cognitive system is performing better. There might be
            % exceptions to this, but the intuition is popular, not least
            % in Lesion Symptom Mapping, where few report associations
            % between 'more damage' and 'better performance'...

            obj.Weights = single(rand(obj.NumLatents, obj.NumScores));
        end
        function obj = sparsify_weights(obj, sparsity)
            % Analysis 1 asks what the role of task impurity is, by
            % analyzing data when the tasks are more pure: i.e., when each
            % behavioural variable is less likely to be influenced by all
            % of the latent variables. We model this by increasing the
            % sparsity of the weight matrix, or in other words, by setting
            % a proportion of the weights to zero.

            n = obj.NumLatents*obj.NumScores; % the number of weights
            wf = (1:n)'; % a vector with a number for each weight
            wf = wf(randperm(n)); % the randomised vector
            n = round(n*sparsity); % sparsity is a proportion; here we work out how many weights that means
            obj.Weights(wf(1:n)) = 0.000001; % here, we set those weights to a small number (setting to zero throws errors if some scores are disconnected)
        end
        function obj = specify_latents(obj)
            % Specify the latent variables for a sample of simulated
            % participants. As with the weights, latent variables are
            % random uniform numbers.

            obj.Latents = rand(obj.NumSubj,obj.NumLatents);
        end
        function obj = calc_scores_from_latents(obj)
            % Calculate the scores from the specified latent variables and
            % weights. This is essentially just multiplication of a vector
            % with a matrix.
            
            obj.Scores = obj.Latents*obj.Weights;           
        end
        function obj = generate_data_for_PCA(NumSubj,NumLatents,NumEmpVar,sparsity)
            obj.NumLatents = NumLatents;
            obj.NumSubj = NumSubj;
            obj.NumScores = NumEmpVar;
            % Set the latent-to-behavioural variable weights
            obj = obj.set_weights();
            % Sparsify the weights (if 'sparsity' > 0)
            if(sparsity > 0)
                obj = sparsify_weights(obj, sparsity);
            end
        end
        function [Scores,Latents] = get_scores(obj)
            % Generate the specified number of latent variables for the
            % specified number of participants, then calculate observed /
            % score variables for each patient by multiplying with the
            % latent-to-behavioural weights. Return both the latent
            % variables and the score variables.
            
            obj = obj.specify_latents();

            obj = obj.calc_scores_from_latents();

            Latents = obj.Latents;
            Scores = obj.Scores;
        end
    end
end

