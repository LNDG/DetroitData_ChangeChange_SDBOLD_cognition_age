#!/bin/bash

# perform ICA component extraction for manual denoising

source preproc_config.sh

# create log folder
if [ ! -d ${LogPath}/ICA ]; then
	mkdir -p ${LogPath}/ICA
	chmod 770 ${LogPath}/ICA
fi

for SUB in ${SubjectID}; do
	
    sessions=$(ls "${DataPath}/${SUB}/")

    for ses in ${sessions}; do
		
		# Name of functional image.
		FuncImage="${SUB}_rest_s${ses: -1}_FEAT_filt_detrend"
		
		# Name of anatomical images to be used.
		AnatImage="${SUB}_anat_s${ses: -1}_brain"											# Brain extracted anatomical image
		
		# Path to the anatomical and functional image folders.
		AnatPath="${DataPath}/${SUB}/${ses}/anat"					# Path for anatomical image
		FuncPath="${DataPath}/${SUB}/${ses}/rest"
		
		# Create job for cluster
		echo "#PBS -N ICA_${SUB}_${ses}"										>> job 			# job name
		echo "#PBS -l walltime=12:0:0" 											>> job			# time until job is killed
		echo "#PBS -l mem=2gb"	 												>> job			# books 8gb RAM for the job
		echo "#PBS -o ${LogPath}/ICA" 						>> job			# write (error) log to log folder
		echo "#PBS -e ${LogPath}/ICA" 						>> job
		echo "#PBS -j oe"														>> job 
		
		echo ". /etc/fsl/5.0/fsl.sh" 											>> job			# set fsl environment
		
		
		echo "cd ${DataPath}/${SUB}/${ses}/rest/" 							>> job 			# job output dir
		
		# Variables for background image
		Preproc="${FuncPath}/${FuncImage}.nii.gz"							# Preprocessed data image
		BET="${AnatPath}/${AnatImage}.nii.gz"											# Brain extracted T1 image
		ANAT2FUNC="${FuncPath}/FEAT.feat/anat2func.nii.gz"										# Background image for ICA
		
		# Anat2func as background image for ICA
		echo "flirt -in ${BET} -ref ${Preproc} -applyxfm -init ${FuncPath}/FEAT.feat/reg/highres2example_func.mat -out ${ANAT2FUNC}" >> job												
		
		echo "melodic -i ${FuncPath}/${SUB}_rest_s${ses: -1}_FEAT_filt_detrend -o ${FuncPath}/FEAT.feat/filtered_func_data.ica --dimest=${dimestVALUE} --nobet --bgthreshold=${bgthresholdVALUE} --tr=${TR} --report --guireport=${DataPath}/${SUB}/${ses}/rest/FEAT.feat/filtered_func_data.ica/report.html -d ${dimensionalityVALUE} --mmthresh=${mmthreshVALUE} --bgimage=${ANAT2FUNC} ${AdditionalParameters}"    		>> job

		qsub job # submit job
		rm job # clean up temporary file

	done
done
