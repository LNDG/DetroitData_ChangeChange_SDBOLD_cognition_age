% visualise overlap and difference of brain regions between implicated in
% cross-sectional and longitudinal PLS model respectively
clear all
cd /Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/figures

% add toolboxes
addpath(genpath('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/tools/NIfTI_20140122'))
addpath(genpath('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/tools/preprocessing_tools'))

%% overlapping and divergent regions in change-change versus cross-sectional models
img1=S_load_nii_2d('SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIbsr_lv1_thr3_cluster25.nii.gz');
img2=S_load_nii_2d('SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIbsr_lv1_thr3_cluster25.nii.gz');

%get overlap
img_over=zeros(size(img1));
img_over(intersect(find(img1),find(img2)))=1;

%get difference
img_diff1_ind=setdiff(find(img1),find(img2));
img_diff2_ind=setdiff(find(img2),find(img1));

%single image for output with indices 1 = overlap, 2 = change>w1w2, 3 =
%w1w2>change
img_all2=zeros(size(img1));
img_all2(intersect(find(img1),find(img2)))=1;
img_all2(img_diff1_ind)=2;
img_all2(img_diff2_ind)=3;

%write output image
nii=load_nii('SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIbsr_lv1_thr3_cluster25.nii.gz'); % reference image
nii.img=[];

nii.img=img_all2;
save_nii(nii,'SD_latent_change_w1w2_overlap_diff2.nii.gz')
nii.img=[];