function [msqerr, corrVal, corrPval, fh] = plotReconstImageResult(stim, stimPre, labels, labelNames, tilteStr)
%
% --- Input
% stim    :  [nSmpl x nPixel]
% stimPre :  [nSmpl x nPixel]
% labels  :  [nSmpl x 1]
%
% --- Output
% msqerr     :  [nSmpl x 1]
% corrVal    :  [nSmpl x 1]
% corrPval   :  [nSmpl x 1]
%
% 2007/01/05 Hajime Uchida
% 2007/05/08 Yoichi Miyawaki modified
% 2007/07/26 Hajime Uchida - return figure handle
% 2008/04/10 Yoichi Miyawaki - use RMSE instead of mean squared error

[msqerr, corrVal, corrPval] = calcErrCorr(stim, stimPre);

resol = sqrt(size(stim,2));%%edYM
nSmpl = size(stim,1);%%edYM
xlimVec = [0.5 nSmpl+0.5];
idxFh=1;
fh(idxFh) = figure;idxFh=idxFh+1;
colormap(gray); plotH = 5;
for smplIdx = 1:nSmpl
    subplot(plotH,nSmpl,smplIdx);       imagesc(reshape(stim(smplIdx,:),    resol, resol),[0 1]); axis image; axis off;%%edYM
    if nargin >= 4 & ~isempty(labelNames)
        title(labelNames{labels(smplIdx)},'interpreter','none');
    end
    subplot(plotH,nSmpl,smplIdx+nSmpl); imagesc(reshape(stimPre(smplIdx,:), resol, resol)); axis image; axis off;%%edYM
end

subplot(plotH,nSmpl, [1:nSmpl]+nSmpl*2); plot(msqerr, '-o');      xlim(xlimVec); ylim([0 1]); ylabel('mse'); xlabel('sample');
text(0.01,0.85,['mean: ' num2str(mean(msqerr))],'Units','normalized');

subplot(plotH,nSmpl, [1:nSmpl]+nSmpl*3); plot(corrVal, '-o');     xlim(xlimVec); ylim([0 1]); ylabel('correlation'); xlabel('sample');
text(0.01,0.85,['mean: ' num2str(mean(corrVal))],'Units','normalized');

subplot(plotH,nSmpl, [1:nSmpl]+nSmpl*4); plot(corrPval, '-o'); xlim(xlimVec); ylabel('correlation p-val'); xlabel('sample');
text(0.01,0.85,['mean: ' num2str(mean(corrPval))],'Units','normalized');





