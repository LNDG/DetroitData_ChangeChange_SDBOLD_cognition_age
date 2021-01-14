#!/bin/bash

# perform brain extraction on anatomical images using FSL bet

source preproc_config.sh

cd ${ScriptsPath}

# create log path and error log
if [ ! -d ${LogPath}/bet ]; then
	mkdir -p ${LogPath}/bet
	chmod 770 ${LogPath}/bet
fi

# Loop over participants & sessions (if they exist)
for SUB in ${SubjectID} ; do
	
	sessions=$(ls "${DataPath}/${SUB}/")
	
	for ses in ${sessions}; do
		
		# Path to the anatomical image folder.
		AnatPath="${DataPath}/${SUB}/session${ses: -1}/anat"		# Path for anatomical image	
		# Name of anatomical image to be used.
		AnatImage="${SUB}_anat_s${ses: -1}" 									# Original anatomical image, no extraction performed
		# ANTs output name
		ANTsName="${SUB}_anat_s${ses: -1}_brain"
		# Start log
		StartLog="${AnatPath}/${ANTsName}started.txt"
		# Error message if ANTs did not produce the expected output
		CrashLog="${AnatPath}/${ANTsName}failed.txt"
		
		# If anat files have not been properly renamed.
		
		if [ ! -f ${AnatPath}/${AnatImage}.nii.gz ]; then   		# Verifies if the anatomical image exists. If it doesn't, the for loop stops here and continues with the next item. 
			echo "No mprage: ${SUB} cannot be processed"
			continue
		elif [ -f ${AnatPath}/${ANTsName}.nii.gz ]; then 	# Verify if ANTs output was already created
			continue
		elif [ ! -f ${AnatPath}/${ANTsName}.nii.gz ]; then
			if [ -f ${CrashLog} ]; then 							# Verify if crash log exists, if so, delete intermediary ANTs files and re-run ANTs.
				echo "ANTs failed for ${SUB} s${ses: -1}. Check folder."
				#rm -rf ${AnatPath}/temp
				#rm ${AnatPath}/${CrashLog}
				continue	
			elif [ -f ${StartLog} ]; then 							# Verify if ANTs job started. Could be problematic if job did not finish.
				continue
			fi
		fi
		
		# ANTs settings
		
		KeepTemporaryFiles="0" # don't save temporary files
		ImageDimension="3" # 3d
		
		# ANTs-specific file paths
		
		#OASIS template
		TemplatePath="${SharedFilesPath}/ANTS/MICCAI2012-Multi-Atlas-Challenge-Data" 					# Directory for ANTs template to be used (Oasis template)
		TemplateImage="${TemplatePath}/T_template0.nii.gz" 											# ANTs bet template image (e.g. averaged anatomical image) - mandatory
		ProbabilityImage="${TemplatePath}/T_template0_BrainCerebellumProbabilityMask.nii.gz" 		# ANTs bet brain probability image of the template image - mandatory
		RegistrationMask="${TemplatePath}/T_template0_BrainCerebellumRegistrationMask.nii.gz" 		# ANTs bet brain mask of the template image (i.e. rough binary mask of brain location) - optional (recommended)
		
		
		# Cluster job
		echo "#PBS -N ANTs_${SUB}_s${ses: -1}" 	>> job # Job name 
		echo "#PBS -l walltime=12:00:00" 						>> job # Time until job is killed 
		echo "#PBS -l mem=8gb" 								>> job # Books 10gb RAM for the job 
		echo "#PBS -m n" 										>> job # Email notification on abort/end, use 'n' for no notification 
		echo "#PBS -o ${LogPath}/bet" 							>> job # Write (output) log to group log folder 
		echo "#PBS -e ${LogPath}/bet" 							>> job # Write (error) log to group log folder 
    	
		echo "sleep $(( RANDOM % 120 ))"						>> job # Sleep for a random period between 1-60 seconds, used to avoid interference when running antsBrainExtraction.sh
		
		echo ". /etc/fsl/5.0/fsl.sh" >> job
		
    	echo "module load ants/2.2.0" 							>> job
		
		echo "cd ${AnatPath}"		>> job
		echo "echo 'ANTs will start now' >> ${StartLog}"		>> job
		
		echo "mkdir ${AnatPath}/temp"							>> job
		echo "cd ${AnatPath}/temp" >> job
		
		echo "cp ${AnatPath}/${AnatImage}.nii.gz ${AnatPath}/temp/${AnatImage}.nii.gz" >> job
		
		# Perform Brain Extraction
		
		echo -n "antsBrainExtraction.sh -d ${ImageDimension} -a ${AnatPath}/temp/${AnatImage}.nii.gz -e ${TemplateImage} " 	>> job
		echo  "-m ${ProbabilityImage} -f ${RegistrationMask} -k ${KeepTemporaryFiles} -q 1 -o ${AnatPath}/temp/${ANTsName}" 					>> job
		
		echo "cp ${AnatPath}/temp/${ANTsName}BrainExtractionBrain.nii.gz ${AnatPath}/${ANTsName}.nii.gz" >> job
		
		echo "cd ${AnatPath}" >> job
		
		echo "rm -r ${AnatPath}/temp" >> job # clean up
		
		echo "rm ${StartLog}" >> job
		
		# If the final ANTs output isn't created, write a text file to be used as a verification of the output outcome.
		echo "if [ ! -f ${AnatPath}/${ANTsName}.nii.gz ]; then echo 'BrainExtractionBrain file was not produced.' >> ${CrashLog}; exit; fi" >> job

		qsub job
		rm job
	done
done

