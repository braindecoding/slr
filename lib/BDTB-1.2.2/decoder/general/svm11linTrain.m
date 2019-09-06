function weight = svm11linTrain(data, label)
% svm11linTrain - calculates weights and bias
%
% Input:
%   data   - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   label  - condition labels of each sample ([time x 1] format)
% Output:
%   weight - weights and bias
%
% Calls:
%   svmSinglePairWeights - calculates weights and bias for all pair by 'OSU SVM'
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check pars:
if ~exist('data','var') || isempty(data) || ~exist('label','var') || isempty(label)
    error('''data'' and ''label'' must be specified');
end


%% Calc weights:
used_conds = unique(label);
weight     = zeros(size(data,2)+1,length(used_conds));

for itt=1:length(used_conds)        % target class
    target_class = used_conds(itt);
    
    weights_class = zeros(size(data,2)+1,length(used_conds));
    for itc=1:length(used_conds)    % compared class
        if itt~=itc
            compare_class = used_conds(itc);
            
            D    = struct('data',data,'label',label);
            pars = struct('conds',[target_class compare_class],'verbose',0);
            D    = selectConds(D,pars);
            
            labels_temp                         = D.label;
            D.label(labels_temp==target_class)  = 1;
            D.label(labels_temp==compare_class) = -1;  % must be '-1'
            weights_bias                        = svmSinglePairWeights(D.data,D.label);
            weights_class(:,itc)                = weights_bias;
        end
    end
    
    weights_class(:,itt) = [];
    weight(:,itt)        = mean(weights_class,2);
end
