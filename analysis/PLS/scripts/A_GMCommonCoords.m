function A_GMCommonCoords
%Saves out the indices of commonly activated voxel coordinates across
%subjects and applies a gray matter mask. Also saves out the result as a
%mask in nifti format.
%
% ran with matlab/R2014b

% add toolbox
addpath(genpath('/home/mpib/LNDG/toolboxes/NIfTI_20140122'));

%N74
subjID = [1301 1312 1321 1340 1356 1394 1399 1409 1415 1423 1431 1438 1449 1460 1498 1527 1528 1565 1581 1583 1586 1587 1606 1607 1608 1610 1619 1634 1635 1637 1638 1641 1642 1647 1655 1661 1662 1667 1669 1670 1671 1672 1673 1676 1678 1679 1685 1690 1695 1699 1702 1703 1707 1708 1710 1714 1716 1720 1721 1722 1723 1729 1730 1733 1734 1744 1750 1754 1756 1762 1764 1766 1769 1770];

% initialize common coordinates
common_coords = (1:1000000);

%% Init folder paths
BASEPATH ='/home/mpib/LNDG/Naftali/data/';
%BASEPATH ='/Users/wiegert/tardis/Naftali/data/';
NIIPATH = ([BASEPATH, 'preproc/mri2/']);
%NIIPATH = '/Users/wiegert/MPIB/commocoords/'
SAVEPATH= ([BASEPATH, 'analysis/PLS/scripts/']);

%% get commonly activated voxel indices across subjects
for i = 1:numel(subjID)  
    for s=1:2 % sessions 1 and 2

        %load preprocessed nifti file
        fname = ([NIIPATH , num2str(subjID(i)), '/session', num2str(s), '/rest/', num2str(subjID(i)), '_rest_s', num2str(s), '_FEAT_filt_detrend_denoised_remean_MNI3mm.nii.gz']);
        
        % load nifit and reshape to 2D
        nii=load_nii(fname);
        nii=nii.img;
        nii=reshape (nii, [], size(nii,4));
        subj_coords = find(nii(:,1));

        % get common coords
        common_coords=intersect(common_coords,subj_coords);

        disp ([num2str(subjID(i)), ' session', num2str(s), ' : added to common coords']);

    end
end

%% gray matter coords
mask = load_nii ([BASEPATH, 'analysis/PLS/scripts/standards/avg152_T1_gray_mask_90_3mm_binary.nii']);
mask = mask.img;
mask = reshape (mask, [], size(mask,4));
mask_coords = find(mask);

%% mask common coords by gray matter coords
GMcommon_coords=intersect(common_coords,mask_coords);

%% save coords
save ([SAVEPATH, 'GMcommoncoordsN', num2str(numel(subjID)),'.mat'], 'GMcommon_coords');
disp (['save: ', SAVEPATH, 'GMcommoncoordsN', num2str(numel(subjID)),'.mat']);


%% save mask as nifti
nii = load_nii ([BASEPATH, 'analysis/PLS/scripts/avg152_T1_gray_mask_90_3mm_binary.nii']);
box = zeros(size(nii.img));
box (GMcommon_coords) = ones (numel(GMcommon_coords),1);
nii.img = box;
save_nii (nii, [BASEPATH, 'analysis/PLS/scripts/GMcomCoordsN', num2str(numel(subjID)),'.nii']);
disp (['save: ', BASEPATH, 'analysis/PLS/scripts/GMcomCoordsN', num2str(numel(subjID)),'.nii']);

end
