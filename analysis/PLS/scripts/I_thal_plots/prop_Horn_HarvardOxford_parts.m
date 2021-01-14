% this script creates a bar plot showing the percentage of voxels in each
% Horn subregion (masked by the Harvard-Oxford subcortical atlas) with
% robust BOLD SD - behaviour correlations according to the thresholded BSR
% results of the longitudinal PLS model.

clear all

% add toolboxes
addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/NIfTI_20140122'))
addpath(genpath('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/tools/preprocessing_tools'))

% load thresholded BSR mask
BSR_img=S_load_nii_2d('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/SD_diff_fMRIrest_N76_Mot_noDiab_COG_allChange_logAge_win1664_BfMRIbsr_lv1_thr27_cluster25_mask.nii.gz')';

% Horn subregion labels
part={'occipital' 'postparietal' 'prefrontal' 'premotor' 'primarymotor' 'sensory' 'temporal'};

% make save path
mkdir('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/thal_w1w2')

%% create Horn mask for all subregions and get percentage of BSR voxels
masks_cat=[];
for p = 1:length(part)
    
    p_part=['/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Horn_2016_Thalamic_Connectivity_Atlas/' part{p} '_mask_3mm_HarvardOxfordThal.nii.gz']; % Horn atlas masked by Harvard-Oxford subcortical atlas (left and right thlamus) using fslmaths
    img=S_load_nii_2d(p_part)';
    
    % save for concatenated masks
    masks_cat(p,:)=img;
    
end

% total Horn mask for all subparts
HornMask_all=sum(masks_cat,1);
HornMask_all(find(HornMask_all))=1; % necessary to account for minor overlap between some subregions

%save total Horn Mask
nii=load_nii(p_part);
nii.img=[];

nii.img=HornMask_all;
save_nii(nii,['/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Horn_2016_Thalamic_Connectivity_Atlas/All_Horn_HarvardOxford_MNI_3mm.nii.gz']);

% get BSR overlap with Horn thalamus (all subregions)
BSR_Hornthal=double((BSR_img+HornMask_all)==2);

%% compute percentage of BSR voxels in each Horn subregion
HornMasks=[];

% cycle over parcels
for p2 = 1:length(part)
    
    % load Horn subregion mask (confined by Harvard-Oxford subcortical atlas)
    p2_part=['/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Horn_2016_Thalamic_Connectivity_Atlas/' part{p2} '_mask_3mm_HarvardOxfordThal.nii.gz'];
    HornMask=S_load_nii_2d(p2_part)';
    
    HornMasks(p2,:)=HornMask;
    
    % get BSR voxels in Horn subregion
    BSR_Hornthal_parts(p2,:)=double((BSR_img+HornMasks(p2,:))==2);
    
    prop_Hornthal_parts(p2,:)=sum(BSR_Hornthal_parts(p2,:))/sum(BSR_Hornthal); % proportion of region-specific BSR voxels relative to all thalamus voxels (not plotted)

end

% compute overlapping BSR in different parcels (not plotted)
BSR_Hornthal_parts_overlap_N = zeros(length(part)); % cells contain number of overlapping voxels for each parcel combination

for p3 = 1:length(part)
    for p4 = 1:length(part)
    
        BSR_Hornthal_parts_overlap_N(p3,p4) = sum(double(BSR_Hornthal_parts(p3,:)+BSR_Hornthal_parts(p4,:)==2));
        
    end
end

BSR_Hornthal_parts_overlap_prop = BSR_Hornthal_parts_overlap_N ./ sum(BSR_Hornthal); % note: not real proportions. Does not add to 1

% variables for saving
BSR_Hornthal_N=sum(BSR_Hornthal);
BSR_Hornthal_parts_N=sum(BSR_Hornthal_parts,2);
Hornthal_parcel_voxelsN=sum(HornMasks,2);

% compute proportion of BSR voxels per parcel (for plotting!)
prop_Hornthal_perPart = BSR_Hornthal_parts_N ./sum(HornMasks,2);

%plot
[prop_Hornthal_perPart_PercSorted ind]=sort(prop_Hornthal_perPart.*100,'descend'); % sort bars descending and in percent

part_labels={'occipital','posterior parietal','prefrontal','premotor','primary motor','sensory','temporal'};
part_labels=part_labels(ind);

b=bar(prop_Hornthal_perPart_PercSorted);
b.FaceColor=[0.2 0.8 0.8];
xlabel('Horn area')
ylabel('Percent of voxels')

ylim([0,100])
yticks([0 20 40 60 80 100])

xlim([0,length(part)+1])
xticks(1:length(part))
xticklabels(part_labels)
xtickangle(45)

set(gca,'FontSize',18);
set(gcf,'position',[0,0,900,600])

% save figure
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/thal_change/Horn_HarvardOxfordThal_prop_parts.pdf','-dpdf','-r0')
close

% save informative variables to mat file
save('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/thal_change/Horn_HarvardOxfordThal_prop_parts','prop_Hornthal_parts','part','BSR_Hornthal_N','BSR_Hornthal_parts_N','BSR_Hornthal_parts_overlap_N','BSR_Hornthal_parts_overlap_prop','Hornthal_parcel_voxelsN','prop_Hornthal_perPart','prop_Hornthal_perPart_PercSorted');
