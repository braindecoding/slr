function [results, pars] = slr_lap_bdtb(D, pars)
%slr_lap_bdtb - performs SLR-LAP-1vsR using SLR1.2.1alpha, either train or test
%[results, pars] = slr_lap_bdtb(D, pars)
%
% Input:
%   D.data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label       - condition labels of each sample ([time x 1] format); only [] for test mode
% Optional:
%   pars.conds    - conditions to be tested (should be 2 for binomial)
%   pars.mode     - train=1 (make weights) or test=2 mode (use weights)
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
% SLR pars:
%   .scale_mode  - normalize paramter
%   .mean_mode   - normalize parmeter
% SLR pars for test:
%   .weight       - SLR weights; for linear, length of chans (mostly zeros)
%   .ix_eff       - index of non-zero weights; for linear, chans used	
%   .norm_scale   - normalize parameter
%   .norm_base    - normalize parameter
%   .norm_sep     - normalize parameter
% SLR pars for train:
%   .nlearn       - # of learning
%   .ax0          - Initial value of relevance parameter ax
%   .amax         - Truncation criteria. Parameters whose relevance parameter is larger 
%                   than this value are eliminated from further iterations
% Output:
%   results - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .pred     - predicted labels
%       .label    - defined labels
%       .dec_val  - decision values
%       .weight   - weights and bias
%	pars          - modified pars, new weights will be added here
%
% Calls:
%   SLR1.2.1alpha, (c)
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
conds   = getFieldDef(pars,'conds',unique(D.label));
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);

num_class = length(conds);

% SLR pars:
nlearn     = getFieldDef(pars,'nlearn',150);
ax0        = getFieldDef(pars,'ax0',[]);
amax       = getFieldDef(pars,'amax',1e8);
weight     = getFieldDef(pars,'weight',[]);
ix_eff     = getFieldDef(pars,'ix_eff',[]);
scale_mode = getFieldDef(pars,'scale_mode',[]);
mean_mode  = getFieldDef(pars,'mean_mode',[]);
norm_sep   = getFieldDef(pars,'norm_sep',0);
scale      = getFieldDef(pars,'scale',[]);
base       = getFieldDef(pars,'base',[]);

if     mode==1 && isempty(D.label),     error('must have ''label'' for train');
elseif mode==2 && isempty(weight),      error('must have ''weight'' for test');      end


%% Add path of SLR (if needed):
str = which('slr_learning');
if isempty(str)
    dirname = uigetdir(pwd,'Select ''SLR1.2.1alpha'' directory');
    if isequal(dirname,0)
        error('Can''t find ''SLR''');
    end
    addpath(dirname);
end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    fprintf('\n mode:    \t%-4d',mode);
    if verbose>=2
        fprintf('\n conds:   \t[%s]',conds);
        fprintf('\n # ix_eff:\t%-4d',length(ix_eff));
    end
    fprintf('\n');
end


%% Fix data input for SLR:
[label, conds2] = reIndex(D.label,[],conds);
inds            = ismember(label,conds2);
label2          = label(inds);
data2           = D.data(inds,:);
num_samples     = length(label2);


%% Test mode:
if mode==2
    % normalize:
    if ~isempty(scale_mode) && ~isempty(mean_mode)
        if norm_sep==0
            data2 = normalize_feature(data2, scale_mode, mean_mode, scale, base);
        else
            data2 = normalize_feature(data2, scale_mode, mean_mode);
        end
    end
    
    if num_class==2
        [pred, dec_val] = calc_label(data2, [zeros(size(data2,2),1) weight]);
    else
        [pred, dec_val] = calc_label(data2, weight);
    end
    num_correct = sum(pred==label2);
    accur       = num_correct / num_samples * 100;
    if verbose,     fprintf(' Answer correct in test: %g%%\n',accur);       end


%% Train mode:
else
    % normalize:
    if ~isempty(scale_mode) && ~isempty(mean_mode)
        [data2, scale, base] = normalize_feature(data2, scale_mode, mean_mode);
        pars.scale           = scale;
        pars.base            = base;
    end
    
    if num_class==2
        if isempty(ax0)
            [weight, ix_eff] = slr_learning(label2, data2, @linfun, 'reweight','OFF', 'nlearn',nlearn, 'amax',amax, 'wdisplay','off');
        else
            [weight, ix_eff] = slr_learning(label2, data2, @linfun, 'reweight','OFF', 'nlearn',nlearn, 'ax0',ax0, 'amax',amax, 'wdisplay','off');
        end
        [pred, dec_val] = calc_label(data2, [zeros(size(data2,2),1) weight]);
    else
        weight = zeros(size(data2,2),num_class);
        ix_eff = cell(num_class, 1);
        for itc=1:num_class
            label_temp              = zeros(length(label2),1);
            label_temp(label2==itc) = 1;    % 1 for class itc, 0 otherwise
            if isempty(ax0)
                [ww, ix] = slr_learning(label_temp, data2, @linfun, 'reweight','OFF', 'nlearn',nlearn, 'amax',amax, 'wdisplay','off');
            else
                [ww, ix] = slr_learning(label_temp, data2, @linfun, 'reweight','OFF', 'nlearn',nlearn, 'ax0',ax0, 'amax',amax, 'wdisplay','off');
            end
            weight(:,itc) = ww;
            ix_eff{itc}   = ix;
        end
        [pred, dec_val] = calc_label(data2, weight);
    end
    
    pars.weight = weight;
    pars.ix_eff = ix_eff;
    
    num_correct = sum(pred==label2);
    accur       = num_correct / num_samples * 100;
    if verbose,     fprintf(' Answer correct in train: %g%%\n',accur);      end
end


%% Return results:
results.model   = mfilename;
results.label   = D.label;
results.weight  = weight;
results.dec_val = dec_val;
results.pred    = conds(pred);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
