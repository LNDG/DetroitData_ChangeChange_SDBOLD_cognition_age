function SDBOLD_filecreation(subjID, prefix, sdprefix)
% replaces st_datamat variable in PLS sessiondata.mat file with SD BOLD for
% the gray matter masked common voxel coordinates.
% Inputs: Subject ID, prefix for original sessiondata.mat files (e.g.
% mean_), prefix for new sessiondata.mat files (e.g. sd_)
%
%for compilation: /opt/matlab/R2014b/bin/mcc -m SDBOLD_filecreation.m -a /home/mpib/LNDG/toolboxes/NIfTI_20140122 -a /home/mpib/LNDG/toolboxes/preprocessing_tools -a /home/mpib/LNDG/toolboxes/spm_squeeze

%% Initialize folder paths
BASEPATH ='/home/mpib/LNDG/Naftali/data/';
MATPATH = ([BASEPATH,'analysis/PLS/mean/']);

disp ('adjusting conditions...')

%% create the SDBOLD datamats

a = load([MATPATH, prefix, subjID, '_BfMRIsessiondata.mat']); %this loads a subject's sessiondata file.

%load GM common coords
load ([BASEPATH, 'analysis/PLS/scripts/GMcommoncoordsN79.mat'])
final_coords = GMcommon_coords;

a = rmfield(a,'st_datamat');
a = rmfield(a,'st_coords');

conditions = a.session_info.condition;

%replace fields with correct info.
a.session_info.datamat_prefix=sdprefix;
a.st_coords = final_coords; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create this subject's datamat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a.st_datamat = zeros(numel(conditions),numel(final_coords)); %(cond voxel)
   
    
% intialize cond specific scan count for populating cond_data
clear count cond_data block_scan;
for cond = 1:numel(conditions)
    count{cond} = 0;
end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % within each block express each scan as deviation from block's 
  % temporal mean.Concatenate all these deviation values into one 
  % long condition specific set of scans that were normalized for 
  % block-to-block differences in signal strength. In the end calculate
  % stdev across all normalized cond scans
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % for each condition identify its scans within  runs 
  % and prepare where to put cond specific normalized data
  used_run = [];
  for cond = 1:numel(conditions)
    tot_num_scans = 0;
    
    dst_run = 0;
    for run = 1:a.session_info.num_runs
      onsets = a.session_info.run(run).blk_onsets{cond}+1;% +1 because we need matlab indexing convention
      if onsets==0; %this if statement looks for any conditions (within run) that don't have data of interest, and if it finds any, then the next "run" loop is entered.
          continue
      end
      
      dst_run = dst_run + 1;
      used_run(cond, run) = 1;
      
      lengths = a.session_info.run(run).blk_length{cond};
      
      for block = 1:numel(onsets)
        block_scans{cond}{dst_run}{block} = onsets(block)-1+[1:lengths(block)];
        this_length = lengths(block);
        if max(block_scans{cond}{dst_run}{block}>a.session_info.run(run).num_scans)
          disp(['bljak ' subjID ' something wrong in block onset lengths']);
          block_scans{cond}{dst_run}{block} = intersect(block_scans{cond}{dst_run}{block},[1:a.session_info.run(run).num_scans]);
          this_length = numel(block_scans{cond}{dst_run}{block});
        end
        tot_num_scans = tot_num_scans + this_length;
      end
    end
    cond_data{cond} = zeros(numel(final_coords),tot_num_scans);%create empty matrix with dimensions coords (rows) by total # of scans (columns). 
  end
  
  dst_run = 0;
  for run = 1:a.session_info.num_runs   %sessions 1 and 2       
    
    % load nifti file for this run
    disp (['loading image run ', num2str(run), ' ...'])

    fname = ([a.session_info.run(run).data_path, '/', a.session_info.run(run).data_files{1}]);
    nii = load_nii(fname); %(x by y by z by time)
    img = double(reshape(nii.img,[],size(nii.img,4)));% 4 here refers to 4th dimension in 4D file....time.
    img = img(final_coords,:);%this command constrains the img file to only use final_coords, which is common across subjects.

    clear nii;

    %now, proceed with creating SD datamat...          

    disp('writing SD data...')      
    
    dst_run = dst_run + 1;

    for cond = 1:numel(conditions)

      if not(used_run(cond,run))
        continue
      end
      
        %just one block in this case since we have resting state data and
        %each condition corresponds to the imaging session

        block_data = img(:,block_scans{cond}{1}{1});% (vox time)

        % normalize block_data to global block mean = 100. 
        block_data = 100*block_data/mean(mean(block_data));
        % temporal mean of this block
        block_mean = mean(block_data,2); % (vox) - this should be 100
        % express scans in this block as  deviations from block_mean
        % and append to cond_data
        good_vox = find(block_mean);              
        for t = 1:size(block_data,2)
          count{cond} = count{cond} + 1;
          cond_data{cond}(good_vox,count{cond}) = block_data(good_vox,t) - block_mean(good_vox);%must decide about perc change option here!!??
        end
    end
  end

  %% now calc stdev across all cond scans.
  for cond = 1:numel(conditions)
      a.st_datamat(cond,:) = squeeze(std(cond_data{cond},0,2))';
  end
  
  % save new sessiondata.mat file containing SD BOLD info
  clear data;
  save([MATPATH, sdprefix, subjID, '_BfMRIsessiondata.mat'],'-struct','a','-mat');

disp (['ID: ', subjID, ' done!'])

end