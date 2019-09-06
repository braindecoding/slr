function [result, P] = validate(D_tr, D_te, P, procs, models)
% validate - validate test-data by 'models' trained by train-data
% result = validate(D_tr, D_te, P, procs, models)
%
% Input:
%   D_tr.data    - 2D matrix of any data for train ([time(sample) x space(voxel/channel)] format)
%   D_tr.label   - condition labels of each sample for train ([time x 1] format)
%   D_te.data    - 2D matrix of any data for test ([time(sample) x space(voxel/channel)] format)
%   D_te.label   - condition labels of each sample for test ([time x 1] format)
%   procs        - array of strings of the processing functions to be called;
%                  this may be any function that conforms with this format:
%                  [D, pars] = myFunc(D, pars);
%   models       - array of strings of the models functions to be called;
%                  this may be any function that conforms with this format:
%                  [result, pars] = myFunc(D, pars);
% Optional:
%   P.<function> - parameters of 'procs' and 'models'
%   P.validate.res_train
%                - return training results also? 0-no, 1-yes, default=0
%   P.validate.verbose
%                - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%	result       - cell array of 'result' structs returned by models, with fields:
%       .model       - names of used model
%       .pred        - predicted labels
%       .label       - defined labels
%       .dec_val     - decision values
%       .weight      - weights (and bias)
%       .freq_table  - frequency table
%       .correct_per - percent correct
%  P.<function>  - modified parameters of 'procs' and 'models'
%
% Calls:
%   procSwitch     - performs a list of processing
%   modelSwitch    - performs a list of models
%   resultsSummary - calculates fummary of results
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D_tr','var')   || isempty(D_tr),         return;         end
if ~exist('D_te','var')   || isempty(D_te),         return;         end
if ~exist('procs','var')  || isempty(procs),        procs = [];     end
if ~exist('models','var') || isempty(models),       return;         end
if ~exist('P','var')      || isempty(P),            P = [];         end

pars      = getFieldDef(P,mfilename,[]);
res_train = getFieldDef(pars,'res_train',0);
verbose   = getFieldDef(pars,'verbose',1);

% Put strings in cell array of strings
if ischar(procs)
    temp  = procs;
    procs = cell(size(temp,1),1);
    for itp=1:size(temp,1)
        procs{itp,1} = temp(1,:);
    end
end
if ischar(models)
    temp   = models;
    models = cell(size(temp,1),1);
    for itm=1:size(temp,1)
        models{itm,1} = temp(1,:);
    end
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n validation');
    if ~isempty(procs)
        fprintf('\n processing:');
        for itp=1:length(procs)
            fprintf('\t%s',procs{itp});
        end
    end
    fprintf('\n models    :');
    for itm=1:length(models)
        fprintf('\t%s',models{itm});
    end
end


%% Main validation proc:
% Preprocessing for training data:
P.procSwitch.mode = 1;
[D_tr, P]         = procSwitch(D_tr,P,procs);

% Training:
P.modelSwitch.mode = 1;
[res_tr, P]        = modelSwitch(D_tr,P,models);

% Preprocessing for test data:
P.procSwitch.mode = 2;
[D_te, P]         = procSwitch(D_te,P,procs);

%Test:
P.modelSwitch.mode = 2;
[res_te, P]        = modelSwitch(D_te,P,models);


%% Results summary:
for itm=1:length(models)
    [res_te{itm}.freq_table, res_te{itm}.correct_per] = freqTableFromLabels(res_te{itm}.label,res_te{itm}.pred);    
end


%% Return results:
if res_train
    result.train = res_tr;
    result.test  = res_te;
else
    result = res_te;
end
