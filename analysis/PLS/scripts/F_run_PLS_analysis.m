% run PLS analysis using PLS toolbox. PLS analysis file must be specified
% manually.
%
% ran with matlab/R2014b

clear all

% add PLS toolbox
addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/Pls'));

cd('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/SDBOLD')

batch_plsgui('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIanalysis.txt')
batch_plsgui('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIanalysis.txt')