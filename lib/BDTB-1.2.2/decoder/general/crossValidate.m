function [result, P] = crossValidate(D, P, procs, models)
% crossValidate_run - performs leave-'one_run'-out cross-validations tests of 'models'
% [result, P] = crossValidate_run(D, P, procs, models)
%
% Input:
%   D.data       - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label      - condition labels of each sample ([time x 1] format)
%   D.design     - design matrix of experiment ([time x dtype] format)
%   procs        - array of strings of the processing functions to be called;
%                  this may be any function that conforms with this format:
%                  [D, pars] = myFunc(D, pars);
%   models       - array of strings of the models functions to be called;
%                  this may be any function that conforms with this format:
%                  [result, pars] = myFunc(D, pars);
% Optional:
%   P.<function> - parameters of 'procs' and 'models'
%   P.crossValidate.fold_ind
%                - index of D.design means which design is used as 'fold' (default=1)
%   P.crossValidate.res_train
%                - return training result also? 0-no, 1-yes, default=0
%   P.crossValidate.verbose
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
if ~exist('D','var')      || isempty(D),        return;         end
if ~exist('procs','var')  || isempty(procs),    procs = [];     end
if ~exist('models','var') || isempty(models),	return;         end
if ~exist('P','var')      || isempty(P),        P = [];         end

pars      = getFieldDef(P,mfilename,[]);
fold_ind  = getFieldDef(pars,'fold_ind',1);
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

% make inds:
id_fold   = D.design(:,fold_ind);
uid_fold  = unique(id_fold);
num_fold  = length(uid_fold);
inds_fold = cell(1,num_fold);
for itf=1:num_fold
    inds_fold{itf} = id_fold==uid_fold(itf);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n %d fold cross validation',num_fold);
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


%% Main validation loop:
fprintf('\n fold      :');
res_cells_te = cell(length(models),num_fold);
res_cells_tr = cell(length(models),num_fold);
for itf=1:num_fold
    fprintf(' %d', itf);
    
    % Get training and test indexes:
    inds_te = inds_fold{itf};
    inds_tr = ~inds_te;
    
    % Get training data and labels:
    D_tr.data  = D.data(inds_tr,:);
    D_tr.label = D.label(inds_tr);
    
    % Preprocessing for training data:
    P.procSwitch.mode = 1;
    [D_tr, P]         = procSwitch(D_tr,P,procs);
    
    % Training:
    P.modelSwitch.mode = 1;
    [res_tr, P]        = modelSwitch(D_tr,P,models);
    
    % Get test data and labels:
    D_te.data  = D.data(inds_te,:);
    D_te.label = D.label(inds_te);
    
    % Preprocessing for test data:
    P.procSwitch.mode = 2;
    [D_te, P]         = procSwitch(D_te,P,procs);
    
    %Test:
    P.modelSwitch.mode = 2;
    [res_te, P]        = modelSwitch(D_te,P,models);
    
    res_cells_tr(:,itf) = res_tr;
    res_cells_te(:,itf) = res_te;
end
fprintf('\n');


%% Results summary:
res_cells_te = resultsSummary(res_cells_te);


%% Return results:
if res_train
    result.train = res_cells_tr;
    result.test  = res_cells_te;
else
    result = res_cells_te;
end
