function make_prePLS_datamat( batchfile )
% prepares sessiondata.mat file for PLS analysis	
%for compilation: /opt/matlab/R2014b/bin/mcc -m make_prePLS_datamat -a /home/mpib/LNDG/Naftali/data/analysis/PLS/tools/Pls

fprintf('Creating PLS_data_mat for %s \n', batchfile);

batch_plsgui(batchfile);

fprintf('done\n');						

end