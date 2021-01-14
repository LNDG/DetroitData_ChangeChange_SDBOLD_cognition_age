#!/bin/bash

# run FSL FEAT

source preproc_config.sh

cd ${DataPath}

# create log path
if [ ! -d ${LogPath}/feat ]; then
	mkdir -p ${LogPath}/feat
	chmod 770 ${LogPath}/feat
fi

# Substitute subject specific information into FEAT template
for SUB in ${SubjectID}; do

		sessions=$(ls "${DataPath}/${SUB}/")

		for ses in ${sessions}
		do
			
			# Subject FUNC image
			FuncImage="${SUB}_rest_s${ses: -1}"
			FuncPath="${DataPath}/${SUB}/${ses}/rest"
			
			# Subject ANAT Image
			AnatImage="${SUB}_anat_s${ses: -1}_brain"
			AnatPath="${DataPath}/${SUB}/${ses}/anat"
			
			# create a designfile for each SUB and adjust name and paths
			cp "${ScriptsPath}/FEAT_template.fsf" "${DataPath}/${SUB}/${ses}/rest/${FuncImage}.fsf"
			
			cd ${FuncPath}
			
			## This will replace the dummy code with the appropriate image, study, subject, session & run specific information.
				# The 'g' option will replace all instances of the dummy code with the required variable.
				# As a side note, we're using the '|' character so as to avoid issues when replacing strings which include slashes.
			
			# Primary Directories	
			sed  -i 's|dummyFEAT|'${FuncPath}/FEAT.feat'|g' ${FuncImage}.fsf
			sed  -i 's|dummyOriginal|'${FuncPath}/${FuncImage}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyAnatomical|'${AnatPath}/${AnatImage}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyStandard|'${MNIImage}'|g' ${FuncImage}.fsf
			# Primary Parameters
			sed  -i 's|dummyToggleMCFLIRT|'${ToggleMCFLIRT}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyBETFunc|'${BETFunc}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyTR|'${TR}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyTotalVolumes|'${TotalVolumes}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyDeleteVolumes|'${DeleteVolumes}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyHighpassFEAT|'${HighpassFEAT}'|g' ${FuncImage}.fsf
	        sed  -i 's|dummySmoothingKernel|'${SmoothingKernel}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyRegisterStructDOF|'${RegisterStructDOF}'|g' ${FuncImage}.fsf
			# Secondary Parameters. Not usually used.
				# Nonlinear Registration
			sed  -i 's|dummyNonLinearReg|'${NonLinearReg}'|g' ${FuncImage}.fsf
	        sed  -i 's|dummyNonLinearWarp|'${NonLinearWarp}'|g' ${FuncImage}.fsf
				# B0 unwarping
			if [ "${Unwarping}" == "1" ]; then
				FieldRad=""
				FieldMapBrain=""
			else FieldRad="Unused"; FieldMapBrain="Unused"; fi 
			sed  -i 's|dummyUnwarping|'${Unwarping}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyFieldRad|'${FieldRad}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyFieldMapBrain|'${FieldMapBrain}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyEpiSpacing|'${EpiSpacing}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyEpiTE|'${EpiTE}'|g' ${FuncImage}.fsf
			sed  -i 's|dummyUnwarpDir|'${UnwarpDir}'|g' ${FuncImage}.fsf
			sed  -i 's|dummySignalLossThresh|'${SignalLossThresh}'|g' ${FuncImage}.fsf
				# Other Parameters
		    sed  -i 's|dummyIntensityNormalization|'${IntensityNormalization}'|g' ${FuncImage}.fsf
			sed  -i 's|dummySliceTimingCorrection|'${SliceTimingCorrection}'|g' ${FuncImage}.fsf
			
			echo "${SUB} ${ses} FEAT design file prepared"
		done

done

cd ${ScriptsPath}

# create and submit job to cluster
for SUB in ${SubjectID}; do
	
		sessions=$(ls "${DataPath}/${SUB}/")

		for ses in ${sessions}; do

			echo "#PBS -N FEAT_${SUB}_${ses}" 						>> job # job name
			echo "#PBS -l walltime=12:00:0" 								>> job # time until job is killed
			echo "#PBS -l mem=4gb" 										>> job # books 10gb RAM for the job --> 1 CPU hat normalerweise 4gb
			echo "#PBS -o ${LogPath}/feat" 		>> job # write (error) log to log folder
			echo "#PBS -e ${LogPath}/feat" 		>> job
			echo "#PBS -j oe"											>> job 
			echo ". /etc/fsl/5.0/fsl.sh"													>> job 	 # set fsl environment
			echo "feat ${DataPath}/${SUB}/${ses}/rest/${SUB}_rest_s${ses: -1}.fsf" 		>> job

			qsub job # submit job
			rm job # clean up temporary file
			
		done

done
