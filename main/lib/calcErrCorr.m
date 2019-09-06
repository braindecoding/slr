function [msqerr, corrVal, corrPval] = calcErrCorr(stim, stimPre)
%
% --- Input
% stim    :  [nSmpl x nDim]
% stimPre :  [nSmpl x nDim]
%
% --- Output
% mse      :  [nSmpl x 1]
% corr     :  [nSmpl x 1]
% corrPval :  [nSmpl x 1]
% rate     :  [nSmpl x 1]


msqerr = mean((stim - stimPre).^2, 2);
for smplIdx = 1:size(stim,1)
    if sum(stim(smplIdx,:)) ~= 0
        [tmpCorr, tmpPval] = corrcoef(stim(smplIdx,:), stimPre(smplIdx,:));
        corrVal(smplIdx,1) = tmpCorr(1,2);
        corrPval(smplIdx,1) = tmpPval(1,2);
    else    
        corrVal(smplIdx,1) = 0;
        corrPval(smplIdx,1) = 0;
    end
end

%% dim to [nSmpl x 1]
msqerr = msqerr(:);
corrVal = corrVal(:);
corrPval = corrPval(:);


