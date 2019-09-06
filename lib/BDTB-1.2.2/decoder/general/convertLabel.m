function [D, pars] = convertLabel(D, pars)
%convertLabels - converting labels according to given tables
%
% Example:[D, P] = convertLabels(D, P);
%
% Inputs:
%	D    - D structure containing data, labels, etc.
%	pars - P structure containing parameters for decoding
%
% Necessary fields of pars:
%      .list  - conversion table of labels (format: {[org1 new1],[org2 new2],...})
%
% Outputs:
%	D    - D structure containing data, converted labels, etc.
%	pars - P structure containing parameters for decoding
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Get Parameters:
if exist('pars','var')==0
    error('Specify parameter structure')
end

parsOrg = pars;

pars   = getFieldDef(pars, mfilename, pars);	% remove any nesting
list   = getFieldDef(pars, 'list', 0);
datDim = getFieldDef(pars, 'datDim', 1);
labels = getFieldDef(D, 'label', []);


%% Error checking:
nDims = ndims(D);
if nDims>3
    fprintf('\nError: >3 dims in data!\n');
    return;
elseif (datDim<3 && nDims~=2) || (datDim==3 && nDims<3)
	fprintf('\nError: datDim does not match nDims of data!\n');
	return;
end


labelsNew = labels;
for i = 1:length(list)
    fprintf('Converting labels: %d --> %d\n',list{i}(1),list{i}(2));
    idx            = labels==list{i}(1);
    labelsNew(idx) = list{i}(2);
end


D.label = labelsNew;
pars = parsOrg;


% end



