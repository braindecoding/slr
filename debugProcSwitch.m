load('parm.mat')
cd lib/BDTB-1.2.2/;addpath_bdtb;cd ..;cd ..;
procs1 = {'fmri_selectRoi'; 
          'reduceOutliers'; 
          'detrend_bdtb'; 
          'shiftData'; 
          'averageBlocks'; 
          'normByBaseline'};
%%%%proc 1
procs1={'fmri_selectRoi'};[Dset,unuse] = procSwitch(D,parm,procs1);
%%%%proc 2
procs1={'reduceOutliers'};[Dred,unuse] = procSwitch(Dset,parm,procs1);
%%%%proc 3
procs1={'detrend_bdtb'};[Dtrend,unuse] = procSwitch(Dred,parm,procs1);
%%%%proc 4
procs1={'shiftData'};[Dshift,unuse] = procSwitch(Dtrend,parm,procs1);
%%%%proc 5
procs1={'averageBlocks'};[Davg,unuse] = procSwitch(Dshift,parm,procs1);
%%%%proc 6
procs1={'normByBaseline'};[Dnorm,unuse] = procSwitch(Davg,parm,procs1);
