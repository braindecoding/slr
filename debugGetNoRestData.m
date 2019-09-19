setpath;
loadMat;
disp(D);
runIdxList=[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
[smpl, label, runIdxForSmpl, mskInOrigData] = getNoRestData(D, runIdxList);
disp(D);
%idxTrainRun<=32

%mengembalikan data yang hanya ada label gambar stimulusnya, menghilangkan
%data antara atau transisi atau istirahat tanpa stimulus atau blank tanpa
%stimulus