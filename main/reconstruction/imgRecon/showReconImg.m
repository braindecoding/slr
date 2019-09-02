function showReconImg(decoCombType,optMode,roiArea)

% 2007/01/07 Hajime Uchida
% 2007/08/21 Yoichi Miyawaki
% 2008/01/22 Yoichi Miyawaki
% 2008/03/12 Yoichi Miyawaki

libLocalPath = '../../lib/';
addpath(genpath(libLocalPath));

decType = 'smlr';

combType = ['linComb-' optMode '_' decoCombType];


cvModeImgRecon = 'figRecon';
resolMode = 'resol10';
predMode = 'maxProbLabel';
basisNormMode = 'dimNorm';

roiEcc = 'Ecc1to11';
roiName = [roiArea '_' roiEcc];

postFix = [];

expID = 's1_s1071119';

if strcmp(expID,'s1_s1071119')
    sbjId = 's1';
    dirPostFix = 's1071119ROI_resol10';
  testNumList = [10 10 10 10 ... %%% figure
		 10 10 ...       %%% NEURO small
		 10 10 ...       %%% NEURO long
		 10 10 10 10 ... %%% NEURO thin
		];
  testNameList = {'figure1';'figure2';'figure3';'figure4';...
		 'NEUROsmall1';'NEUROsmall2';...
		 'NEUROlong1';'NEUROlong2';
		 'NEUROthin1';'NEUROthin2';'NEUROthin3';'NEUROthin4';}
  toPlotImg = [1:12];
end


resDir = ['result/' sbjId '/' roiArea '/' decType '/'];
figDir = ['figure/' sbjId '/' roiArea '/' decType '/'];;

if ~exist(figDir,'dir')
  mkdir(figDir);
end


%%% plot index selection
for idxPlot = 1:length(testNumList)
  tmp{idxPlot} = [1:testNumList(idxPlot)] + sum(testNumList(1:idxPlot-1));
end    

for i = 1:length(toPlotImg)
  plotIdxList{i} = tmp{toPlotImg(i)};
end


data = [resDir sbjId '_' roiName '_baseByRestPre_' ...
        decType '_'  dirPostFix ...
        '_' cvModeImgRecon '_' combType ...
        '_' predMode, '_' basisNormMode postFix ...
        '.mat'];

fprintf('loading: %s ...\n',data);
d = load(data); 
      
for k = 1:length(plotIdxList)
    plotIdx = plotIdxList{k};
    
    offset = 0;
    stim = d.stimFigTestAll(plotIdx+offset,:);
    stimPre = d.stimFigTestAllPre(plotIdx+offset,:);
    label = d.labelFigTestAll(plotIdx+offset,:);
    
    [msqerr,corrVal,corrPval,fh] = plotReconstImageResult(stim,stimPre,[],[],data);

    figure(fh); suptitle(strrep([data '_' testNameList{k}],'_','\_'));

    fprintf('plot: %12s -- mse %6g\n',...
	    testNameList{k}, mean(msqerr));
	
    %%% remove result directory name and .mat suffix
    savename = data(length(resDir)+1:end-4);
    
    savename = [figDir savename '_' testNameList{k}];
    saveas(fh, savename, 'fig');
    saveas(fh, savename, 'epsc');	
    saveas(fh, savename, 'pdf');

end	       







