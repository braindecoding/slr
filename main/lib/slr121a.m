function [results, pars] = slr121a(D, pars)
%slr121a - performs multinomial SLR using SLR1.2.1alpha, either train or test
%[results, pars] = slr121a(D, pars)
%
% Input:
%   D,data        - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label       - condition labels of each sample ([time x 1] format); only [] for test mode
% Optional:
%   pars.conds    - conditions to be tested (should be 2 for binomial)
%   pars.mode     - train=1 (make weight) or test=2 mode (use weight)
%   pars.verbose  - [1..3] = print detail level; 0 = no printing (default=0)
% SLR pars:
%   .R            - SLR Gaussian kernel width; 0 = linear version (default)
% SLR pars for test:
%   .weight      - SLR weight; for linear, length of chans (mostly zeros)
%   .ix_eff       - index of non-zero weight; for linear, chans used	
%   .xcenter      - center of kernels (in original space?)
%   .parm         - struct of parameter in learning
% SLR pars for train:
%   .nlearn       - # of learning
%   .ax0          - Initial value of relevance parameter ax
%   .amax         - Truncation criteria. Parameters whose relevance parameter is larger 
%                   than this value are eliminated from further iterations
% Output:
%   results - struct contain ANY result as a field, typically:
%       .model    - name of this function
%       .pred    - predicted label
%       .label   - defined label
%       .dec_val - decision value
%       .weight  - weight and bias
%	pars          - modified pars, new weight will be added here
%
% Calls:
%   selectDir_gui         - outputs dialog-box to select directory with GUI
%   SLR1.23.1.alpha, (c) >>>
%       slr_make_kernel   - make explanatory matrix consisting of Gaussian kernel
%       slr_learning      - learning parameters of ARD-sparse logistic regression model
%       slr_count_correct - count the number of correct label
%       smlr_learn        - run sparse multinomial logistic regression
%
%   subfuncs for visRecon
%       smlr_test         - predict using sparse multinomial logistic regression
%
% Created   By: Alex Harner (1),	  alexh@atr.jp      06/10/23
% Modified  By: Alex Harner (1),	  alexh@atr.jp      06/10/30
% With help of: Okito Yamashita (1),  oyamashi@atr.jp
% Modified  By: Hajime Uchida (1),    hajime-u@atr.jp   06/11/20
% Modified  By: Hajime Uchida (1),    hajime-u@atr.jp   06/12/26
% Modified  By: Satoshi MURATA (1),   satoshi-m@atr.jp  08/10/10
% modified by yoichi_m, added feature normalize
% modified by yoichi_m, modified for compatibility for reconstruction 12/04/29
% renamed to slr121a.m by yoichi_m for compatibility for SLR1.2.1alpha 12/04/29
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
% NOTE: slr121a.m is largely based on slr_sm_norm.m, originally written by the above contributors


%% Check and get pars:
if exist('D','var')==0 || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
conds   = getFieldDef(pars,'conds',unique(D.label)); % edYM
mode    = getFieldDef(pars,'mode',1);
verbose = getFieldDef(pars,'verbose',0);


% YM
normMeanMode  = getFieldDef(pars,'normMeanMode','feature'); % edYM
normScaleMode = getFieldDef(pars,'normScaleMode','feature'); % edYM
normMean  = getFieldDef(pars,'normMean',0);
normScale = getFieldDef(pars,'normScale',1);
normMode = getFieldDef(pars,'normMode','training'); % edYM

nstep = getFieldDef(pars,'nstep',10); % edYM


num_class = length(conds);

% SLR pars:
if num_class==2
    % binomial only
    R       = getFieldDef(pars,'R',0);      % Gaussian width parameter
    xcenter = getFieldDef(pars,'xcenter',[]);
    kernel_func = getFieldDef(pars,'kernel_func','none');
else
    % multinomial only
    parm    = getFieldDef(pars,'parm',[]);
    nlearn  = getFieldDef(pars,'nlearn',150);
    ax0     = getFieldDef(pars,'ax0',[]);
    amax    = getFieldDef(pars,'amax',1e8);
end
weight = getFieldDef(pars,'weight',[]);
ix_eff  = getFieldDef(pars,'ix_eff',[]);

if     mode==1 && isempty(D.label),    error('must have ''label'' for train');
elseif mode==2 && isempty(weight),     error('must have ''weight'' for test');      end


%% Add path of SLR (if needed):
%str = which('slr_learning');
%if isempty(str)
%    dirname = selectDir_gui(pwd,'Select ''SLR'' directory');
%    if isempty(dirname),    error('Can''t find ''SLR''');     end
%    addpath(dirname);
%end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n mode:    \t%-4d',mode);
        fprintf('\n conds:   \t[%s]',num2str(conds)); % edYM
        fprintf('\n # ix_eff:\t%-4d',length(ix_eff));
        if num_class==2
            fprintf('\n R    :   \t%-4d',R);
        end
    end
    fprintf('\n');
end


