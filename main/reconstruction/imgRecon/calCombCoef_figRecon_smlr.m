function calCombCoef_figRecon_smlr(decoCombType,optMode,roiArea)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimizing reconstruction error using combination coefficient
%
% 2007/01/07 Hajime Uchida
% 2007/05/24 Hajime Uchida - Opt weights of decoder for allCV.
% 2007/11/17 Yoichi Miyawaki
% 2008/01/22 Yoichi Miyawaki - rewrite for paper figures

libRootPath = '../../../lib/';
libLocalPath = '../../lib/'
addpath(genpath([libRootPath 'BDTB-1.2.2/'])); %% edYM
addpath(genpath([libRootPath 'SLR1.2.1alpha/'])); %% edYM
addpath(genpath(libLocalPath)); %% edYM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Exp parameter setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sbjID = 's1'; onVal = 1; resol = 10;
randImgRun = 1:20; figTestRun  = 21:32;
dirPostFix = 's1071119ROI_resol10';
decoderPath = '../';
predMode = 'maxProbLabel';
basisNormMode = 'dimNorm';    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Model setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
decType = 'smlr';
%decType = 'smlr_shuffle1';

roiEcc = 'Ecc1to11';
roiName = [roiArea '_' roiEcc];
    
cvModeLocalDecoder = 'leave1';
cvModeImgRecon = 'trainCombFigRecon';

loadDirPostFix = [dirPostFix '_' cvModeLocalDecoder];
saveFnamePostFix = [dirPostFix '_' cvModeImgRecon];    
    
saveFnamePostfix2 = ['_' predMode '_' basisNormMode];
saveDir = ['result/' sbjID '/' roiArea '/' decType];

if ~exist(saveDir,'dir')
    mkdir(saveDir)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% For parallel computing setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
saveFname = [sbjID '_' roiName '_baseByRestPre_' decType '_' ...
    saveFnamePostFix '_linComb-' optMode '_' decoCombType ...
    saveFnamePostfix2 '_figReconW.mat'];

saveFnameToSkip = [sbjID '_' roiName '_baseByRestPre_' decType '_' ...
    saveFnamePostFix '_linComb-' optMode '_' decoCombType ...
    saveFnamePostfix2 '_figReconW_toSkip.mat'];

if 1
    fprintf(['checking saveFnameToSkip: ' saveFnameToSkip '\n']);
    if exist([saveDir '/' saveFnameToSkip],'file')
        fprintf('File already exist. Skip this combination.\n');
        return
    else
        str = 'skip file does not exist. proceed calculation.';
        save([saveDir '/' saveFnameToSkip],'str');
    end
