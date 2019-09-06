function [D, pars] = balanceLabels(D, pars)
% balances labels by either averaging (.method=1), adjustToMin (2), adjustToMax (3)
%[D, pars] = balanceLabels(D, pars)
%
% Inputs:
%	D.data   - 2D matrix of data ([time(sample) x space(voxel/channel)] format)
%	D.label  - labels matching samples of 'data' ([time x 1] format)
%	pars     - structure containing parameters as optional fields; may be P
% Optional pars fields:
%	.method  - 1=averaging, 2=adjust to min, 3=adjust to max
%	.doTest  - should we balance in test (.mode=2)? 0-no, 1-yes (default: 1)
%	.mode    - train=1 or test=2 mode
%	.verbose - [1..3] = print detail level; 0 = no printing (default=0)
% Outputs:
%	D.label  - new balances labels
%	D.data   - data matching new labels
%	pars     - any modified pars, including .inds for indices used
%
% Note:
%   This function might shuffle data in the time direction.
%   So you should use this function in 'procs2'.
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
method 	= getFieldDef(pars, 'method',  2);		% 2=adjust to min
doTest  = getFieldDef(pars, 'doTest',  1);		% balance test set also?
mode 	= getFieldDef(pars, 'mode',    1);
datDim 	= getFieldDef(pars, 'datDim',  1);		% 1=new
verbose = getFieldDef(pars, 'verbose', 0);		% yes

labels = D.label;
data   = D.data;

nOrig = length(labels);

%% Optionally balance test set:
if doTest==0 && mode==2,
	return;
end;

%% suppose labels -> [n x times] and data -> [m x times] below (YM100410)
labels = labels';
data   = data';

%%% Balancing methods:
[labelsNew rr colReps] = removeReps(labels);
colInds = cumsum(colReps);
nInds = length(colInds);

uLabels = unique(labels);
nMinLabels = Inf;
nMaxLabels = 0;

uLabelsInds = cell(1,length(uLabels));
for it = 1:length(uLabels)
  tmpInds = find(labels == uLabels(it));
  uLabelsInds{it} = tmpInds;
  if nMinLabels > length(tmpInds); nMinLabels = length(tmpInds); end
  if nMaxLabels < length(tmpInds); nMaxLabels = length(tmpInds); end
end

if method==1,     % average
    dataNew = zeros(size(data,1), nInds);
    ei = 0;
    for it = 1:nInds,
        bi = ei + 1;
        ei = colInds(it);
        dataNew(:,it) = mean(data(:,bi:ei),2);
    end;
    data   = dataNew;
    labels = labelsNew;
    inds   = colInds;

elseif method==2, % adjust to min cond.
    rand('state',sum(100*clock));
    inds = zeros(1,nMinLabels*length(uLabels));
    for it = 1:length(uLabels)
        tmpRand                                 = randperm(length(uLabelsInds{it}));
        inds(nMinLabels*(it-1)+1:nMinLabels*it) = uLabelsInds{it}(tmpRand(1:nMinLabels));
    end
    data   = data(:,inds);
    labels = labels(:,inds);
      
elseif method==3, % adjust to max cond.
    rand('state',sum(100*clock));
    inds = [];
    for it = 1:length(uLabels)
        tmpRand    = randperm(length(uLabelsInds{it}));
        nDuplicate = nMaxLabels - length(uLabelsInds{it});
        inds       = [inds uLabelsInds{it}];
        while nDuplicate ~= 0
            if nDuplicate > length(tmpRand)
                inds       = [inds uLabelsInds{it}(tmpRand)];
                nDuplicate = nDuplicate - length(tmpRand); 
            else
                inds       = [inds uLabelsInds{it}(tmpRand(1:nDuplicate))];
                nDuplicate = 0;
            end
        end
    end
    data   = data(:,inds);
    labels = labels(:,inds);
end


%% reverse dims:
data   = data';
labels = labels';
inds   = inds';


%% Print parameters:
if verbose,
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n This function might shuffle data in the time direction.\n So you should use this function in ''procs2''.');
    if verbose>=2
        meth = {'averaging','adjust to min','adjust to max'};
    	fprintf('\n  method\t= %s', meth{method});
        fprintf('\n  doTest\t= %d', doTest);
    	fprintf('\n  mode  \t= %d', mode);
        fprintf('\n  datDim\t= %d', datDim);
        nNew = length(labels);
        fprintf('\n  %d orig labels, now %d', nOrig, nNew);
    end
    fprintf('\n');
end

pars.inds = inds;

%% Output:
%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end


D.data   = data;
D.label  = labels;

% end
