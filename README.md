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