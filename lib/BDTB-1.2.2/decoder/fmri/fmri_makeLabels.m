function [label, label_type, label_def] = fmri_makeLabels(prtcl)
% fmri_makeLabels - makes labels for each sample from 'prtcl'
% [label, label_type, label_def] = fmri_makeLabels(prtcl)
%
% Input:
%   prtcl.labels_runs_blocks - labels of each run ({runs}[label dim x block] format)
%   prtcl.samples_per_label  - number of samples per label ([1 x 1], [1 x block] or {runs}[1 x block] format)
% Output:
%   label                    - multi-dimensional condition labels of each sample ([time x label dim] format)
%   label_type               - name of each labeling type ({label dim} format)
%   label_def                - name of each condition ({label dim}{condition} format)
%
% Calls:
%   fmri_makeLabelsSub - make labels from 'samples_per_block' with [1 x block] format
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('prtcl','var') || isempty(prtcl)
    error('''prtcl'' should be specified');
end

prtcl = getFieldDef(prtcl,'prtcl',prtcl);   % unnest, if need

labels_runs_blocks = getFieldDef(prtcl,'labels_runs_blocks',{});
if ~iscell(labels_runs_blocks)
    labels_runs_blocks = {labels_runs_blocks};
end
if ~iscell(labels_runs_blocks{1})
    labels_runs_blocks = {labels_runs_blocks};
end

samples_per_label = getFieldDef(prtcl,'samples_per_label',{1});
if ~iscell(samples_per_label)
    samples_per_label = {samples_per_label};
end
if ~iscell(samples_per_label{1})
    samples_per_label = {samples_per_label};
end

label_type = getFieldDef(prtcl,'labels_type',{});
if ~iscell(label_type)
    label_type = {label_type};
end
label_def = getFieldDef(prtcl,'labels_def',{});
if ~iscell(label_def)
    label_def = {label_def};
end
if ~iscell(label_def{1})
    label_def = {label_def};
end


%% Make labels:
fprintf('\nMaking labels:\n');

num_ltype = length(labels_runs_blocks);
num_run   = length(labels_runs_blocks{1});
label     = cell(1,num_ltype);
for itt=1:num_ltype
    if length(samples_per_label{itt})==1
        if length(samples_per_label{itt}{1})==1 % {1 x 1}
            label{itt} = reshape(repmat([labels_runs_blocks{itt}{:}],[samples_per_label{itt}{1},1]),1,[])';
        else                                    % {[1 x block]}
            if size(labels_runs_blocks{itt}{1},2)~=length(samples_per_label{itt}{1})
                error('''labels_runs_blocks'' and ''samples_per_label'' don''t have the same block num');
            end
            num_samples = num_run * sum(samples_per_label{itt}{1});
            label{itt} = fmri_makeLabelsSub(cell2mat(labels_runs_blocks{itt}),samples_per_label{itt}{1},num_samples)';
        end
    else                                        % {runs}[1 x block]
        if length(samples_per_label{itt})~=num_run
            error('''labels_runs_blocks'' and ''samples_per_label'' don''t have the same run num');
        end
        label{itt} = cell(num_run,1);
        for itr=1:num_run
            if size(labels_runs_blocks{itt}{itr},2)~=length(samples_per_label{itt}{itr})
                error('''labels_runs_blocks'' and ''samples_per_label'' don''t have the same block num');
            end
            num_samples = sum(samples_per_label{itt}{itr});
            label{itt}{itr} = fmri_makeLabelsSub(labels_runs_blocks{itt}{itr},samples_per_label{itt}{itr},num_samples);
        end
        label{itt} = [label{itt}{:}]';
    end
end
label = [label{:}];
