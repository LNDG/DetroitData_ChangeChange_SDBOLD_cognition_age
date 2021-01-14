function dicom2nifti_conversion
% This function converts the raw anatomical and resting state (f)MRI data
% from dicom to nifti format. Analyses reported in the paper pertain to
% sessions 1 (wave 1) and 2 (wave2).
%
% Notes: - ID 1340 reconverted manually with dicom2nii toolbox due to corrupt header.
%        - ID 1610 session 1 skipped in script due to conversion error. Processed manually using dicom2nii toolbox.

%specify folder IDs
ID = {'1300' '1301' '1308' '1312' '1317' '1321' '1322' '1325' '1327' '1329' '1330' '1335' '1340' '1356' '1364' '1371' '1381' '1385' '1394' '1399' '1408' '1409' '1413' '1415' '1423' '1426' '1431' '1438' '1446' '1449' '1460' '1482' '1486' '1497' '1498' '1500' '1506' '1510' '1514' '1515' '1523' '1525' '1527' '1528' '1531' '1543' '1552' '1560' '1563' '1565' '1568' '1570' '1571' '1573' '1578' '1581' '1583' '1584' '1585' '1586' '1587' '1591' '1592' '1603' '1606' '1607' '1608' '1610' '1611' '1619' '1622' '1623' '1625' '1634' '1635' '1636' '1637' '1638' '1641' '1642' '1643' '1644' '1645' '1646' '1647' '1648' '1650' '1651' '1652' '1653' '1654' '1655' '1657' '1658' '1659' '1660' '1661' '1662' '1663' '1664' '1665' '1666' '1667' '1668' '1669' '1670' '1671' '1672' '1673' '1674' '1675' '1676' '1677' '1678' '1679' '1681' '1682' '1683' '1684' '1685' '1686' '1687' '1688' '1689' '1690' '1692' '1693' '1694' '1695' '1696' '1697' '1698' '1699' '1700' '1701' '1702' '1703' '1704' '1705' '1706' '1707' '1708' '1709' '1710' '1711' '1712' '1713' '1714' '1715' '1716' '1717' '1718' '1719' '1720' '1721' '1722' '1723' '1724' '1725' '1726' '1727' '1729' '1730' '1731' '1732' '1733' '1734' '1736' '1737' '1738' '1739' '1740' '1741' '1742' '1743' '1744' '1745' '1747' '1748' '1750' '1751' '1752' '1753' '1754' '1755' '1756' '1757' '1761' '1762' '1763' '1764' '1766' '1767' '1769' '1770' '1771' '1772' '1773' '1774' '1775' '1776' '1777' '1778' '1779' '1780' '1781'};

%session IDs
sessionID = {'session1' 'session2' 'session3'};
% add dicom2nii toolbox
%addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/preproc/scripts/y_GIT_repo/toolboxes/xiangruili-dicm2nii-ae1d301'));

RAW_dir = '/home/mpib/skowron/NetworkFolders/LNDG/Projects/Naftali/RAW/newSync/Doug rsMRI';
DATA_dir = '/home/mpib/skowron/NetworkFolders/LNDG/Projects/Naftali/data/preproc/mri2';

if ~exist(DATA_dir, 'dir')
   mkdir(DATA_dir)
end

for i = 1:length(ID)
    
    SUB_dir = fullfile(DATA_dir,ID{i});
    
    % make subject output folder
    if ~exist(SUB_dir, 'dir')
       mkdir(SUB_dir)
