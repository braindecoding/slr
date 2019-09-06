function [D, pars] = selectLabelSample(D, pars)
% selectLabelSample - select samples with specific labels
% [D, pars] = selectLabelSample(D, pars)
%
% Input:
%   D.data         - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label        - vector of labels (after selecting specific label vector)
% Optional:
%   pars.labels_in - label values to be included 
%   pars.verbose   - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%   D.data         - remaining data matrix
%   D.label        - remaining label matrix
%   D.design       - design matrix of selecting samples
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];              end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
labels_in  = getFieldDef(pars,'labels_in',[]);
verbose    = getFieldDef(pars,'verbose',1);

if isempty(labels_in)
    error('labels_in should be specified');
end

ulabels    = unique(D.label);
labels_out = setdiff(ulabels, labels_in);


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n labels included: \t%d',labels_in);
        fprintf('\n labels excluding:\t%s',labels_out);
    end
    fprintf('\n');
end


%% select samples
idx = find(ismember(D.label, labels_in));

D.data   = D.data(idx,:);
D.label  = D.label(idx,:);
D.design = D.design(idx,:);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
