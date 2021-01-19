function E_updateSDBoldDiff21
%%Add SD BOLD change score WAVE 2 - WAVE 1 to sessiondata.mat files


%% Init folder paths
BASEPATH ='/home/mpib/LNDG/Naftali/data/';
MATPATH = ([BASEPATH,'analysis/PLS/mean/']);
DATAPATH =([BASEPATH,'preproc/mri2/']);

%Subject IDs
%N74
IDs={'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};

%waitbar
waitB = waitbar(0,'Please wait...');


for subjID = 1:(numel(IDs))


   clear a;
   %% load _BfMRIsessiondata.mats variables to be changed 

  	data = load([MATPATH, 'SD_12ONLY_', IDs{subjID}, '_BfMRIsessiondata.mat'], 'session_info','st_coords','num_subj_cond','st_evt_list', 'st_datamat');

    % compute SD BOLD change score
    data.st_datamat(3,:) = data.st_datamat(2,:) - data.st_datamat(1,:);
    
    %update session info
    data.session_info.num_conditions    = 3; % update total number of cond.
    data.session_info.num_conditions0   = 3;
    data.session_info.condition{3}      = 'SDrest_diff21';
    data.session_info.condition0{3}     = 'SDrest_diff21';
    
    data.session_info.condition_baseline{3} = [-1;1];
    data.session_info.condition_baseline0{3} = [-1;1];

    data.st_evt_list    = [1, 2, 3];  % update total number of cond.
    data.num_subj_cond  = [1, 1, 1];
    
    %save data
    
   %% save new data file
   save ([MATPATH, 'SD_12ONLY_', IDs{subjID}, '_BfMRIsessiondata.mat'], '-struct', 'data', '-append');

   clear data

   disp (IDs{subjID})
   waitbar(subjID/numel(IDs),waitB);
   
end
end