# visReconRoot
miyawaki dataset
## How to use miyawaki dataset
Open matlab command and make sure structure directory like HowToUse.pdf guide and put into Matlab folder,
after that run:
sh```
addpath('lib/spm5/','main/lib/','lib/SLR1.2.1alpha/','lib/BDTB-1.2.2/')
genpath
```
change dir to to s1_fmri_mat folder in data folder and load the mat file
sh```
load s1_fmri_roi-1to2mm_Th1_fromAna_s1071119ROI_resol10_v6.mat 
```
there is D as struct data, inside D :
label : stimulus image