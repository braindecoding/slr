setpath;loadMat
load('parm.mat');load('Davg.mat')
cd lib/BDTB-1.2.2/;addpath_bdtb;cd ..;cd ..;
procs1={'normByBaseline'};[Dnorm,unuse] = procSwitch(Davg,parm,procs1);