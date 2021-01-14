% Extract PCA dim for non-BSR region with smallest BSR and equal sample
% size to BSR mask

clear all

% settings
% N74
SubjectList = {'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};
BASEPATH = '/Volumes/fb-lip/Projects/Naftali/data/';   % root directory

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'analysis/PLS/tools/preprocessing_tools']));
addpath(genpath([ BASEPATH 'analysis/PLS/tools/NIfTI_20140122']));

% get st_datamat
load ('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIresult.mat','st_coords')

% get BSR mask
mask = load_nii ('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/figures/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIbsr_lv1_thr3_cluster25_mask.nii.gz');
mask = mask.img;
mask = reshape (mask, [], size(mask,4));

% get indicies of BSR voxels and non-BSR voxels
BSR_ind=find(mask);
nonBSR_ind=find(~mask);
nonBSR_ind=intersect(nonBSR_ind,st_coords); % only voxels in GM mask

% determine BSR threshold for smallest BSR containing equal N voxels as
% BSRmask

load ('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIresult.mat','result')
[~,nonBSR_indALT,~] = intersect(st_coords,nonBSR_ind);

% initialise
cBSR=0; % BSR thresh
nonBSR_sam_ind=[]; % sample indices

while numel(nonBSR_sam_ind) < numel(BSR_ind) % while size of nonBSR sample smaller than BSR mask
    cBSR = cBSR+0.00001; % update BSR thresh
    
    nonBSR_small=result.boot_result.compare_u(nonBSR_indALT,1)<=cBSR;
    nonBSR_sam_ind=nonBSR_ind(nonBSR_small);
end


%% Compute PC dim for nonBSR region
disp (['Starting BSR nonmask PCA dim extraction']);

% output
DimPerc_spatial_BSRnonmask=zeros(length(SubjectList),2);

% outpaths
SAVEPATH = ([BASEPATH,'analysis/Dimensionality/PCAdim_BSRnonmask/']);  % output path

%% Loop over subjects
for i=1:numel(SubjectList)
    for s=1:2 % cycle over sessions
    %% Load subject's nifti  
    fname=([BASEPATH 'preproc/mri2/' SubjectList{i} '/session' num2str(s) '/rest/' SubjectList{i} '_rest_s' num2str(s) '_FEAT_filt_detrend_denoised_remean_MNI3mm.nii.gz']);
    img_org = S_load_nii_2d(fname);

        img = img_org(nonBSR_sam_ind,:);    % constrains the img file to only use BSR coords only

        %% spatial PCA
        img=img'; % spatial PCA: rows = timepoints, columns=voxels

        [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix (correlation over time) (Only EXPLAINED output needed)
        DimPerc_spatial_BSRnonmask(i,s) = EXPLAINED(1);
%             %% Extracting components explaining up to 90% of the variance
% 
%             % Initialize total variance and dimensions count
%             TotalVar=0;
%             Dimensions=0;
% 
%             for j=1:numel(EXPLAINED)
%                 TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
%                 if TotalVar>90                      % set 90% criterion
%                     Dimensions=j;                 % Choose dimension that reaches min 90% of variance
%                     break
%                 end
%             end

        clear  img EXPLAINED img_org fname
    end 
    
    disp (['finished subject ', num2str(SubjectList{i})]);
end  

% BSR nonmask PCA dims

SAVEFILE=('PCAdim_BSRnonmask_small.mat');
save([SAVEPATH, SAVEFILE],'DimPerc_spatial_BSRnonmask','nonBSR_sam_ind','cBSR');
disp (['saved to: ', SAVEPATH, SAVEFILE]);