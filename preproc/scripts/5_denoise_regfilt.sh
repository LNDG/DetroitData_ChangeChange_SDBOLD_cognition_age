#!/bin/bash

## Noise Component Rejection

# This will remove the ICA components which have been selected manually for rejection.

source preproc_config.sh

OutputStage="denoised"

# PBS Log Info
CurrentLog="${LogPath}/denoise"
if [ ! -d ${CurrentLog} ]; then mkdir ${CurrentLog}; chmod 770 ${CurrentLog}; fi

# Error Log
Error_Log="${CurrentLog}/denoise_error_summary.txt"; echo "" >> ${Error_Log}; chmod 770 ${Error_Log}

## Create string with all FEAT directories
# Loop over participants, sessions (if they exist) & runs
for SUB in ${SubjectID} ; do
	sessions=$(ls "${DataPath}/${SUB}/")

	for ses in ${sessions}
	do

		FuncImage="${SUB}_rest_s${ses: -1}_FEAT_filt_detrend"
		
		# functional image path
		FuncPath="${DataPath}/${SUB}/${ses}/rest"
		FuncName="${SUB}_s${ses: -1}"
		
		if [ ! -f ${FuncPath}/${FuncImage}.nii.gz ]; then
			echo "${FuncImage} not found"
			continue
		elif [ -f ${FuncPath}/${FuncImage}_${OutputStage}.nii.gz ]; then
			continue 
		fi
		
		# verify manual rejcomp file
		cd ${ScriptsPath}/rejcomps
		if [ ! -f ${FuncName}_rejcomps.txt ]; then
			echo "${FuncName}_rejcomps.txt does not exist" >> ${Error_Log}
			continue
		fi
		
		# Create hand_labels_noise.txt from manual rejcomp file required for filtering
		if [ -f ${FuncName}_rejcomps.txt ]; then
			echo  "${SUB} ${ses}: creating hand_labels_noise.txt"
			cp ${FuncName}_rejcomps.txt ${FuncPath}/FEAT.feat/hand_labels_noise.txt
		fi
		
		chmod -R 770 ${FuncPath}/FEAT.feat/hand_labels_noise.txt
		
		## Remove rejected components
		cd ${FuncPath}/FEAT.feat
		Training="hand_labels_noise.txt"
		Rejected=`cat ${Training} | tail -1`
		
		# Cluster job
		echo "#PBS -N denoise_${FuncName}" 			>> job # Job name 
		echo "#PBS -l walltime=1:00:00" 						>> job # Time until job is killed 
		echo "#PBS -l mem=2gb" 									>> job # Books 4gb RAM for the job 
		echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${CurrentLog}" 							>> job # Write (output) log to group log folder 
		echo "#PBS -e ${CurrentLog}" 							>> job # Write (error) log to group log folder 

		# Initialize FSL	
		echo "source /etc/fsl/5.0/fsl.sh"  >> job
				
		# Variables for denoising
	
		Preproc="${FuncPath}/${FuncImage}.nii.gz"									# Preprocessed data image
		Denoised="${FuncPath}/${FuncImage}_${OutputStage}.nii.gz"								# Denoised image
		Melodic="${FuncPath}/FEAT.feat/filtered_func_data.ica/melodic_mix"						# Location of ICA generated Melodic Mix
		
																# List of components to be removed
		
		# Run fsl_regfilt command
		echo "fsl_regfilt -i ${Preproc} -o ${Denoised} -d ${Melodic} -f \"${Rejected}\""  		>> job
		
		# Change permissions
		echo "chmod 770 ${Denoised}"  															>> job
		
		# Error Log
		echo "Difference=\`cmp ${Preproc} ${Denoised}\`" >> job
		echo "if [ -z \${Difference} ]; then echo 'Denoising did not change the preprocessing image: ${FuncImage}' >> ${Error_Log}; fi" >> job
		
		
		qsub job
		rm job
			
	done
done
