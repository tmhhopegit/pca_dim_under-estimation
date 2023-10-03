# pca_dim_under-estimation

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
