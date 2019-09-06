function preds = predsFromDecVals(dec_vals, conds)
% predsFromDecVals - maps decision values to prediction labels
% preds = predsFromDecVals(dec_vals, conds)
%
% Inputs:
%	dec_vals - decision values
% Optional:
%	conds   - list of conditions corresponding to decVals; if absent,
%   		  it will use [1 2 ...] as conditions
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('dec_vals','var') || isempty(dec_vals),	error('Wrong args');    end

if ~exist('conds','var') || isempty(conds)
    num_conds = size(dec_vals,2);
    conds     = 1:num_conds;
end


%% Find max decision value:
[nouse, inds] = max(dec_vals,[],2);


%% Map max to condition:
preds = conds(inds);
