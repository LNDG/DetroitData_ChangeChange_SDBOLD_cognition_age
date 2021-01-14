#!/bin/bash
# 21.11.18 Creating quality check reports by Alex

source ../preproc_config.sh

#Output path must be an empty folder!
OutPath_anat="${DataPath}/QC/ANTs_bet"

if [ ! -d ${OutPath_anat} ]; then mkdir -p ${OutPath_anat}; chmod 770 ${OutPath_anat}; fi

# load FSL

FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

cd ${ScriptsPath}

#------------- QC step anat -------------------
# T1
cd ${OutPath_anat}
	
#cycle over subjects
for SUB in ${SubjectID}; do
	
	sessions=$(ls "${DataPath}/${SUB}/")
	
	for ses in ${sessions}; do
 		
 	# Path to the anatomical image folder.
 	AnatPath="${DataPath}/${SUB}/session${ses: -1}/anat"		# Path for anatomical image	
 	# Name of anatomical image to be used.
 	AnatImage="${SUB}_anat_s${ses: -1}" 									# Original anatomical image, no extraction performed
	# ANTs output name
	ANTsName="${SUB}_anat_s${ses: -1}_brain"
	
	# raw T1
 	T1=${AnatPath}/${AnatImage}.nii.gz
 	
	# Brain extracted T1 (FSL bet output)
 	T1_bet=${AnatPath}/${ANTsName}.nii.gz	 
 	
	# overlay of brain extraction
 	overlay 1 1 ${T1} -a ${T1_bet} 1 10 ${OutPath_anat}/${SUB}_anat_s${ses: -1}_bet_overlay.nii.gz 
 
	done
done

overlays=`ls *anat_s?_bet_overlay.nii.gz`	 

#create report
slicesdir ${overlays}

#delete intermediate niftis
rm ${overlays}	
 
#clean up
cd ${OutPath_anat}/slicesdir

overlays_png=`ls *anat_s?_bet_overlay.png`
mv ${overlays_png} ${OutPath_anat}

cd ${OutPath_anat}

mv ${OutPath_anat}/slicesdir/index.html ${OutPath_anat}/index.html
rm -r ${OutPath_anat}/slicesdir