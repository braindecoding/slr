function res = resultsSummary(res)
% Finds freq_table and correct_per from results structs, and add them at the end of 'res'
% res = resultsSummary(res)
%
% Inputs:
%   res{}.pred            - predicted labels
%   res{}.label           - correct labels
% Output:
%   res{:,end}.freq_table  - frequency table; [# nConds x # nConds] matrix 
%	res{:,end}.correct_per - total percent correct rate
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('res','var') || isempty(res),     error('Wrong vars');	end

[num_models, num_dataset] = size(res);
num_preds_data            = length(res{1}.pred);


%% Make res all:
pred  = zeros(num_dataset*num_preds_data,num_models);
label = zeros(num_dataset*num_preds_data,1);

for itd=1:num_dataset

    label((itd-1)*num_preds_data+1:itd*num_preds_data) = res{1,itd}.label;

    for itm=1:num_models
        pred((itd-1)*num_preds_data+1:itd*num_preds_data,itm) = res{itm,itd}.pred;
    end
end



%% Calc summary
freq_table  = cell(num_models,1);
correct_per = cell(num_models,1);
for itm=1:num_models
    [freq_table{itm}, correct_per{itm}] = freqTableFromLabels(label,pred(:,itm));
end


%% Add summary
res = [res cell(num_models,1)];
for itm=1:num_models
    model = res{itm,1}.model;
    
    res{itm,end} = struct('model',model,'pred',pred(:,itm),'label',label,...
                          'freq_table',freq_table{itm},'correct_per',correct_per{itm});
end
