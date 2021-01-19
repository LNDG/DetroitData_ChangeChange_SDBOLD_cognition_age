% run PLS analysis using PLS toolbox. PLS analysis file must be specified
% manually.
%
% ran with matlab/R2014b

clear all

% add PLS toolbox
addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/Pls'));

cd('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/SDBOLD/w1w2_masked_posBSR')

% file copied manually from parent directory
batch_plsgui('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/w1w2_masked_posBSR/SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIanalysis.txt')