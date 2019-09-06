function predictVal = predict_smlr(decoder,smpl,mode)
%
% --- Input
% decoder :  structure
% smpl    :  [nSmpl x nVoxel]
%
% --- Output
% predictVal :  [nSmpl x 1]
%
% 2007/01/05 Hajime Uchida
% 2008/01/22 Yoichi Miyawaki - output class value of the highest probability
% 2008/08/01 Yoichi Miyawaki - implement mode switch
% 2012/05/01 Yoichi Miyawaki - modified data dimension

num_samples = size(smpl,1);
num_class = numel(decoder.parm.conds);

parm = decoder.parm.slr121a;

kernel_func = getFieldDef(parm,'kernel_func','none');
R = getFieldDef(parm,'R',0);      % Gaussian width parameter
xcenter = getFieldDef(parm,'xcenter',[]);

normMeanMode  = getFieldDef(parm,'normMeanMode','feature'); % edYM
normScaleMode = getFieldDef(parm,'normScaleMode','feature'); % edYM
normMean  = getFieldDef(parm,'normMean',0);
normScale = getFieldDef(parm,'normScale',1);
normMode = getFieldDef(parm,'normMode','training'); % edYM

weight = getFieldDef(parm,'weight',[]);
ix_eff  = getFieldDef(parm,'ix_eff',[]);

if strcmp(normMode,'test')
    if size(smpl,1) == 1 && strcmp(normMeanMode,'each')
      fprintf('\nWARNINIG: data sample size is 1. this normalization convnert all features into 0.\n');
    end
    smpl = normFeature(smpl,normMeanMode,normScaleMode);
  elseif strcmp(normMode,'training')
    smpl = normFeature(smpl,normMeanMode,normScaleMode,normMean,normScale);
  else
    error('normalization mode error');
  end  

if num_class==2
    % binomial
    if strcmp(kernel_func,'none')
        Phi = smpl;
    else
        Phi = slr_make_kernel(smpl,kernel_func,xcenter,R);
    end
    Phi = [Phi ones(num_samples,1)];

    if isempty(ix_eff)
        pred       = zeros(num_samples,1);
        dec_val    = zeros(num_samples,1);
    else
        if size(weight,1)>size(Phi,2),     
            weight = weight(ix_eff);      
        end
        dec_val = 1 ./ (1+exp(-Phi*weight));
        pred = double(dec_val > 0.5);
    end
else
    % multinomial
    Phi = [smpl ones(num_samples,1)];
    [tmp, label_est_te] = max(Phi*weight,[],2);

    eY = exp(Phi*weight); % num_samples*num_class
    dec_val = eY ./ repmat(sum(eY,2), [1, num_class]); % num_samples*num_class
    pred = decoder.parm.conds(label_est_te)';
end

%% calc expected value
if isfield(decoder, 'labelList')

    switch mode
      case 'maxProbLabel'
        predictVal = pred; %% edYM
      case 'exProb'
        if num_class == 2
           predictVal = dec_val; %% edYM
        else            
            predictVal = dec_val*decoder.labelList';
        end
      otherwise
        error('Invalid prediction mode: should be maxProbLabel or exProb');
    end

else
  error('ERROR: incompatible to non-labeled data -- in predict_smlr.m');
end