else
    fprintf('file checking skipped. all calculation is sequentially performed\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load preprocessed mat file and extracted decoder mat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fnameD = [decoderPath 'de_' sbjID '_' roiName '_baseByRestPre_' decType '_' loadDirPostFix '_1x1_preprocessed'];
fprintf(['loading ' fnameD ' ...\n']);
load(fnameD, 'D');
D_1x1 = D;

decoderPath = [decoderPath 'de_' sbjID '_' roiName '_baseByRestPre_' decType '_' loadDirPostFix '_decoder/'];
[decoderAllCv, basisMat, decoCombType, cvIdxSet] ...
    = prepareDecoder_basisNormalized(randImgRun, decoderPath,decoCombType,basisNormMode,cvModeImgRecon);

%% extract data of figure image
[smplFigTest, stimFigTest] = getNoRestData(D_1x1,figTestRun);
labelFigTest = stimFigTest(:,1);
stimFigTest = stimFigTest(:,2:end)/onVal;

stimLocalTestAll = []; xLocalTestAll = []; labelLocalTestAll = [];
stimFigTestAll = []; xFigTestAll = []; labelFigTestAll = [];
for cvIdx = 1:size(decoderAllCv,2)

    localTestRun = cvIdxSet.localTest.runIdx{cvIdx};

    if any(ismember(localTestRun,cvIdxSet.imgTest.runIdx)) ||...
            any(ismember(localTestRun,cvIdxSet.training.runIdx{cvIdx})) || ...
            any(ismember(cvIdxSet.training.runIdx{cvIdx},cvIdxSet.imgTest.runIdx))
        error('test and training runs are overlapping')
    end

    fprintf('runs for local train: %s, runs for basis combination: %s, run for reconstruction test: %s\n',...
        cvIdxSet.training.runStr{cvIdx}, cvIdxSet.localTest.runStr{cvIdx}, cvIdxSet.imgTest.runStr);

    decoder = decoderAllCv(:,cvIdx);

    %% localTest
    [smplLocalTest, stimLocalTest] = getNoRestData(D_1x1, localTestRun);
    labelLocalTest = stimLocalTest(:,1);
    stimLocalTest = stimLocalTest(:,2:end)/onVal;

    %% predict each decoder.
    for decoIdx = 1:size(decoder,1)
        if strcmp(decoder{decoIdx}.model, 'slr121a')
            labelPreLocalTest(:,decoIdx) = predict_smlr(decoder{decoIdx}, smplLocalTest,predMode);  %% [nSmpl x nDecoder]
            labelPreFigTest(:,decoIdx) = predict_smlr(decoder{decoIdx}, smplFigTest,predMode); %% [nSmpl x nDecoder]  
        else
            error('invalid model')
        end
    end

    for pixIdx = 1:(resol^2)
        nSmpl = size(labelPreLocalTest,1);
        labelPreInPix = repmat(basisMat(:,pixIdx),1,nSmpl) .* labelPreLocalTest';
        xLocalTest(pixIdx,:,:) = labelPreInPix; %% [nPixel x nDecoder x nSmpl]

        nSmpl = size(labelPreFigTest,1);
        labelPreInPix = repmat(basisMat(:,pixIdx),1,nSmpl) .* labelPreFigTest';
        xFigTest(pixIdx,:,:) = labelPreInPix; %% [nPixel x nDecoder x nSmpl]
    end

    stimLocalTestAll = [stimLocalTestAll; stimLocalTest];
    xLocalTestAll = cat(3, xLocalTestAll, xLocalTest);
    labelLocalTestAll = [labelLocalTestAll labelLocalTest];

    stimFigTestAll = [stimFigTestAll; stimFigTest];
    xFigTestAll = cat(3, xFigTestAll, xFigTest);
    labelFigTestAll = [labelFigTestAll labelFigTest];
end


y = stimLocalTestAll';
x = xLocalTestAll;

%% rank check
X = reshape(permute(x, [1 3 2]), size(x,1) * size(x,3), size(x,2));
Y = y(:);
fprintf('# of parameter: %d, data rank: %.2f\n', size(x,2), rank([X Y]));


if strmatch(optMode, 'errFuncImage', 'exact')
    errFunc = optMode;
    w0 = zeros(size(x,2),1);
    iterNum = 1000;
    display = 'iter'; % off, final, iter
    options = optimset('GradObj','on', 'MaxIter', iterNum, 'Display', display);
    [w fval] = fminunc(errFunc, w0, options, y, x);

elseif strmatch(optMode, 'errFuncImageNonNegCon', 'exact')
    errFunc = 'errFuncImage';
    w0 = zeros(size(x,2),1);
    lb = zeros(size(x,2),1);
    iterNum = 1000;
    display = 'iter'; % off, final, iter
    options = optimset('GradObj','on', 'MaxIter', iterNum, 'Display', display);
    [w fval] = fmincon(errFunc, w0, [],[],[],[],lb,[],[],options, y, x);

elseif strmatch(optMode, 'no_opt', 'exact')
    w = ones(size(x,2),1);
else
    error('Invalid optimization mode')
end


for smplIdx = 1:size(xLocalTestAll,3)
    stimLocalTestAllPre(smplIdx,:) = xLocalTestAll(:,:,smplIdx) * w;
end
for smplIdx = 1:size(xFigTestAll,3)
    stimFigTestAllPre(smplIdx,:) = xFigTestAll(:,:,smplIdx) * w;
end

wOfDecoder = w;

saveVars = {'decoder','basisMat','wOfDecoder', 'decoderAllCv',...
    'labelLocalTestAll','stimLocalTestAll','stimLocalTestAllPre', ...
    'labelFigTestAll','stimFigTestAll','stimFigTestAllPre', ...
    'randImgRun','figTestRun','predMode','basisNormMode'};


save([saveDir '/' saveFname],saveVars{:});




