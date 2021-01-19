% cut out negative going BSR activation in cross-sectional model from GM mask
clear all
cd /Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/scripts

load('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/figures/cluster_report/SD_w1w2_fMRIrest_N74_Mot_noDiab_latentCOG_all_Age_BfMRIcluster.mat');
load('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/scripts/GMcommoncoordsN74.mat');

%get ventricle cluster indicies
vent_ind=cluster_info.data{1,1}.idx(cluster_info.data{1,1}.mask==-1);

%remove ventricle indicies from GM mask
GMcommon_coords_cut=setdiff(GMcommon_coords,vent_ind);

% save ventricle indicies into common coords
[~,vent_GMcommon_ind,~] = intersect(GMcommon_coords,vent_ind);

%save new coords
save('GMcommon_coords_w1w2_masked_posBSR.mat','GMcommon_coords_cut')

%adjust subjects datamats for new coords
mkdir('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/w1w2_masked_posBSR')
cd /Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/w1w2_masked_posBSR

%N74
IDs={'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};

st_coords=GMcommon_coords_cut; % new coords

for sub = 1:length(IDs)
   
    copyfile(['/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/SD_12ONLY_' IDs{sub} '_BfMRIsessiondata.mat'],'/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/SDBOLD/w1w2_masked_posBSR')
    load(['SD_12ONLY_' IDs{sub} '_BfMRIsessiondata.mat'], 'st_datamat')
    
    st_datamat(:,vent_GMcommon_ind)=[]; % remove vent indicies
    
    save(['SD_12ONLY_' IDs{sub} '_BfMRIsessiondata.mat'], 'st_datamat', 'st_coords', '-append');
    
end