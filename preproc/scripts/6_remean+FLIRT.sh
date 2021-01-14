#!/bin/bash

## Re-add mean & FLIRT registration to MNI space

source preproc_config.sh

# create log path
if [ ! -d ${LogPath}/remean_FLIRT ]; then
	mkdir -p ${LogPath}/remean_FLIRT
	chmod 770 ${LogPath}/remean_FLIRT
fi

for SUB in ${SubjectID}; do
	
    sessions=$(ls "${DataPath}/${SUB}/")

    for ses in ${sessions}; do
		
		if [ ! -f ${DataPath}/${SUB}/${ses}/rest/${SUB}_rest_s${ses: -1}_FEAT_filt_detrend_denoised.nii.gz ]; then
			echo "${SUB}_rest_s${ses: -1}_FEAT_filt_detrend_denoised.nii.gz not found"
			continue
		fi
		
		# create cluster job	
		echo "#PBS -N REG${FixThreshold}_${SUB}_${ses}"								>> job 			# job name
		echo "#PBS -l walltime=1:0:0" 											>> job			# time until job is killed
		echo "#PBS -l mem=2000mb"	 											>> job			# books 8gb RAM for the job
		echo "#PBS -o ${LogPath}/remean_FLIRT" 			>> job			# write (error) log to log folder
		echo "#PBS -e ${LogPath}/remean_FLIRT" 			>> job
		echo "#PBS -j oe"														>> job 
		
		echo ". /etc/fsl/5.0/fsl.sh"											>> job  				
		
		## READD MEAN
		echo "${ScriptsPath}/run_add_mean.sh /opt/matlab/R2014b/ ${DataPath} ${SUB} ${ses: -1}" 		>> job  

		## FLIRT
		# Variables
		FNAME=${SUB}_rest_s${ses: -1}_FEAT_filt_detrend_denoised_remean
		BNAME=${SUB}_anat_s${ses: -1}_brain

		preproc="${DataPath}/${SUB}/${ses}/rest/${FNAME}"
		registered="${DataPath}/${SUB}/${ses}/rest/${FNAME}_MNI3mm"
		bet="${DataPath}/${SUB}/${ses}/anat/${BNAME}"
		
		preproc2BET="${DataPath}/${SUB}/${ses}/rest/FEAT.feat/reg/${SUB}_s${ses: -1}_preproc2BET.mat"
		bet2MNI="${DataPath}/${SUB}/${ses}/rest/FEAT.feat/reg/${SUB}_s${ses: -1}_bet2MNI.mat"
		preproc2MNI="${DataPath}/${SUB}/${ses}/rest/FEAT.feat/reg/${SUB}_s${ses: -1}_preproc2MNI.mat"
		

		# Register preprocessed data to BET image and create preproc2BET matrix (A_to_B)
		echo "flirt -in ${preproc} -ref ${bet} -omat ${preproc2BET}" 								>> job
		echo "chmod -R 770 ${preproc2BET}"  														>> job
		
		# Register BET image to MNI space and create bet2MNI matrix (B_to_C)
		echo "flirt -in ${bet} -ref ${MNIImage} -omat ${bet2MNI}" 										>> job
		echo "chmod -R 770 ${bet2MNI}"  															>> job
		
		# Combine matrices, used to register preproc to MNI (preproc_to_MNI)
		## omat = name of concatenated matrices (A_to_C), 
		## concat = two matrices to be concatenated (B_to_C A_to_B)
		echo "convert_xfm -omat ${preproc2MNI} -concat ${bet2MNI} ${preproc2BET}" 					>> job
		echo "chmod -R 770 ${preproc2MNI}"  														>> job
		
		echo "flirt -in ${preproc} -ref ${MNIImage} -out ${registered} -applyxfm -init ${preproc2MNI}"  	>> job
		echo "chmod -R 770 ${registered}*"  														>> job

		qsub job  
		rm job
	done
done
