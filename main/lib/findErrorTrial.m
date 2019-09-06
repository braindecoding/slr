function findErrorTrial(dirName)
%% detect error trials

%dirName = 'de_HU061030_V1V2_Ecc1to11_baseByRestPre_smlr_4RunOut/';
%dirName = 'de_HU071010_V1V2_Ecc1to11_baseByRestPre_smlr_4RunOut/';
%dirName = 'de_HU071010_V1V2_Ecc1to11_baseByRestPre_smlr_4RunOut_resol10';
%dirName = 'de_HU071010_V1V2_Ecc1to11_baseByRestPre_smlr_4RunOut_shuffle1/';
%dirName = 'de_HU061030_V1V2_Ecc1to11_baseByRestPre_smlrSelectedMean_4RunOut/';

%dirName = 'de_IN070706_V1V2_Ecc1to11_baseByRestPre_posEstGLM_4RunOut_voxNum1/';

dirInfo = dir(dirName);


for i=1:length(dirInfo)
  if dirInfo(3).isdir == 1
        continue
    end

    abnormalFlag = 0;

fname = dirInfo(i).name;
    idx = findstr(fname,'_RUNNING_INFO');

%    fprintf('%s\n',fname);

if dirInfo(i).isdir ~=1
try
    %            load([dirName '/' fname]);
catch
    abnormalFlag = 1;
end
end
    
    if ~isempty(idx)
        fname2 = fname(1:idx-1);
        if ~exist([dirName '/' fname2 '.mat'],'file');
            fprintf(['rm -f ' dirName '/' fname2 '_RUNNING_INFO.mat\n']);
        end

    end

    if abnormalFlag == 1;
        fprintf('----- File cannot be read !! -----\n');
        fprintf(['rm -f ' dirName '/' fname '\n']);
    end
end









