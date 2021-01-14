#!/bin/bash

# Perform detrending and filtering steps.

source preproc_config.sh

cd ${ScriptsPath}

# create log path
if [ ! -d ${LogPath}/detrend_filter ]; then
	mkdir -p ${LogPath}/detrend_filter
	chmod 770 ${LogPath}/detrend_filter
fi

for SUB in ${SubjectID}
	do
	    sessions=$(ls "${DataPath}/${SUB}/")
	
	    for ses in ${sessions}
	    do
			
			# Create job for cluster
	        echo "#PBS -N detrend_filter_${SUB}_${ses}" 				>> job # job name 
	        echo "#PBS -l walltime=2:00:00" 						>> job # time until job is killed 
	        echo "#PBS -l mem=4gb" 									>> job # books 10gb RAM for the job
	        echo "#PBS -o ${LogPath}/detrend_filter" 	>> job # write (error) log to log folder 
	        echo "#PBS -e ${LogPath}/detrend_filter" 	>> job 
	       	echo "#PBS -j oe"										>> job
	
	        echo "cd ${ScriptsPath}"      		>> job   # job output dir 
	
	        echo "./run_bandpass_filter_detrend.sh /opt/matlab/R2014b/ ${DataPath} ${SUB} ${ses: -1} ${HighpassFilterLowCutoff} ${LowpassFilterHighCutoff} ${FilterOrder} ${TR} ${PolyOrder}" >> job  
	
	        qsub job  # submit job
	        rm job # clean up temporary file 
	        
	
	done
done
 
 
