function [labels_samples, runSampInds, blockSampInds, stim_patterns, run_labels, block_labels] = fmri_blockToTrialLabels_visRecon(blockLabels, sampsPerBlock, stim_patterns_cells, labelsRest)
% [labels_samples, runSampInds, blockSampInds] = fmri_blockToSampLabels(blockLabels, sampsPerBlock, blockTimes, TR)
%
% Generates labels_samples, runSampInds, and blockSampInds, given either:
% (1) blockLabels and sampsPerBlock OR
% (2) blockTimes, TR, and (1), for which it uses blockTimes/TR instead of sampsPerBlock
%
% Inputs:
%	blockLabels	- a 2D [R x B] matrix of block labels (R = nRun, B = nBlocksPerRun)
%	sampsPerBlock	- # of samples per block
% Optional:
%	blockTimes		- a 2D [R x B] matrix of corresponding times (secs!) of each block
%	TR				- # of secs per sample (1 trial = 1 volume = 1 sample), must exist if blockTimes does
% Outputs:
% 	labels_samples	- [1 x nSamps] task labels for each sample
% 	runSampInds     - [2 x nRuns] begin (row 1) and end samples for each run
% 	blockSampInds	- [2 x nRuns*nBlocksPerRun] begin (row 1) and end samples for each block
% Key:
%	nChans = # Channels, signals; voxels for fMRI; sensors for EEG; ~ space, patterns
%	nSamps = # Samples; nTRs, nVols, nSamps for fMRI (not MEG); ~ time
%
% Example:
%	>> [labels_samples, D.ti_run_sampInds, D.ti_block_sampInds] = ...
%				fmri_blockToSampLabels(D.labels_runs_blocks, D.ti_samples_per_block);
%
% Status: basic testing
%
% Created  By: Alex Harner (1),	alexh@atr.jp	06/04/18
% Modified By: Alex Harner (1),	alexh@atr.jp	06/06/20
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
%
% modified by Yoichi Miyawaki <yoichi_m@atr.jp>, 06/08/03
% comment: this function set up stimulus label information so that it
% matches to data sample matrix. Some parts of this code can be more optimized and cleaned up.
%


useTimes = 0;
% blockTimes option:
if exist('blockTimes','var')==1,
    useTimes = 1;
    blockTimes = round(blockTimes/TR);	% convert block times (secs) to samples
end
% blockLabels and loop limits:
nRuns         = size(blockLabels,1);
for i=1:nRuns
    nBlocksPerRun(i) = length(blockLabels{i});
end
% Make sampsPerBlock same size as blockLabels, repmat as necessary:



%%% extract target stimulus, including 'rest' volumes
labels_samples = [];
stim_patterns = [];
run_labels = [];
block_labels= [];
[Yresolution,Xresolution,dummy]=size(stim_patterns_cells{1});

for i = 1:nRuns

    k=1;
    for j=1:nBlocksPerRun(i),
        if ismember(blockLabels{i}(j), labelsRest)
			% AMH: to discriminate between 0 within stim vs. 0 within blank (set to -1)
       %     tmp(:,:,j) = zeros(Yresolution,Xresolution);
			tmp(:,:,j) = -1*ones(Yresolution,Xresolution);
        else
try
            tmp(:,:,j) = stim_patterns_cells{i}(:,:,k);
            k = k + 1;
catch
    keyboard
    end
        end
    end

    tmpStimVec = []; tmpLabelVec = []; tmpBlockLabelVec = [];
    for j=1:length(sampsPerBlock{i})
		tmpStim = tmp(:,:,j);
		tmpStim = tmpStim(:);
%-		tmpStim = reshape(tmpPat,1,[prod(size(tmpPat))]);
        tmpStimVec  = [tmpStimVec  repmat(tmpStim,1,sampsPerBlock{i}(j))];
        tmpLabelVec = [tmpLabelVec repmat(blockLabels{i}(j),1,sampsPerBlock{i}(j))];
        tmpBlockLabelVec = [tmpBlockLabelVec; repmat(j,sampsPerBlock{i}(j),1)];
        
        if i == 1
            if j == 1
                blockSampInds(1, j) = 1;
            else
                blockSampInds(1, j) = blockSampInds(2, j - 1) + 1;
            end
            blockSampInds(2, j) = blockSampInds(1, j) + sampsPerBlock{i}(j) - 1;
        else
            blockSampInds(1,sum(nBlocksPerRun(1:i-1)) + j) = blockSampInds(2,sum(nBlocksPerRun(1:i-1)) + j - 1) + 1;
            blockSampInds(2,sum(nBlocksPerRun(1:i-1)) + j) = blockSampInds(1,sum(nBlocksPerRun(1:i-1)) + j) + sampsPerBlock{i}(j) - 1;            
        end
    end
        
    runSampInds(1,i) = length(labels_samples) + 1;
    runSampInds(2,i) = runSampInds(1,i) + length(tmpLabelVec) - 1;
    
    labels_samples = [labels_samples tmpLabelVec];
    stim_patterns = [stim_patterns tmpStimVec];
    run_labels = [run_labels; repmat(i,sum(sampsPerBlock{i}),1)];
    block_labels = [block_labels; tmpBlockLabelVec];
    
end


