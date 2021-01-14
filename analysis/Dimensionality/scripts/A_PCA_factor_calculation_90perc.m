% This function finds PCA dimensionality necessary to capture up to 90% of the total variance of whole-brain subjects' spatiotemporal data.
% Input: preprocessed nifti, common coordinates
% Ouput: Dimensions; Number of PCA dimensions, EXPLAINED: percentage of varianc explained per
% component 
% Requires usage of NIfTI toolbox. Available at: https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image


%% Set paths

SubjectList={'1301' '1312' '1321' '1340' '1356' '1394' '1399' '1409' '1413' '1415' '1423' '1431' '1438' '1449' '1460' '1498' '1527' '1528' '1565' '1568' '1578' '1581' '1583' '1586' '1587' '1606' '1607' '1608' '1610' '1619' '1634' '1635' '1637' '1638' '1641' '1642' '1647' '1655' '1661' '1662' '1664' '1667' '1669' '1670' '1671' '1672' '1673' '1676' '1678' '1679' '1685' '1690' '1695' '1699' '1702' '1703' '1707' '1708' '1710' '1713' '1714' '1716' '1720' '1721' '1722' '1723' '1729' '1730' '1733' '1734' '1744' '1750' '1754' '1756' '1762' '1764' '1766' '1769' '1770'};

BASEPATH = '/Volumes/FB-LIP/Projects/Naftali/data/';   % root directory
SAVEPATH = ([BASEPATH,'analysis/Dimensionality/PCAdim_wholebrain/']);  % output path

mkdir(SAVEPATH);

%% Add toolboxes to path

addpath(genpath([ BASEPATH 'analysis/PLS/tools/preprocessing_tools']));
addpath(genpath([ BASEPATH 'analysis/PLS/tools/NIfTI_20140122']));

%% Load common coords

load([BASEPATH, 'analysis/PLS/scripts/GMcommoncoordsN79.mat']);

%% Loop over subjects
for i=1:numel(SubjectList)
    for s=1:2 % cycle over sessions
     
        %% Load subject's nifti  
        fname=([BASEPATH 'preproc/mri2/' SubjectList{i} '/session' num2str(s) '/rest/' SubjectList{i} '_rest_s' num2str(s) '_FEAT_filt_detrend_denoised_remean_MNI3mm.nii.gz']);
        img = S_load_nii_2d(fname);

        img = img(GMcommon_coords,:);    % constrains the img file to only use final_coords, which are commonly activated voxels across subjects
        
        %% temporal PCA

        [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true);  % temporal PCA using correlation matrix (correlation over space) (Only EXPLAINED output needed)

        %% Extracting components explaining up to 90% of the variance

        % Initialize total variance and dimensions count
        TotalVar=0;
        Dimensions=0;

        for j=1:numel(EXPLAINED)
            TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
            if TotalVar>90                      % set 90% criterion
                Dimensions=j;                 % Choose dimension that reaches min 90% of variance
                break
            end
        end

        %% Save indivSubjectList{i}ual .mats containing PCA information

        SAVEFILE=([SubjectList{i}, '_session', num2str(s) ,'_temporalPCAcorr_90variance.mat']);
        save([SAVEPATH, SAVEFILE],'EXPLAINED', 'Dimensions');
        disp (['saved to: ', SAVEPATH, SAVEFILE]);

        clear  Dimensions EXPLAINED TotalVar SAVEFILE j;
        
        %% spatial PCA
        img=img'; % spatial PCA: rows = timepoints, columns=voxels

        [~, ~, ~, ~, EXPLAINED] = pca(img, 'VariableWeights','variance', 'Centered', true));  % spatial PCA using correlation matrix (correlation over time) (Only EXPLAINED output needed)

        %% Extracting components explaining up to 90% of the variance

        % Initialize total variance and dimensions count
        TotalVar=0;
        Dimensions=0;

        for j=1:numel(EXPLAINED)
            TotalVar=TotalVar+EXPLAINED(j,1);   % EXPLAINED represents variance accounted for by a given dimension.
            if TotalVar>90                      % set 90% criterion
                Dimensions=j;                 % Choose dimension that reaches min 90% of variance
                break
            end
        end

        %% Save indivSubjectList{i}ual .mats containing PCA information

        SAVEFILE=([SubjectList{i}, '_session', num2str(s) ,'_spatialPCAcorr_90variance.mat']);
        save([SAVEPATH, SAVEFILE],'EXPLAINED', 'Dimensions');
        disp (['saved to: ', SAVEPATH, SAVEFILE]);

        clear  Dimensions EXPLAINED TotalVar SAVEFILE img j fname NIFTIPATH;
    end 
end

