#!/bin/bash

# downsample binary thalamus and striatum atlas masks to 3mm using Human Connectome workbench

# toolbox path
wbPath='/Users/skowron/Documents/workbench/bin_macosx64'

# Paths
HornInPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Horn_2016_Thalamic_Connectivity_Atlas/2mm'
HornOutPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Horn_2016_Thalamic_Connectivity_Atlas'

MorelPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/Morel'

BGhatPath='/Volumes/FB-LIP/Projects/Naftali/data/analysis/standards/BGhat'

# Horn labels
HornNames='occipital postparietal prefrontal premotor primarymotor sensory temporal'

# infos for workbench resampling routine
affineMat='/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/tools/affine.txt' # matrix specifying affine transformation
BSRimg='/Volumes/FB-LIP/Projects/Naftali/data/analysis/PLS/figures/SD_diff_fMRIrest_N76_Mot_noDiab_COG_allChange_logAge_win1664_BfMRIbsr_lv1_thresh35_cluster25.nii.gz' # reference volume with desired resolution

# Horn atlas downsampling
for part in $HornNames
do
	
	${wbPath}/wb_command -volume-affine-resample ${HornInPath}/${part}_thr_MNI_2mm.nii.gz ${affineMat} ${BSRimg} ENCLOSING_VOXEL ${HornOutPath}/${part}_mask_3mm.nii.gz # enclosing_voxel method because images are binary
	
done

# Morel atlas downsampling

${wbPath}/wb_command -volume-affine-resample ${MorelPath}/Thalamus_Morel_consolidated_mask_v3.nii ${affineMat} ${BSRimg} ENCLOSING_VOXEL ${MorelPath}/Thalamus_Morel_consolidated_mask_v3_3mm.nii.gz

# BGhat atlas downsampling
${wbPath}/wb_command -volume-affine-resample ${BGhatPath}/BGHAT_MNI2mm_mask.nii.gz ${affineMat} ${BSRimg} ENCLOSING_VOXEL ${BGhatPath}/BGHAT_MNI3mm_mask.nii.gz