%% Fix data input for SLR:
[label, conds2] = reIndex(D.label,[],conds);
if num_class==2     % binomial
    label = label - 1;    % re-indexes to 0,1,...
    conds2 = [0 1];
end
ind        = ismember(label,conds2);
label2     = label(ind);
data2       = D.data(ind,:);
num_samples = length(label2);


%% Test mode:
if mode==2
    if strcmp(normMode,'test')
        if size(data2,1) == 1 && strcmp(normMeanMode,'each')
            fprintf('\nWARNINIG: data sample size is 1. this normalization convnert all features into 0.\n');
        end
        data2 = normFeature(data2,normMeanMode,normScaleMode);
    elseif strcmp(normMode,'training')
        data2 = normFeature(data2,normMeanMode,normScaleMode,normMean,normScale);
    else
        error('normalization mode error');
    end  
    
    % binomial
    if num_class==2
        if strcmp(kernel_func,'none')     
            Phi = data2;
        else
            Phi = slr_make_kernel(data2,kernel_func,xcenter,R);
        end
        Phi = [Phi ones(num_samples,1)];
    
        if isempty(ix_eff)
            szl         = size(label2);
            num_correct = 0;
            pred       = zeros(szl);
            dec_val    = zeros(szl);
        else
            if size(weight,1)>size(Phi,2),    
                weight = weight(ix_eff);      
            end
            [num_correct, pred, dec_val] = slr_count_correct(label2,Phi,weight);
        end
    
    % multinomial
    else
        
        % Test
        Phi = [data2 ones(num_samples,1)];
        [tmp, label_est_te] = max(Phi*weight,[],2);

        if ~isempty(label2)
            num_correct  = sum(label_est_te==label2);
            errTable_te  = slr_error_table(label2, label_est_te);
        else
            errTable_te = [];
        end
        eY = exp(Phi*weight); % num_samples*num_class
        dec_val = eY ./ repmat(sum(eY,2), [1, num_class]); % num_samples*num_class
        pred = conds(label_est_te)';
    end    

    correct_rate = num_correct / num_samples * 100;    
    if verbose,     
        fprintf(' Answer correct in test: %g%%\n',correct_rate);       
    end

%% Train mode:
else
  
  %%% normalize
  [data2 normMean normScale] = normFeature(data2,normMeanMode,normScaleMode);

  if num_class==2
      % binomial
      if strcmp(kernel_func,'none'),
          Phi = data2;
      else
          Phi = slr_make_kernel(data2,kernel_func,xcenter,R);
      end
      Phi = [Phi ones(num_samples,1)]; %% add bias term
      
      [weight, ix_eff] = slr_learning(label2,Phi,@linfun,'reweight','OFF','wdisplay','off','nstep',nstep);
      
      if isempty(ix_eff)
          szl         = size(label2);
          num_correct = 0;
          pred       = zeros(szl);
          dec_val    = zeros(szl);
      else
          [num_correct, pred, dec_val] = slr_count_correct(label2,Phi,weight);
      end
      
      correct_rate = num_correct/num_samples*100;

      pars.normMean = normMean;
      pars.normScale = normScale;
      
      pars.weight = weight;
      pars.ix_eff  = ix_eff;

      if strcmp(kernel_func,'Gaussian')
          pars.xcenter = data2(ix_eff(1:end-1),:);    
      end
    
  else
      % multinomial
      Phi = [data2 ones(num_samples,1)]; %% add bias term 
      num_feat = size(Phi,2); %% number of features (#voxel + bias)
      
      % learning parameters
      [weight, ix_eff] = ...
          smlr_learning(label2,Phi,num_feat,'nlearn',nlearn,'amax',amax,'wdisplay','off','nstep',nstep);
      
      % set ix_eff_all and removing bias coef
      [ixf, ixc] = ind2sub([num_feat, num_class], ix_eff);
      ix_eff_all = cell(1,num_class);
      for cc = 1 : num_class
          ix_eff_all{cc} = setdiff(ixf(ixc==cc), num_feat);
      end
      
      % reshape weight
      weight = reshape(weight, [num_feat, num_class]);
      
      [tmp, label_est_tr] = max(Phi*weight,[],2);
      
      pred = conds(label_est_tr)';        
      correct_rate = sum(label_est_tr == label2)/num_samples*100;
      
      eY = exp(Phi*weight); % num_samples*num_class
      dec_val  = eY ./ repmat(sum(eY,2), [1, num_class]); % num_samp*num_class
      
      errTable = slr_error_table(label2, label_est_tr);
      
      num_correct = sum(label_est_tr==label2);
      
      pars.normMean = normMean;
      pars.normScale = normScale;
      
      pars.parm    = parm;
      pars.weight = weight;
      pars.ix_eff  = ix_eff;
  end
  
  if verbose,     
      fprintf(' Answer correct in train: %g%%\n',correct_rate);        
  end
end

%% Return results:
results.model   = mfilename;
results.label   = D.label;
results.weight  = weight;
results.dec_val = dec_val;
results.xyz     = D.xyz;
results.pred    = pred;

%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
end
