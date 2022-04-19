# visReconRoot
miyawaki dataset 
http://brainliner.jp/data/brainliner/Visual_Image_Reconstruction
## How to use miyawaki dataset
Open matlab command and make sure structure directory like HowToUse.pdf guide and put into Matlab folder,
after that run:
1. setpath
    run it after open matlab and set work folder to braindecoding
2. createMat 
    just run once, to generate mat file from ANALYZE file
    file location : main\data\s1_fmri_mat
3. loadMat
    load file in folder main\data\s1_fmri_mat
4. generateFigures 
    to generate all figure presenting to subject under redording
4. runrandom
    to get one random figure
5. runshape
    to get one shape figure

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