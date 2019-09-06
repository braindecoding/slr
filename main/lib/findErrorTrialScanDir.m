clear all


%basisList = {'1x1','1x2','2x1','2x2'};
%labelNum = [100 90 90 81];

%basisList = {'1x1','1x2','2x1'};
%labelNum = [100 90 90];

basisList = {'1x1'}
labelNum = [100];

%basisList = {'1x2'};
%labelNum = [90];

%basisList = {'1x2'};
%labelNum = [90];

%basisList = {'2x2'};
%labelNum = [81];


%sbjId = 'HU071010';
%sbjId = 'IN071012';
sbjId = 's1';

%retinoId = 'HU071119';
%retinoId = 'IN071119';
retinoId = 's1071119';

%areaROI = 'AllArea';
areaROI = 'V1V2';
%areaROI = 'V1';
%areaROI = 'V2';
%areaROI = 'V3';
%areaROI = 'V4';

eccROI = 'Ecc1to11';

decoder = 'smlr';
%decoder = 'posEstGLM2_voxNum1';
%decoder = 'posEstGLM2_FDR005';
%decoder = 'svm_multi';
%decoder = 'lda_voxNum300';
%decoder = 'smlr_shuffle1';

%filterType = '_hpfConst128';
filterType = '';

resol = 'resol10';

cvMode = 'localLeave2_imgLeave2';
%cvMode = 'localLeave0_imgLeave2';
%cvMode = 'localLeave0_imgLeave0';

dirName = ['de_' sbjId '_' areaROI '_' eccROI filterType '_baseByRestPre_' ...
           decoder '_' retinoId 'ROI_' resol '_' cvMode]


switch cvMode
  case 'localLeave2_imgLeave2'
    fileNum = 90;
  case 'localLeave0_imgLeave2'
    fileNum = 20;
  case 'localLeave0_imgLeave0'
    fileNum = 2;
  otherwise
    error('invalid cvMode')
end


for basisIdx = 1:length(basisList)

    for idx = 1:labelNum(basisIdx)
 
        str = sprintf('%s/%s/label%03d',dirName, basisList{basisIdx},idx); 
     
        d=dir([str '/*mat']);


        if size(d,1) ~= fileNum
            fprintf('insufficient file num in basis %s, label%03d\n', basisList{basisIdx},idx);
        end
  
        findErrorTrial(str);
        
    end
end



       
       
       
       
       
       
       
       
