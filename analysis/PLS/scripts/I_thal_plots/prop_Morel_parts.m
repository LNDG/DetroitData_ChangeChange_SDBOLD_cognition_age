% plot histogram of BSR voxels in Morel subregions
clear all

addpath(genpath('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/NIfTI_20140122'))
addpath(genpath('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/tools/preprocessing_tools'))

% load BSR mask
BSR_img=S_load_nii_2d('/Volumes/fb-lip/Projects/Naftali/data/analysis/PLS/figures/SD_diff_fMRIrest_N74_Mot_noDiab_COG_latentChange_Age_BfMRIbsr_lv1_thr3_cluster25_mask.nii.gz')';

MorelFile='/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Morel/Thalamus_Morel_consolidated_mask_v3_3mm.nii.gz';

MorelMask=S_load_nii_2d(MorelFile)';

% get BSR voxels across all parts
MorelMask_all=zeros(size(MorelMask));
MorelMask_all(find(MorelMask))=1; % all areas mask

% get overlap with thalamus (all regions)
BSR_Morelthal=double((BSR_img+MorelMask_all)==2);

% get  BSR voxels for each part and compute percetange voxels
MorelMasks=[];

part=[1:14 17]; % Morel labels

for i = 1:length(part)

    MorelMasks(i,:)=double(MorelMask==part(i)); % mask area label i
    
    BSR_Morelthal_parts(i,:)=double((BSR_img+MorelMasks(i,:))==2);
    
    prop_Morelthal_parts(i,:)=sum(BSR_Morelthal_parts(i,:))/sum(BSR_Morelthal);

end

% for saving
BSR_Morelthal_N=sum(BSR_Morelthal);
BSR_Morelthal_parts_N=sum(BSR_Morelthal_parts,2);
Morelthal_parcel_voxelsN=sum(MorelMasks,2);

% compute proportion of voxels per parcel
prop_Morelthal_perPart = BSR_Morelthal_parts_N ./sum(MorelMasks,2);

%plot
[prop_Morelthal_perPart_PercSorted ind]=sort(prop_Morelthal_perPart.*100,'descend'); % sort bars descending and in percent

part_labels={'AN' 'VM' 'VL' 'MGN' 'MD' 'PuA' 'LP' 'IL' 'VA ' 'Po' 'LGN' 'PuM' 'PuI' 'PuL' 'VP'};
part_labels=part_labels(ind);

b=bar(prop_Morelthal_perPart_PercSorted);
b.FaceColor=[0.2 0.8 0.8];
xlabel('Morel area')
ylabel('Percent of voxels')

ylim([0,100])
yticks([0 20 40 60 80 100])

xlim([0,length(part)+1])
xticks(1:length(part))
xticklabels(part_labels)
% xtickangle(45)

set(gca,'FontSize',18);
set(gcf,'position',[0,0,900,600])

% save figure
set(gcf,'Units','Inches');
pos = get(gcf,'Position');
set(gcf,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])
print(gcf,'/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/thal_change/Morel_prop_parts_latentCH.pdf','-dpdf','-r0')
close

% save to mat file
save('/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/thal_change/Morel_prop_parts_latentCH','prop_Morelthal_parts','part','BSR_Morelthal_N','BSR_Morelthal_parts_N','Morelthal_parcel_voxelsN','prop_Morelthal_perPart','prop_Morelthal_perPart_PercSorted');
