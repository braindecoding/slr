function [D, pars] = selectConds(D, pars)
% selectConds - selects data corresponding to labels that match 'conds'
% [D, pars] = selectConds(D, pars)
%
% Selects data and labels corresponding to labels that match conditions
% in array 'conds'; also returns indices of selection in 'pars.indCond'.
%
% Input:
%   D.data       - 2D matrix
%   D.label      - 1D array of labels whose length matches the sample length of data
%   pars.conds   - 1D array of conditions to be selected from labels
% Optional:
%   pars.verbose - [1..3] = print detail level; 0 = no printing (default=0)
% Output:
%   D.data       - data corresponding to matched labels
%   D.label      - condition labels matching 'conds'
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D)
    error('''D''ata-struct must be specified');
end
if ~exist('pars','var'),	pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
conds   = getFieldDef(pars,'conds',[]);
verbose = getFieldDef(pars,'verbose',0);

if isempty(conds),      return;     end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n conds: %s\n', num2str(conds));
end


%% Find indexes of labels matching conds:
conds      = unique(conds);
inds_match = find(ismember(D.label,conds));


%% Select data and labels with indexes:
D.label = D.label(inds_match);
D.data  = D.data(inds_match,:);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
