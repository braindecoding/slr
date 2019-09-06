% fmri_makeLabelsSub - makes labels for each sample
% label = fmri_makeLabelsSub(labels_runs_blocks, samples_per_block, num_samples)
%
% This function is used to make label, when 'samples_per_block' isn't [1x1].
%
% Input:
%   labels_runs_blocks - labels of each run ([run x block] format)
%   samples_per_block  - number of samples per block ([1 x 1] or [1 x block] format)
% Output:
%   label              - condition labels of each sample ([time x 1] format)
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%-This is merely the help file for the compiled routine
error('fmri_makeLabelsSub.c not compiled');
