function [result, pars] = libsvm_bdtb(D, pars)
% libsvm_bdtb - performs multi SVM using libsvm-mat, either train or test
% [result, pars] = libsvm_bdtb(D, pars)
%
% Inputs:
%	D.data       - 2D matrix of data
%	D.label      - labels matching samples of 'data'; only [] for test mode
% Optional:
%	pars.model   - SVM 'model', including weights; optional for training
%	pars.mode    - train=1 (make weights) or test=2 mode (use weights)
%	pars.verbose - [1..3] = print detail level; 0 = no printing (default=0)
%   pars.conds   - class label, which is necessary to relabel correctly
% LibSVM pars fields:
%	.kernel      - 0=linear, 1=poly, 2=rbf, 3=sigmoid; default=0
%	.cost        - C of C-SVC, epsilon-SVR, and nu-SVR; default=1
%	.gamma       - set gamma in kernel function; default 1/k
%	.coef        - set coef0 in kernel function; default=0
%	.degree      - set degree in kernel function; default=3
%	.prob        - output probabilities as decVals? 0-no, 1-yes; default=1
% Outputs:
%	result       - struct contain ANY result as a field, typically:
%       .model   - name of this function
%       .pred    - predicted labels
%       .label   - defined labels
%       .dec_val - decision values
%       .weight  - weight and bias
%	pars         - modified pars, new weights will be added here
%
% Note: modelSwitch will make the remaining fields of results.
%
% Calls: svmtrain, svmpredict (help svmtrain for more info)
% Requires: libsvm-mat-2.82, (c) 2000-2005 Chih-Chung Chang & Chih-Jen Lin
% Info: http://www.csie.ntu.edu.tw/~cjlin/libsvm
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var')    || isempty(D),      error('Wrong args');	end
if ~exist('pars','var') || isempty(pars),	pars = [];              end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
model   = getFieldDef(pars,'model',[]);
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);

if     mode==1 && isempty(D.label),     error('must have ''label'' for train');
elseif mode==2 && isempty(model),       error('must have ''model'' for test');      end


%% Add path of libsvm-mat (if needed):
str = which('svmpredict');
if isempty(str)
    dirname = uigetdir(pwd,'Select ''libsvm-mat'' directory');
    if isequal(dirname,0),  error('Can''t find ''libsvm-mat''');    end
    addpath(dirname);
end


%% SVM pars:
kernel = getFieldDef(pars,'kernel',0);      % linear
gamma  = getFieldDef(pars,'gamma',0);       % NOTE: gamma=0 defaults to 1/k
prob   = getFieldDef(pars,'prob',1);
cost   = getFieldDef(pars,'cost',1);
coef   = getFieldDef(pars,'coef',0);
degree = getFieldDef(pars,'degree',3);

ops1 = sprintf('-t %d -c %g -r %g -d %g', kernel, cost, coef, degree);
if prob,        ops1 = [ops1 ' -b 1'];   ops2 = '-b 1';     end
if gamma,       ops1 = [ops1 ' -g ' num2str(gamma)];        end
%if verbose==0,  ops2 = [ops2 ' -o 0'];                      end     % hacked


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:  \t%d\n',mode);
    if verbose>=2
        kernel_str = {'0-linear','1-poly','2-rbf','3-sigmoid'};
        fprintf('\n kernel:\t%s',kernel_str{kernel+1});
        fprintf('\n cost:  \t%g',cost);
        fprintf('\n coef:  \t%g',coef);
        fprintf('\n degree:\t%g',degree);
        if prob,    fprintf('\n prob:  \t%d',prob);       end
        if gamma,   fprintf('\n gamma: \t%g',gamma);
        else        fprintf('\n gamma: \t1/k');          end
    end
end


%% Test mode:
if mode==2
    [pred, nouse, dec_val] = svmpredict(D.label, D.data, model, ops2);
    
    
%% Train mode:
else
    model                  = svmtrain(D.label, D.data, ops1);
    [pred, nouse, dec_val] = svmpredict(D.label, D.data, model, ops2);
    
    pars.model             = model;
end


%% Retrun results:
if exist('labels_old','var') && isempty(labels_old)==0  
    D.label = reIndex(D.label,labels_old,labels_new);
    pred    = reIndex(pred,labels_old,labels_new);
end


%% Return results:
result.model   = mfilename;
result.pred    = pred;
result.label   = D.label;
result.dec_val = dec_val;
result.weight  = model.SVs' * model.sv_coef;


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
