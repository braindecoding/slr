function extractDecoder(basisTypeSet,areaROI,cvMode)

%% path setting
libLocalPath = ['../lib/'];
addpath(genpath(libLocalPath));


saveDirPostFix = '_decoder';

sbjId = 's1';
retinoId = 's1071119';
% areaROI = 'V1V2';

eccROI = 'Ecc1to11';

decoder = 'smlr';
%decoder = 'smlr_shuffle1';

resol = 'resol10';

trainRun = 1:20;

resultsDir = ['de_' sbjId '_' areaROI '_' eccROI '_baseByRestPre_' ...
                    decoder '_' retinoId 'ROI_' resol '_' cvMode]

%% main loop
for idxBasisType = 1:length(basisTypeSet)
    basisType  = basisTypeSet{idxBasisType};
	
    switch basisType
      case '1x1'
        labelsList = 1:100;
      case {'1x2','2x1'}
        labelsList = 1:90;
      case '2x2'
        labelsList = 1:81;
      otherwise
    end       
    
    switch cvMode
      case 'leave2'
        [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(trainRun,2,2);
      case 'leave1'
        [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(trainRun,0,2);
      case 'leave0'
        [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(trainRun,0,0);
    end

    labelsAll = []; labelsPreAll = []; labelsPreExpAll = [];
    for idxCv = 1:length(idxTrainRunSet)
        trainRunStr = idxTrainRunSetStr{idxCv};

        decoder = {};
        for idxLabel = labelsList
            fName = sprintf('%s/label%03d/%s_label%03d_train%s',basisType,idxLabel,basisType,idxLabel,trainRunStr);
            fprintf(['loading : ' fName ' ...\n']);
            try
                res = load([resultsDir '/' fName '.mat']);            
            catch
                keyboard
                fprintf(['ERROR: ' resultsDir '/' fName '.mat\n']);
            end
            decoder{idxLabel} = struct;
            decoder{idxLabel}.model = res.parm.model;

            if strcmp(res.parm.model, 'slr121a')
                decoder{idxLabel}.weight = res.resultsTr{1}.weight;
                decoder{idxLabel}.parm    = res.parm;
            end

            strEval = ['decoder{idxLabel}.' decoder{idxLabel}.model{:} ' = res.parm.' decoder{idxLabel}.model{:} ';'];
            eval(strEval);
            
            decoder{idxLabel}.xyz = res.resultsTr{1}.xyz;
        end

        basisMat = res.parm.basisConvertW;
        origData = resultsDir;
        if ~exist([resultsDir saveDirPostFix], 'dir')
            mkdir([resultsDir saveDirPostFix]);
        end
        save([resultsDir saveDirPostFix '/' basisType '_' trainRunStr], 'decoder', 'basisMat', 'origData');
    end
end

