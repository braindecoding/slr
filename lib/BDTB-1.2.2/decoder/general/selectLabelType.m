function [D, pars] = selectLabelType(D, pars)
% selectLabelType - selecting label types from multiple labels
% [D, pars] = selectLabelType(D, pars)
%
% Example:[D, P] = selectLabelType(D, P);
%
% Inputs:
%	D     - D structure containing data, converted labels, etc.
%	pars  - P structure containing parameters for decoding
%
% Necessary fields of pars:
%      .target  - target label index to be selected (scalar)
%
% Outputs:
%	D     - D structure containing data, converted labels, etc.
%	pars  - P structure containing parameters for decoding
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D),     error('Wrong args');	end
if ~exist('pars','var'),                pars = [];              end

pars   = getFieldDef(pars,mfilename,pars); 
target = getFieldDef(pars,'target',[]);


%% Error checking:
if isempty(target)
    error('Specify target label index.');
elseif numel(target) > 1;
    error('target label index should be a scalar.');
end

D.label      = D.label(:,target);
D.label_type = D.label_type{target};
D.label_def  = D.label_def{target};

