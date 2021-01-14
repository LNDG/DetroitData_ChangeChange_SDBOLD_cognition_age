function bandpass_filter_detrend( DATAPATH, subjID, session, LowCutoff, HighCutoff, filtorder, TR, k)
% This function bandpass filters unfiltered nifti files with a butterworth
% filter. And detrend to k order.

% for compilation: /opt/matlab/R2014b/bin/mcc -m bandpass_filter_detrend -a /home/mpib/LNDG/toolboxes/NIfTI_20140122 -a /home/mpib/LNDG/toolboxes/spm_detrend -a /home/mpib/LNDG/toolboxes/preprocessing_tools

%% Variables

LowCutoff=str2num(LowCutoff);
HighCutoff=str2num(HighCutoff);
filtorder=str2num(filtorder);
TR=str2num(TR);
k=str2num(k);

DATAPATH = fullfile(DATAPATH, subjID, ['session' session]);


%% check if session 2 is available

if ~exist (DATAPATH,'file') == 7
    exit;
end
        
%% load nifti

img = load_untouch_nii(fullfile(DATAPATH,'rest','FEAT.feat','filtered_func_data.nii.gz'));
nii = double(reshape(img.img, [], img.hdr.dime.dim(5)));


%% filter
% parameters, for detail see help NoseGenerator.m
samplingrate = 1/TR;         %in Hz, TR=2.5s, FS=1/TR=2.5

for i = 1:size(nii,1)
    
    [B,A] = butter(filtorder,LowCutoff/(samplingrate/2),'high'); 
    nii(i,:)  = filtfilt(B,A,nii(i,:)); clear A B;

    [B,A] = butter(filtorder,HighCutoff/(samplingrate/2),'low');
    nii(i,:)  = filtfilt(B,A,nii(i,:)); clear A B
    
end

disp ([subjID, ': filtering done']);


%% Detrend
[ nii ] = S_detrend_data2D( nii, k );

disp ([subjID, ': detrending done']);


%% save file
SAVEPATH=fullfile(DATAPATH,'rest', [subjID,'_rest_s', session, '_FEAT_filt_detrend.nii.gz']);

img.img = nii;
save_untouch_nii (img, SAVEPATH)
disp (['saved as: ', SAVEPATH])

end

