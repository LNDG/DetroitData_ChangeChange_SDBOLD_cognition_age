% Extract PCA dim for BSR mask and non-BSR samples
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

% % confine to BSR between 0 and 1
% load ('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N76_Mot_noDiab_COG_latentChange_logAge_win1664_BfMRIresult.mat','result')
% [~,nonBSR_indALT,~] = intersect(st_coords,nonBSR_ind);
% nonBSR_small=result.boot_result.compare_u(nonBSR_indALT,1)<=1.4;
% nonBSR_ind=nonBSR_ind(nonBSR_small);

BSR_size=numel(BSR_ind);

%% compute PC dim for BSR mask for each subject
disp (['Starting BSR mask PCA dim extraction']);

SAVEPATH = ([BASEPATH,'analysis/Dimensionality/PCAdim_BSRmask/']);  % output path

mkdir(SAVEPATH);

% output variable with BSR mask dims for all subejcts
DimPerc_spatial_BSRmask=zeros(length(SubjectList),2);

%% Loop over subjects
for i=1:numel(SubjectList)
    for s=1:2 % cycle over sessions
     
        %% Load subject's nifti  
        fname=([BASEPATH 'preproc/mri2/' SubjectList{i} '/session' num2str(s) '/rest/' SubjectList{i} '_rest_s' num2str(s) '_FEAT_filt_detrend_denoised_remean_MNI3mm.nii.gz']);
        img = S_load_nii_2d(fname);

        img = img(BSR_ind,:);    % constrains the img file to only use BSR coords
                
        %% spatial PCA
        img=img'; % spatial PCA: rows = timepoints, columns=voxels

        [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix (correlation over time) (Only EXPLAINED output needed)
        DimPerc_spatial_BSRmask(i,s) = EXPLAINED(1);
%         %% Extracting components explaining up to 90% of the variance
% 
%         % Initialize total variance and dimensions count
%         TotalVar=0;
%         Dimensions=0;
% 
%         for j=1:numel(EXPLAINED)
%             TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
%             if TotalVar>90                      % set 90% criterion
%                 Dimensions=j;                 % Choose dimension that reaches min 90% of variance
%                 break
%             end
%         end

        clear  img fname NIFTIPATH EXPLAINED
    end 
end

% save BSRmask PCA dims

SAVEFILE=('PCAdim_BSRmask.mat');
save([SAVEPATH, SAVEFILE],'DimPerc_spatial_BSRmask','BSR_ind');
disp (['saved to: ', SAVEPATH, SAVEFILE]);

%% Compute PC dim for nonBSR sample
disp (['Starting BSR nonmask PCA dim extraction']);

nN=100; % number of samples to be drawn from nonBSR mask

% output
DimPerc_spatial_BSRnonmask=zeros(length(SubjectList),2,nN);
nonBSRsam_inds=zeros(nN,BSR_size);

for sam = 1:nN
   
    %draw samples with equal size to the BSR mask  
    nonBSRsam=datasample(nonBSR_ind,BSR_size,'Replace',false);
    nonBSRsam_inds(sam,:)=nonBSRsam;

    clear nonBSRsam
end
clear sam

%nonBSRsam = nonBSRsam_inds(sam,:);
%  nonBSRsam = nonBSR_ind; % temp

% outpaths
SAVEPATH = ([BASEPATH,'analysis/Dimensionality/PCAdim_BSRnonmask/']);  % output path
mkdir(SAVEPATH);

%% Loop over subjects
for i=1:numel(SubjectList)
    for s=1:2 % cycle over sessions
        %% Load subject's nifti  
        fname=([BASEPATH 'preproc/mri2/' SubjectList{i} '/session' num2str(s) '/rest/' SubjectList{i} '_rest_s' num2str(s) '_FEAT_filt_detrend_denoised_remean_MNI3mm.nii.gz']);
        img_org = S_load_nii_2d(fname);
            
        for sam=1:nN
            img = img_org(nonBSRsam_inds(sam,:),:);    % constrains the img file to only use BSR coords only

            %% spatial PCA
            img=img'; % spatial PCA: rows = timepoints, columns=voxels

            [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true);  % spatial PCA using correlation matrix (correlation over time) (Only EXPLAINED output needed)
            DimPerc_spatial_BSRnonmask(i,s,sam) = EXPLAINED(1);
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

            clear  img EXPLAINED
        end
        clear img_org fname
    end 
    
    disp (['finished subject ', num2str(SubjectList{i})]);
end  

% BSR nonmask PCA dims

SAVEFILE=('PCAdim_BSRnonmask.mat');
save([SAVEPATH, SAVEFILE],'DimPerc_spatial_BSRnonmask','nonBSRsam_inds');
disp (['saved to: ', SAVEPATH, SAVEFILE]);

%% get sample close to median
disp (['Select sample']);

% compute median
diff_BSRnonmask=DimPerc_spatial_BSRnonmask(:,2,:)-DimPerc_spatial_BSRnonmask(:,1,:);
med_BSRnonmask=median(diff_BSRnonmask,3);

% compute distance from median for each sample

dist_BSRnonmask=zeros(nN,1); % distance from median for each sample

for sam = 1:nN
   
    dist_BSRnonmask(sam)=sum(abs(diff_BSRnonmask(:,1,sam)-med_BSRnonmask));

end

% get sample with minimum median distance
[~,minDist_ind]=min(dist_BSRnonmask);

% Save selected sample info

SAVEFILE=('PCAdim_BSRnonmask.mat');
save([SAVEPATH, SAVEFILE],'minDist_ind','-append');
disp (['saved to: ', SAVEPATH, SAVEFILE]);

