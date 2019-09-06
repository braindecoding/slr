function [mi chi2 p] = multiclass_mutualinfo_confmat(confmat)
% multiclass_mutualinfo_confmat - calculate mutual information from confusion matrix
% [mi chi2 p] = multiclass_mutualinfo_confmat(confmat)
%
% Inputs:
%   confmat - confusion matrix
% Outputs:
%   mi      - mutual information
%   chi2    - chi-square value
%   p       - cumulative distribution function of chi-square
%
% Note:
%   'p' is the cumulative distribution function, so the LARGE value of 'p'
%   means NON-independent 
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% mutual information
N   = sum(confmat(:));
pxy = confmat/N;
px  = sum(confmat,2)/N;
py  = sum(confmat,1)/N;

ixz = find(px > 0);
Hx	= - sum( px(ixz) .* log2(px(ixz)) );

ixz = find(py > 0 );
Hy	= - sum( py(ixz) .* log2(py(ixz)) );

ixz = find( pxy > 0 );
Hxy = - sum( pxy(ixz) .* log2(pxy(ixz)) );

mi = Hx + Hy - Hxy;


%% chi-square test for independence
tmp = 0;
for i = 1:length(px)
    for j = 1:length(py)
        tmp = tmp + N * (pxy(i,j) - px(i)*py(j)).^2 / (px(i)*py(j));
    end
end
chi2 = tmp;

nu = (length(px) - 1)*(length(py) - 1);
p  = chi2cdf(chi2, nu);
