function [results, pars] = liblinear_bdtb(D, pars)
%liblinear_bdtb - performs 'liblinear'
%[results, pars] = liblinear_bdtb(D, pars)
%
% Input:
%   D.data       - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label      - condition labels of each sample ([time x 1] format)
% Optional:
%   pars.model   - liblinear 'model', including weights; optional for training
%   pars.mode    - train=1 (make weights) or test=2 mode (use weights)
%   pars.verbose - [1..3] = print detail level; 0 = no printing (default=0)
%   pars.ops     - for 'liblinear' pars, see README of liblinear
% Output:
%   results      - struct contain ANY result as a field, typically:
%       .model   - name of this function
%       .pred    - predicted labels
%       .label   - defined labels
%       .weight  - weight and bias
%   pars         - modified pars, new weights will be added here
%
% Calls:
%   liblinear, (c) >>>
%       train   - learning parameters of liblinear
%       predict - classifying data by learned parameters
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
model         = getFieldDef(pars,'model',[]);
mode          = getFieldDef(pars,'mode',1);
verbose       = getFieldDef(pars,'verbose',0);
ops           = getFieldDef(pars,'ops',[]);
trainShuffle  = getFieldDef(pars, 'trainShuffle', 0);  % no

if     mode==1 && isempty(D.label),    error('must have ''label'' for train');
elseif mode==2 && isempty(model),       error('must have ''model'' for test');      end



%% Add path of libliner/matlab (if needed):
str = which('train');
if isempty(str)
    dirname = uigetdir(pwd,'Select ''liblinear/matlab'' directory');
    if isequal(dirname,0),  error('Can''t find ''liblinear''');     end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:\t%d\n',mode);
end


%% Model pars:
if verbose,     ops = [ops ' -v 1'];        end


%% Test mode:
if mode==2
    [pred, accuracy, prob] = predict(D.label,sparse(D.data),model,ops);


%% Train mode:
else
    label = D.label;
    if trainShuffle
        label = label(randperm(length(label)));
    end
    
    model = train(label,sparse(D.data),ops);
    pred  = model.Label;
    
    pars.model = model;
end


%% Retrun results:
results.model  = mfilename;
results.pred   = pred;
results.label  = D.label;
results.weight = model.w';


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
