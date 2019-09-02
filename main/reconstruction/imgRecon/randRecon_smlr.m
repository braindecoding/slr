function randRecon_smlr(decoCombType,optMode,imgTestIdx,roiArea)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reconstruction of figure image using optimized combination coefficient
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
cvModeImgRecon = 'randRecon';
cvModeReconWeight = 'trainCombRandRecon';

loadDirPostFix = [dirPostFix '_' cvModeLocalDecoder];
saveFnamePostFix = [dirPostFix '_' cvModeImgRecon];
weightFnamePostFix = [dirPostFix '_' cvModeReconWeight];

weightFnamePostfix2 = ['_' predMode '_' basisNormMode];
saveFnamePostfix2 = ['_' predMode '_' basisNormMode];
    
weightDir = ['result/' sbjID '/' predMode '/' roiArea '/' decType];
saveDir = ['result/' sbjID '/' predMode '/' roiArea '/' decType];


%%% wOfDecoder file name
weightFname = [sbjID '_' roiName '_baseByRestPre_' decType '_' ...
	       weightFnamePostFix '_linComb-' optMode '_' decoCombType ...
	       weightFnamePostfix2 '_imgTestIdx' ...
	       num2str(imgTestIdx) '_randReconW.mat'];

%%% save file name
saveFname = [sbjID '_' roiName '_baseByRestPre_' decType '_' ...
             saveFnamePostFix '_linComb-' optMode '_' decoCombType ...
             saveFnamePostfix2 '_imgTestIdx' ...
             num2str(imgTestIdx) '.mat'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load preprocessed mat file, extracted decoder mat file,
%%% and combination coefficient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fnameD = [decoderPath 'de_' sbjID '_' roiName '_baseByRestPre_' decType '_' loadDirPostFix '_1x1_preprocessed'];
fprintf(['loading ' fnameD ' ...\n']);
load(fnameD, 'D');
D_1x1 = D;

decoderPath = [decoderPath 'de_' sbjID '_' roiName '_baseByRestPre_' decType '_'loadDirPostFix '_decoder/'];
[decoderAllCv, basisMat, decoCombType, cvIdxSet] ...
    = prepareDecoder_basisNormalized(randImgRun, decoderPath,decoCombType,basisNormMode,cvModeImgRecon,imgTestIdx);

fnameW = [weightDir '/' weightFname];
fprintf(['loading combination coefficient: ' fnameW ' ...\n']);
load(fnameW,'wOfDecoder');

%% extract data of figure image
[smplImgTest, stimImgTest] = getNoRestData(D_1x1,cvIdxSet.imgTest.runIdx);
labelImgTest = stimImgTest(:,1);
stimImgTest = stimImgTest(:,2:end)/onVal;

stimImgTestAll = []; xImgTestAll = []; labelImgTestAll = [];
for cvIdx = 1:size(decoderAllCv,2)

  if any(ismember(cvIdxSet.training.runIdx{cvIdx},cvIdxSet.imgTest.runIdx))
    error('test and training runs are overlapping')
  end

  fprintf('runs for local train: %s, run for reconstruction test: %s\n',...
	  cvIdxSet.training.runStr{cvIdx}, cvIdxSet.imgTest.runStr);
    
  decoder = decoderAllCv(:,cvIdx);
    
  %% predict each decoder.
  for decoIdx = 1:size(decoder,1)
      if strcmp(decoder{decoIdx}.model, 'slr121a')      
          labelPreImgTest(:,decoIdx) = predict_smlr(decoder{decoIdx}, smplImgTest,predMode);  %% [nSmpl x nDecoder]
      else
          error('invalid model')    
      end
  end

  for pixIdx = 1:(resol^2)
    nSmpl = size(labelPreImgTest,1);
    labelPreInPix = repmat(basisMat(:,pixIdx),1,nSmpl) .* labelPreImgTest';
    xImgTest(pixIdx,:,:) = labelPreInPix; %% [nPixel x nDecoder x nSmpl]
  end

  stimImgTestAll = [stimImgTestAll; stimImgTest];
  xImgTestAll = cat(3, xImgTestAll, xImgTest);
  labelImgTestAll = [labelImgTestAll labelImgTest];
end

for smplIdx = 1:size(xImgTestAll,3)
    stimImgTestAllPre(smplIdx,:) = xImgTestAll(:,:,smplIdx) * wOfDecoder;
end


saveVars = {'decoder','basisMat','wOfDecoder', 'decoderAllCv',...
	    'labelImgTestAll','stimImgTestAll','stimImgTestAllPre', ...
	    'randImgRun','figTestRun','predMode','basisNormMode'};


save([saveDir '/' saveFname],saveVars{:});




