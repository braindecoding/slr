function fNames = fmri_makeFileNames(baseName, D)
%fmri_makeFileNames - makes an array of fileNames to read given baseName, runs, vols.
%fNames = fmri_makeFileNames(baseName, D)
%
% Inputs:
%	baseName - base file name, e.g. 'rHS041209'
%	D.ti_run_sampInds   - [2 x nRuns] begin (row 1) and end samples for each run
%	D.fMRI.run_names{run} - array of run labels, e.g. {'a','b', ...}
%	D.fMRI.begin_vols(run)- array of 1st vols of each run
% Output:
%	fNames   - cell array of fileNames to volumes to be read
% Note:
%	1 sample = 1 TR = 1 volume ~= 1 trial for fMRI
%
% Example: see ..scripts/make_fmri_all_janken.m
%
% Status: basic testing
%
% Created  By: Alex Harner (1),	alexh@atr.jp	06/04/18
% Modified By: Alex Harner (1),	alexh@atr.jp	06/08/28
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Fix things:
[rows,nRuns] = size(D.ti_run_sampInds);
if rows==1, D.ti_run_sampInds(2,:) = D.ti_run_sampInds(1,:); end;

% Init fNames:
fNames = cell(D.ti_run_sampInds(2,end),1);

% Expand ..begin_vols:
beginVols = D.fMRI.begin_vols;
if size(beginVols,2)==2, beginVols'; end;
beginVols = expandPat(beginVols, [1 D.Gen.runs_max]);


atri = 1;
endSampLast = 0;
% Loop through runs:
for run = 1:nRuns,
	endSamp = D.ti_run_sampInds(2,run);	% absolute end sample of each run
	nSamps = endSamp - endSampLast;			% relative end sample
	% Loop through samples per run:
	for rtri = 1:nSamps,
		cRun = D.fMRI.run_names{run};		% run name
		vol = rtri + beginVols(run) - 1;	% vol number
		cVol = sprintf('%04d', vol);		% vol name
		fNames{atri} = [baseName cRun cVol '.img'];	% file name
		atri = atri+1;
	end;
	endSampLast = endSamp;
end;
