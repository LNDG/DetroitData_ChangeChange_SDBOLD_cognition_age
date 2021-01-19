% compute USC and VSC for BSR mask and non-mask sample
clear all

A=load ('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIresult.mat');

% get common coords
load('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/scripts/GMcommoncoordsN79.mat');

% get BSR mask inds
load('/Volumes/fb-lip/Projects/Naftali/data/analysis/Dimensionality/PCAdim_BSRmask/PCAdim_BSRmask.mat','BSR_ind')
[~,BSR_ind2,~] = intersect(GMcommon_coords,BSR_ind); % indices in common coords vector
BSR_ind2=BSR_ind2';

% get BSR nonmask sample ind
load('/Volumes/fb-lip/Projects/Naftali/data/analysis/Dimensionality/PCAdim_BSRnonmask/PCAdim_BSRnonmask.mat','minDist_ind','nonBSRsam_inds');
[~,BSRnonmask_sam_ind2,~] = intersect(GMcommon_coords,nonBSRsam_inds(minDist_ind,:)); % indices in common coords vector
BSRnonmask_sam_ind2=BSRnonmask_sam_ind2';

% get BSR nonmask sample small
load('/Volumes/fb-lip/Projects/Naftali/data/analysis/Dimensionality/PCAdim_BSRnonmask/PCAdim_BSRnonmask_small.mat','nonBSR_sam_ind');
[~,BSRnonmask_sam_small_ind2,~] = intersect(GMcommon_coords,nonBSR_sam_ind); % indices in common coords vector
BSRnonmask_sam_small_ind2=BSRnonmask_sam_small_ind2';

% N74
SubjectList = {'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};

cd /Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD
%% compute usc for BSRmask only

BSRmask_usc=zeros(length(SubjectList),1);

for i = 1:length(SubjectList)
    
    % load subject datamat
    load(['SD_12ONLY_' SubjectList{i} '_BfMRIsessiondata.mat'],'st_datamat');
    
    BSRmask_usc(i) = A.result.u(BSR_ind2,1)'*st_datamat(3,BSR_ind2)';
    
    clear st_datamat
    
end

%% compute usc for BSRnonmask sample only

BSRnonmask_sam_usc=zeros(length(SubjectList),1);

for i = 1:length(SubjectList)
    
    % load subject datamat
    load(['SD_12ONLY_' SubjectList{i} '_BfMRIsessiondata.mat'],'st_datamat');
    
    BSRnonmask_sam_usc(i) = A.result.u(BSRnonmask_sam_ind2,1)'*st_datamat(3,BSRnonmask_sam_ind2)';
    
    clear st_datamat
    
end

%% compute usc for BSRnonmask sample small only

BSRnonmask_sam_small_usc=zeros(length(SubjectList),1);

for i = 1:length(SubjectList)
    
    % load subject datamat
    load(['SD_12ONLY_' SubjectList{i} '_BfMRIsessiondata.mat'],'st_datamat');
    
    BSRnonmask_sam_small_usc(i) = A.result.u(BSRnonmask_sam_small_ind2,1)'*st_datamat(3,BSRnonmask_sam_small_ind2)';
    
    clear st_datamat
    
end

% save output
mkdir('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/PCA_USC_VSC_analysis')

save('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/PCA_USC_VSC_analysis/USC_masked','BSRmask_usc','BSRnonmask_sam_usc','BSRnonmask_sam_small_usc');