function add_mean( BASEPATH, subjID, ses )
% this function re-adds mean to preprocessed images
%
% for compilation: /opt/matlab/R2014b/bin/mcc -m add_mean -a /home/mpib/LNDG/toolboxes/NIfTI_20140122

%% Variables

DATAPATH = fullfile(BASEPATH, subjID, ['session', ses], 'rest');

%%
%load nifti
    pre = load_untouch_nii (fullfile(DATAPATH, 'FEAT.feat', 'filtered_func_data.nii.gz'));
    post_nii = load_untouch_nii (fullfile(DATAPATH, [subjID, '_rest_s', ses, '_FEAT_filt_detrend_denoised.nii.gz']));


    pre = reshape(pre.img, [], pre.hdr.dime.dim(5));
    post = reshape(post_nii.img, [], post_nii.hdr.dime.dim(5));

    %calculate and re-add mean
    for i = 1:size(pre,1)
        
        average=mean(pre(i,:));
        post(i,:)=post(i,:)+average;

    end


    disp ([subjID, ' session', ses ': adding mean done']);

    %% save file
    post = reshape(post, post_nii.hdr.dime.dim(2),post_nii.hdr.dime.dim(3),post_nii.hdr.dime.dim(4),post_nii.hdr.dime.dim(5));
    post_nii.img=post;
    
    SAVEPATH = fullfile(DATAPATH, [subjID, '_rest_s', ses, '_FEAT_filt_detrend_denoised_remean.nii.gz']);
    save_untouch_nii (post_nii, SAVEPATH)
    disp (['saved as: ', SAVEPATH])

end