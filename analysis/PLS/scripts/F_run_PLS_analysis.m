% run PLS analysis using PLS toolbox. PLS analysis file must be specified
% manually.
%
% ran with matlab/R2014b

clear all

% add PLS toolbox
addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/Pls'));

cd('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/SDBOLD')

% path substituted manually for respective analysis
batch_plsgui('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N76_Mot_noDiab_COG_allChange_logAge_win1664_BfMRIanalysis.txt')