%     else   
%         fprintf('Subject %s already processed. Skipping...\n',ID{i})
%         continue % skip if conversion already done
    end
    
    cd(SUB_dir);
    
    for s = 1:length(sessionID)
        
        SUB_SES_dir = [];
        
        % check if session data folder exists for subject
        if strcmp(sessionID{s},'session1') && exist(fullfile(RAW_dir,ID{i}))
            
            SUB_SES_dir = fullfile(RAW_dir,ID{i});
            
        elseif strcmp(sessionID{s},'session1') && exist(fullfile(RAW_dir,'new',ID{i}))

            SUB_SES_dir =  fullfile(RAW_dir,'new',ID{i});
            
        end
            
        if strcmp(sessionID{s},'session2') && exist(fullfile(RAW_dir,[ID{i} 'L']))
            
            SUB_SES_dir = fullfile(RAW_dir,[ID{i} 'L']);
            
        elseif strcmp(sessionID{s},'session2') && exist(fullfile(RAW_dir,'new',[ID{i} 'L']))

            SUB_SES_dir =  fullfile(RAW_dir,'new',[ID{i} 'L']);
            
        end
            
        if strcmp(sessionID{s},'session3') && exist(fullfile(RAW_dir,[ID{i} 'L2']))
            
            SUB_SES_dir = fullfile(RAW_dir,[ID{i} 'L2']);
            
        elseif strcmp(sessionID{s},'session3') && exist(fullfile(RAW_dir,'new',[ID{i} 'L2']))
            
            SUB_SES_dir =  fullfile(RAW_dir,'new',[ID{i} 'L2']);
            
        end
            
        if isempty(SUB_SES_dir)
            fprintf('No raw directory for %s %s\n',ID{i},sessionID{s})
            continue
        end
        
        OUT_dir = fullfile(SUB_dir,sessionID{s});
        
        if ~exist(OUT_dir, 'dir')
            mkdir(OUT_dir)
        end
        
        cd(OUT_dir)
        
        % skip for sub 1610 session 1 because of auto conversion issues.
        % Processed manually
        if strcmp(ID{i},'1610') && strcmp(sessionID{s},'session1')
            fprintf('Warning! Skipping 1610 session 1 due to conversion issues. Processed manually...\n')
            continue
        end
        
        %% ANAT conversion
        
        % skip anat conversion if already processed
        if ~isfile(fullfile(OUT_dir,'anat',[ID{i},'_anat_s' num2str(s) '.nii.gz']))

            % anat conversion
            mkdir(fullfile(OUT_dir,'anat'));
            cd(fullfile(OUT_dir,'anat'))

            anat_raw = dir(fullfile(SUB_SES_dir,'*t1*'));

            if isempty(anat_raw)
               fprintf('Missing anat data folder for %s %s. Skipping...\n',ID{i},sessionID{s})
            else
                
                if length(anat_raw) > 1

                    % check which rest folder contains full run
                    a_full = length(dir(fullfile(SUB_SES_dir,anat_raw(2).name,'*.dcm'))) == 177;

                    if a_full
                        anat_raw = anat_raw(2).name;
                    else
                        fprintf('Problem with %s %s anat. Quitting...\n',ID{i},sessionID{s})
                        return
                    end

                else
                    rest_raw = rest_raw.name;    
                end

                anat_raw = anat_raw.name;

                copyfile(fullfile(SUB_SES_dir,anat_raw,'*.dcm'),fullfile(OUT_dir,'anat'))

                system(['/home/mpib/LNDG/Naftali/data/preproc/scripts/y_GIT_repo/dcm2nii -f ',fullfile(OUT_dir,'anat','*.dcm')]);

                %dicm2nii(fullfile(SUB_SES_dir,anat_raw),fullfile(OUT_dir,'anat'),1)

                % rename
                anat_nifti=dir(fullfile(OUT_dir,'anat','co*.nii.gz'));
                anat_nifti=anat_nifti.name;

                movefile(fullfile(OUT_dir,'anat',anat_nifti),fullfile(OUT_dir,'anat',[ID{i},'_anat_s' num2str(s) '.nii.gz']))

                % clean up
                delete(fullfile(OUT_dir,'anat','*1001.nii.gz'));
                delete(fullfile(OUT_dir,'anat','*.dcm'));
            end
           
        else
            
            fprintf('Anat conversion already produced for %s %s. Skipping...\n',ID{i},sessionID{s})
            
        end

        cd(OUT_dir)
        
        %% Rest conversion
        
        if ~isfile(fullfile(OUT_dir,'rest',[ID{i},'_rest_s' num2str(s) '.nii.gz']))
        
            % rest conversion
            mkdir(fullfile(OUT_dir,'rest'));
            cd(fullfile(OUT_dir,'rest'))

            rest_raw = dir(fullfile(SUB_SES_dir,'*resting*'));

            if isempty(rest_raw)
               fprintf('Missing rest data folder for %s %s. Skipping...\n',ID{i},sessionID{s})
            else

                if length(rest_raw) > 1

                    % check which rest folder contains full run
                    r_full = length(dir(fullfile(SUB_SES_dir,rest_raw(2).name,'*.dcm'))) == 200;

                    if r_full
                        rest_raw = rest_raw(2).name;
                    else
                        fprintf('Problem with %s %s rest. Quitting...\n',ID{i},sessionID{s})
                        return
                    end

                else
                    rest_raw = rest_raw.name;    
                end

                copyfile(fullfile(SUB_SES_dir,rest_raw,'*.dcm'),fullfile(OUT_dir,'rest'))

                system(['/home/mpib/LNDG/Naftali/data/preproc/scripts/y_GIT_repo/dcm2nii -f ',fullfile(OUT_dir,'rest','*.dcm')]);
                %dicm2nii(fullfile(SUB_SES_dir,rest_raw),fullfile(OUT_dir,'rest'),1)

                % rename
                rest_nifti=dir(fullfile(OUT_dir,'rest','*.nii.gz'));
                rest_nifti=rest_nifti.name;

                movefile(fullfile(OUT_dir,'rest',rest_nifti),fullfile(OUT_dir,'rest',[ID{i},'_rest_s' num2str(s) '.nii.gz']))

                % clean up
                delete(fullfile(OUT_dir,'rest','*.dcm'));
            end
            
        else
           
            fprintf('Rest conversion already produced for %s %s. Skipping...\n',ID{i},sessionID{s})
            
        end
        
        cd(OUT_dir)
    
    end
    
    fprintf('finished subject %s\n',ID{i})
end
end
