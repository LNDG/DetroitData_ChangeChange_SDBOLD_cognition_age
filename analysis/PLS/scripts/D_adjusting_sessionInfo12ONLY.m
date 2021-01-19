function D_adjusting_sessionInfo
%% Alter PLS sessiondata.mat info to match 3 conditions

%% Initialize folder paths
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
   try
      a = load([MATPATH, 'SD_12ONLY_', IDs{subjID}, '_BfMRIsessiondata.mat'], 'session_info','st_coords','num_subj_cond','st_evt_list', 'st_datamat');
      catch ME
      disp (ME.message)
   end
   
   
      
   %% edit conditions labels  
   a.session_info.condition(1,1) = {'SDrest_s1'};
   a.session_info.condition(1,2) = {'SDrest_s2'};
   
   a.session_info.condition0 = a.session_info.condition;
   
   
   %% rename prefix to display ID in analysis
   a.session_info.datamat_prefix = ['SD_12ONLY_',IDs{subjID}];
     
   %% edit condition counters
   a.session_info.num_conditions  = 3;
   a.session_info.num_conditions0 = 3;
   
   %% add zero vector to st_datamat if condition(=session) not availilbe
   % update condition variables according to count of conditions

   if size(a.st_datamat,1) == 1
       a.st_datamat(2,:) = zeros(1, numel(a.st_coords));
       a.st_datamat(3,:) = zeros(1, numel(a.st_coords));
       
       a.session_info.condition_baseline{2}  = a.session_info.condition_baseline{1};
       a.session_info.condition_baseline{3}  = a.session_info.condition_baseline{1};

       a.session_info.condition_baseline0{2} = a.session_info.condition_baseline0{1};
       a.session_info.condition_baseline0{3} = a.session_info.condition_baseline0{1};

       a.session_info.run(2).blk_onsets      = a.session_info.run(1).blk_onsets;
       a.session_info.run(3).blk_onsets      = a.session_info.run(1).blk_onsets;

       a.session_info.run(2).blk_length      = a.session_info.run(1).blk_length;
       a.session_info.run(3).blk_length      = a.session_info.run(1).blk_length;

       
   elseif size(a.st_datamat,1) == 2
       a.st_datamat(3,:) = zeros(1, numel(a.st_coords));  
       
       a.session_info.condition_baseline{3}  = a.session_info.condition_baseline{1};
 
       a.session_info.condition_baseline0{3} = a.session_info.condition_baseline0{1};
    
       a.session_info.run(3).blk_onsets      = a.session_info.run(1).blk_onsets;
  
       a.session_info.run(3).blk_length      = a.session_info.run(1).blk_length;

   end
       
   % num_subj_cond AND st_evt_list: ones or numbers = count of conditions
   a.num_subj_cond = [1,1,1];
   a.st_evt_list   = [1,2,3];

    %% save new data file
   save ([MATPATH, 'SD_12ONLY_', IDs{subjID}, '_BfMRIsessiondata.mat'], '-struct', 'a', '-append');
    
   clear a
   
   waitbar(subjID/numel(IDs),waitB);
   
end
end