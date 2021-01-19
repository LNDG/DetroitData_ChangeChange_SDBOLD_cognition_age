# DetroitData_ChangeChange_SDBOLD_cognition_age
Code to reproduce results reported in "Losses in brain signal variability and functional integration are coupled with declines in cognitive performance over two years" by Douglas D. Garrett, Alexander Skowron, Steffen Wiegert, Janne Adolf, Cheryl L. Dahle, Ulman Lindenberger, & Naftali Raz [Paper DOI]. Please reference this paper if you intend to to reuse this code.

## Code execution
All scripts should be executed in numerical or alphabetical order as indicated. Util folders contain helper functions (paths may need to be adjusted in scripts).

**Preprocessing**
Scripts to reproduce our preprocesing pipeline can be found in the preproc folder. Preprocessing was performed with FSL 5 and some custom matlab functions. All steps were performed on the high computing cluster "tardis" at the MPI for Human Development Berlin. Therefore a compiled version of the relevant matlab scripts are provided. Settings of key variables for preprocessing can be found (and adjusted if desired) in preproc_config.sh. Optional quality checks can be performed using the scripts in 7_QC. Components that were manually rejected after inspecting ICA results can be found in the rejcomps folder. Note that IC numbering can be shuffled when rerunning the scripts. Original IC reports that rejection was based on can be provided by the first author upon reasonable request. Also note that MNI standard images are not included (please refer to the paper).

**PLS analyses**
Scripts to reproduce all PLS results can be found in the analysis/PLS folder. These scripts prepare subjects' sessiondata.mat files, run PLS analyses, and plot figures reported in the paper. Note that surface and axial brain plots were produced manually in FSL 5 and the Human Connectome workbench. PLS template files required to run PLS analyses are saved in the SDBOLD output folder since they need to be saved in the same folder as the sessiondata.mat files. Note that in order to run scripts in J_Dim_USC_VSC_analysis you first need to run the scripts for the dimensionality analysis (see below). Also note that MNI standard images and masks are not included (please refer to the paper).

**Dimensionality analyses**
Scripts to extract PC dimensionality in specified brain masks can be found in the Dimensionality folder.

## Required toolboxes
Toolboxes required to execute all code:

* PLS toolbox for matab found [here](https://www.rotman-baycrest.on.ca/index.php?section=84 "Title")
* FSL found [here](https://www.rotman-baycrest.on.ca/index.php?section=84 "Title")
* Nifti toolbox for matlab found [here](https://de.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image "Title")
* Matlab statistics and machine learning toolbox found [her](https://de.mathworks.com/products/statistics.html "Title")