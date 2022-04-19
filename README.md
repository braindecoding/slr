# visReconRoot
miyawaki dataset 
http://brainliner.jp/data/brainliner/Visual_Image_Reconstruction
## How to use miyawaki dataset
Open matlab command and make sure structure directory like HowToUse.pdf guide and put into Matlab folder,
after that run:
### setpath
    run it after open matlab and set work folder to braindecoding
### createMat 
    just run once, to generate mat file from ANALYZE file
    make sure there is data in folder :
    main\data\s1_stimulusData
    main\data\s1_resliced
    main\data\s1_ROI
    file geerate location : main\data\s1_fmri_mat
### loadMat
    load file in folder main\data\s1_fmri_mat
### generateFigures 
    to generate all figure presenting to subject under redording
    file location : main\data\s1_figures
### runrandom
    to get one random figure
### runshape
    to get one shape figure
### training decoder model for local spatial
    run setpath
    start parallel pool
    go to main\reconstruction
    run command : trainLocalDecoder('s1_s1071119',{'1x1'},'V1','leave0',0)
    output file : de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_1x1_preprocessed.mat
    output folder : main\reconstruction\de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0
    each label has two file .mat and RUNNING_INFO
### compiling training model to a one file
    run setpath
    run loadMat
    start parallel pool
    go to main\reconstruction
    run command : extractDecoder({'1x1'},'V1','leave0')
    output folder : de_s1_V1_Ecc1to11_baseByRestPre_smlr_s1071119ROI_resol10_leave0_decoder
    output file in folder : 1x1_1--2--3--4--5--6--7--8--9-10-11-12-13-14-15-16-17-18-19-20.mat
### Learning of combination coefficients for minimiza error
    run setpath
    run loadMat
    goto : main\reconstruction\imgRecon
    run command : calCombCoef_figRecon_smlr('1x1','no_opt','V1')
    

## Requirements
1. Parallel Pool
2. Optimization Toolbox(to support slr)


## Running On Matlab 2019a
You migh meet error :
Warning: The quasi-newton algorithm does not use analytic Hessian. Hessian flag in
options will be ignored (supplied Hessian will not be used).

solution is modifiing slr_learning and smlr_learning in SLR1.2.1alpha line 98, in optimset by add parameter 'Algorithm','trust-region'

from :
```
option = optimset('Gradobj','on','Hessian','on',...
       'MaxIter', WMaxIter, 'Display', WDisplay);
```
to:
```
   option = optimset('Gradobj','on','Hessian','on',...
       'MaxIter', WMaxIter, 'Display', WDisplay,'Algorithm','trust-region','UseParallel',true);
```

'UseParallel',true : is optional if u want to use parallel computing by running parpool command at first.

or you just use modif of slr121alpha from repository:
https://github.com/awangga/SOLR