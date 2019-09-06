function [design, design_type] = fmri_makeDesign(prtcl, label)
% fmri_makeDesign - makes design matrix for run and block
% [design, design_type] = fmri_makeDesign(prtcl, label)
%
% Input:
%   prtcl.labels_runs_blocks - labels of each run ([run x block] format)
%   prtcl.samples_per_block  - number of samples per block ([1 x 1], [1 x block] or {runs}[1 x block] format)
%   prtcl.samples_per_label  - number of samples per label ([1 x 1], [1 x block] or {runs}[1 x block] format)
%   label                    - condition labels of each sample ([time x 1] format)
%                              if absent, call 'fmri_makeLabels'
% Output:
%   design                   - design matrix of experiment ([time x dtype] format)
%   design_type              - name of each design type ({1 x dtype] format)
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('prtcl','var') || isempty(prtcl)
    error('''prtcl'' should be specified');
end
prtcl = getFieldDef(prtcl,'prtcl',prtcl);   % unnest, if needed

if ~exist('label','var') || isempty(label)
    label = fmri_makeLabels(prtcl);
else
    label = getFieldDef(label,'label',label);	% unnest, if needed
end

labels_runs_blocks = getFieldDef(prtcl,'labels_runs_blocks',{});
if ~iscell(labels_runs_blocks)
    labels_runs_blocks = {labels_runs_blocks};
end
if ~iscell(labels_runs_blocks{1})
    labels_runs_blocks = {labels_runs_blocks};
end

samples_per_block = getFieldDef(prtcl,'samples_per_block',1);
if ~iscell(samples_per_block)
    samples_per_block = {samples_per_block};
end

samples_per_label = getFieldDef(prtcl,'samples_per_label',{1});
if ~iscell(samples_per_label)
    samples_per_label = {samples_per_label};
end
if ~iscell(samples_per_label{1})
    samples_per_label = {samples_per_label};
end


%% Make design matrix:
fprintf('\nMaking design matrix:\n');

num_runs    = length(labels_runs_blocks{1});
num_samples = length(label);
design      = zeros(length(label),2);
design_type = {'run', 'block'};

% block:
if length(samples_per_block)==1
    if length(samples_per_block{1})==1  % [1 x 1]
        num_blocks = num_samples / samples_per_block{1};
        design(:,2) = reshape(repmat(1:num_blocks,samples_per_block{1},1),[],1);
    else                                % [1 x block]
        num_blocks  = length(samples_per_block{1}) * num_runs;
        design(:,2) = fmri_makeLabelsSub(reshape(1:num_blocks,[],num_runs)',samples_per_block{1},num_samples)';
    end
else                                    % {runs}[1 x block]
    samples_per_block = [samples_per_block{:}];
    num_blocks        = length(samples_per_block);
    design(:,2)       = fmri_makeLabelsSub(1:num_blocks,samples_per_block,num_samples)';
end

% run:
if length(samples_per_label{1})==1
    if length(samples_per_label{1}{1})==1  % [1 x 1]
        samples_per_run = samples_per_label{1}{1} * size(labels_runs_blocks{1}{1},2);
    else                                % [1 x block]
        samples_per_run = sum(samples_per_label{1}{1});
    end
    design(:,1) = reshape(repmat(1:num_runs,samples_per_run,1),[],1);
else                                    % {runs}[1 x block]
    samples_per_run = cellfun(@sum,samples_per_label{1})';
    design(:,1)     = fmri_makeLabelsSub(1:num_runs,samples_per_run,num_samples)';
end
