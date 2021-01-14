function copy2cluster
% This function copies participants' MRI data from the server to the
% computational cluster (tardis).

%specify folder IDs
ID = {'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1413' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1568' '1578' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1664' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1713' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};
sessionID = {'session1' 'session2' 'session3'};
    
Source_dir_root = '/home/mpib/skowron/NetworkFolders/LNDG/Projects/Naftali/data/preproc/mri2';
Target_dir_root = '/home/mpib/LNDG/Naftali/data/preproc/mri2';

for i = 1:length(ID)
    for s =1:length(sessionID)
    
    %skip nonexisting sessions
    if ~exist(fullfile(Source_dir_root,ID{i},sessionID{s}),'dir')
        continue
    end
    
    %anat
    if ~isfile(fullfile(Target_dir_root,ID{i},sessionID{s},'anat',[ID{i},'_anat_s' num2str(s) '.nii.gz']))
    
        if ~isdir(fullfile(Target_dir_root,ID{i},sessionID{s},'anat'))
            mkdir(fullfile(Target_dir_root,ID{i},sessionID{s},'anat'))
        end
        
        copyfile(fullfile(Source_dir_root,ID{i},sessionID{s},'anat',[ID{i},'_anat_s' num2str(s) '.nii.gz']),fullfile(Target_dir_root,ID{i},sessionID{s},'anat',[ID{i},'_anat_s' num2str(s) '.nii.gz']));
        
        fprintf('copied %s %s anat\n',ID{i},sessionID{s})
        
    end
    
    %rest
    if ~isfile(fullfile(Target_dir_root,ID{i},sessionID{s},'rest',[ID{i},'_rest_s' num2str(s) '.nii.gz']))
    
        if ~isdir(fullfile(Target_dir_root,ID{i},sessionID{s},'rest'))
            mkdir(fullfile(Target_dir_root,ID{i},sessionID{s},'rest'))
        end
        
        copyfile(fullfile(Source_dir_root,ID{i},sessionID{s},'rest',[ID{i},'_rest_s' num2str(s) '.nii.gz']),fullfile(Target_dir_root,ID{i},sessionID{s},'rest',[ID{i},'_rest_s' num2str(s) '.nii.gz']));
        
        fprintf('copied %s %s rest\n',ID{i},sessionID{s})
        
    end
    
    end
    
end

