#!/bin/bash
# 21.11.18 Creating quality check reports by Alex

# run on cluster using these specs:
#
#PBS -N QC 	  # Job name 
#PBS -l walltime=12:00:00 						  # Time until job is killed 
#PBS -l mem=4gb 								  # Books 10gb RAM for the job 
#PBS -m n										  # Email notification on abort/end, use 'n' for no notification 
#PBS -o /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (output) log to group log folder 
#PBS -e /home/mpib/LNDG/EyeMem/study_information/B_logs/BET_QC 							  # Write (error) log to group log folder 

source ../preproc_config.sh

#Output path must be an empty folder!
OutPath_task="${DataPath}/QC"

if [ ! -d ${OutPath_task} ]; then mkdir -p ${OutPath_task}; chmod 770 ${OutPath_task}; fi

# load FSL
FSLDIR=/home/mpib/LNDG/FSL/fsl-5.0.11
. ${FSLDIR}/etc/fslconf/fsl.sh      
PATH=${FSLDIR}/bin:${PATH}         
export FSLDIR PATH

#---------------------------- QC step FD ---------------------------

FD_Outpath="${OutPath_task}/FD"

sessions="session1 session2"

if [ ! -d ${FD_Outpath} ]; then mkdir -p ${FD_Outpath}; chmod 770 ${FD_Outpath}; fi
	
cd ${FD_Outpath}

for SUB in ${SubjectID}; do
	
	for ses in ${sessions}; do
		
		# post preproc
		func_img="${SUB}_rest_s${ses: -1}_FEAT_filt_detrend_denoised_remean_MNI3mm"
		
		func_dir="${DataPath}/${SUB}/session${ses: -1}/rest"
		
		fsl_motion_outliers -i ${func_dir}/${func_img}.nii.gz -o ${FD_Outpath}/${func_img}_mat.txt -s ${FD_Outpath}/${func_img}_FD.txt --fd --thresh=1
		
		FD_sub=`cat ${FD_Outpath}/${func_img}_FD.txt`
		FD_sub_max=`echo "${FD_sub[*]}" | sort -nr | head -n1`
		echo "${SUB}	${ses}	${FD_sub_max}" >> FD_max_all_sub_post.txt
		
		# pre preproc
		func_img_raw="${SUB}_rest_s${ses: -1}"
		
		func_dir="${DataPath}/${SUB}/session${ses: -1}/rest"
		
		fsl_motion_outliers -i ${func_dir}/${func_img_raw}.nii.gz -o ${FD_Outpath}/${func_img_raw}_mat.txt -s ${FD_Outpath}/${func_img_raw}_FD.txt --fd --thresh=1 --dummy=${DeleteVolumes}
		
		FD_sub_raw=`cat ${FD_Outpath}/${func_img_raw}_FD.txt`
		FD_sub_max_raw=`echo "${FD_sub_raw[*]}" | sort -nr | head -n1`
		echo "${SUB}	${ses}	${FD_sub_max_raw}" >> FD_max_all_sub_pre.txt
		
	done
done

#---------------------------- QC step epi2MNI ---------------------------
# creates a gif of the MNI template and mean filtered func image registered to MNI space 

epi2MNI_Outpath="${OutPath_task}/epi2MNI"

if [ ! -d ${epi2MNI_Outpath} ]; then mkdir -p ${epi2MNI_Outpath}; chmod 770 ${epi2MNI_Outpath}; fi
	
cd ${epi2MNI_Outpath}

# prepare report index

echo "<HTML><TITLE>epi2MNI</TITLE><BODY BGCOLOR=\"#aaaaff\">" >> epi2standard_report.html

# create MNI template overlay

cp ${MNIImage}.nii.gz ${epi2MNI_Outpath}/MNI_template.nii.gz

slicesdir -p ${epi2MNI_Outpath}/MNI_template ${epi2MNI_Outpath}/MNI_template

cd slicesdir

pngappend grota.png + grotb.png + grotc.png + grotd.png + grote.png + grotf.png + grotg.png + groth.png + groti.png movie_MNI_template.gif

cp movie_MNI_template.gif ../movie_MNI_template.gif

cd ${epi2MNI_Outpath}

rm -r slicesdir

for SUB in ${SubjectID}; do
	
	sessions=$(ls "${DataPath}/${SUB}/")
	
	for ses in ${sessions}; do
			
			preproc_dir="${DataPath}/${SUB}/session${ses: -1}/rest/FEAT.feat"
			
			mean_func="${SUB}_s${ses: -1}_mean_func"
			
			# check if file exists
			if [ ! -f ${preproc_dir}/mean_func.nii.gz ]; then
				continue
			fi
			
			# prepare epi overlay
			cp ${preproc_dir}/mean_func.nii.gz ${epi2MNI_Outpath}/${mean_func}.nii.gz
    	
			flirt -in ${mean_func} -ref ${MNIImage} -applyxfm -init ${preproc_dir}/reg/example_func2standard.mat -out ${mean_func}2standard
			
			rm ${mean_func}.nii.gz
			
			slicesdir -p ${epi2MNI_Outpath}/MNI_template ${mean_func}2standard
			
			cd slicesdir
			
			pngappend grota.png + grotb.png + grotc.png + grotd.png + grote.png + grotf.png + grotg.png + groth.png + groti.png movie_${SUB}_s${ses: -1}.gif
			
			cp movie_${SUB}_s${ses: -1}.gif ../movie_${SUB}_s${ses: -1}.gif
			
			cd ${epi2MNI_Outpath}
			
			rm -r slicesdir
			rm ${mean_func}2standard.nii.gz
			
			whirlgif -o epi2standard_${SUB}_s${ses: -1}.gif -time 50 -loop 0 movie_${SUB}_s${ses: -1}.gif movie_MNI_template.gif 2>&1
			
			rm movie_${SUB}_s${ses: -1}.gif
			
			# add gif to report
			
			echo "<a href=\"epi2standard_${SUB}_s${ses: -1}.gif\"><img src=\"epi2standard_${SUB}_s${ses: -1}.gif\" WIDTH=1000 > ${SUB}_s${ses: -1}</a><br>" >> epi2standard_report.html
    	
	done
done

# finalise
echo "</BODY></HTML>" >> epi2standard_report.html

rm MNI_template.nii.gz
rm movie_MNI_template.gif

#------------------------ QC step func2anat -------------------------------------------


epi2anat_Outpath="${OutPath_task}/epi2anat"

if [ ! -d ${epi2anat_Outpath} ]; then mkdir -p ${epi2anat_Outpath}; chmod 770 ${epi2anat_Outpath}; fi

cd ${epi2anat_Outpath}

# prepare report index
echo "<HTML><TITLE>epi2anat</TITLE><BODY BGCOLOR=\"#aaaaff\">" >> epi2anat_report.html

for SUB in ${SubjectID}; do
	sessions=$(ls "${DataPath}/${SUB}/")
	
	for ses in ${sessions}; do

			org_file="${DataPath}/${SUB}/session${ses: -1}/rest/FEAT.feat/reg/example_func2highres.png"
			
			if [ ! -f ${org_file} ]; then
				continue
			fi
			
			cp ${org_file} ${epi2anat_Outpath}/${SUB}_s${ses: -1}_epi2anat.png
			
			# add png to report
			echo "<a href=\"${SUB}_s${ses: -1}_epi2anat.png\"><img src=\"${SUB}_s${ses: -1}_epi2anat.png\" WIDTH=1000 > ${SUB}_s${ses: -1}</a><br>" >> epi2anat_report.html
			
	done
done

# finalise
echo "</BODY></HTML>" >> epi2anat_report.html