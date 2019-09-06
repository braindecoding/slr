function [result, pars] = svm11lin_bdtb(D, pars)
% svm11lin_bdtb - SVM one-against-one, linear combination, either train or test
% [result, pars] = svm11lin_bdtb(D, pars)
%
% Input:
%   D.data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label       - condition labels of each sample ([time x 1] format)
% Optional:
%   pars.weight   - weight for test mode; optional for training
%   pars.mode     - train=1 (make weight) or test=2 mode (use weight)
%   pars.num_boot - number of bootstrap samples
%                   0: no botstrapping, <0: use '-num_boot*length(labels)'
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
% Output:
%   result        - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .pred     - predicted labels
%       .label    - defined labels
%       .dec_val  - decision values
%       .weight   - weight and bias
%   pars          - modified pars, new weight will be added here
%
% Calls:
%   svm11linTrain - calculates weight by 'OSU SVM'
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
weight   = getFieldDef(pars,'weight',[]);
mode     = getFieldDef(pars,'mode',1);
num_boot = getFieldDef(pars,'num_boot',0);
verbose  = getFieldDef(pars,'verbose',0);

if     mode==1 && isempty(D.label),     error('must have ''label'' for train');
elseif mode==2 && isempty(weight),      error('must have ''weight'' for test');         end


%% Add path of OSU SVM (if needed):
str = which('PolySVC');
if isempty(str)
    dirname = uigetdir(pwd,'Select OSU SVM directory');
    if isequal(dirname,0),  error('Can''t find OSU SVM');   end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode    :\t%d\n',mode);
    if num_boot~=0,     fprintf(' num_boot:\t%d\n',num_boot);       end
end


%% Test mode:
if mode==2
    dec_val = D.data * weight(1:end-1,:);


%% Train mode (normal):
elseif num_boot==0
    weight      = svm11linTrain(D.data,D.label);
    dec_val     = D.data * weight(1:end-1,:);
    
    pars.weight = weight;


%% Train mode (Bootstrapping):
else
    if num_boot<0,      num_boot_samps = -num_boot*length(D.label);
    else                num_boot_samps = num_boot;                          end
    
    boot_weight = bootstrp(num_boot_samps,'svm11linTrain',D.data,D.label);
    weight      = reshape(mean(boot_weight(1:num_boot_samps,:),1),[],length(unique(D.label)));
    dec_val     = D.data * weight(1:end-1,:);
    
    pars.weight = weight;
end


%% Return results:
result.model   = mfilename;
result.dec_val = dec_val;
result.weight  = weight;
result.label   = D.label;
result.pred    = predsFromDecVals(dec_val,unique(D.label));


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
