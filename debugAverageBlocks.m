setpath;
load Dshift.mat;
cd lib/BDTB-1.2.2/;addpath_bdtb;
procs1={'averageBlocks'};[Davg,unuse] = procSwitch(Dshift,parm,procs1);


%% detail di dalam fungsinya
target_labels = getFieldDef(parm,'target_labels',unique(Dshift.label)); % 465x1 urut 1 kolom 0-464
