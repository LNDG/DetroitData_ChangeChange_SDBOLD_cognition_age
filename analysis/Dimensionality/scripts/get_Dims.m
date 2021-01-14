% Helper to extract dimensionality info
clear all

SubjectList={'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1413' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1568' '1578' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1664' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1713' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};

DimPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/Dimensionality/PCAdim_wholebrain/';
ScriptPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/Dimensionality/scripts/';

cd(ScriptPath)

% initialise output
% nr of dimensions needed to capture 90% variance
Dim90_temp_all=zeros(length(SubjectList),2);
Dim90_spatial_all=zeros(length(SubjectList),2);

% variance accounted for by 1st Dimension
DimPerc_temp_all=zeros(length(SubjectList),2);
DimPerc_temp_all=zeros(length(SubjectList),2);

for i = 1:length(SubjectList)
    for s = 1:2 % cycle over sessions
        
    % fill in info from temoral PCA
    load([DimPath SubjectList{i} '_session' num2str(s) '_temporalPCAcorr_90variance.mat'])
    
    Dim90_temp_all(i,s)=Dimensions;
    DimPerc_temp_all(i,s)=EXPLAINED(1);
    
    % fill in info from spatial PCA
    load([DimPath SubjectList{i} '_session' num2str(s) '_spatialPCAcorr_90variance.mat'])
    
    Dim90_spatial_all(i,s)=Dimensions;
    DimPerc_spatial_all(i,s)=EXPLAINED(1);
    
    end
end

% save output
save([ScriptPath 'Dim_info.mat'],'Dim90_temp_all','DimPerc_temp_all','Dim90_spatial_all','DimPerc_spatial_all')