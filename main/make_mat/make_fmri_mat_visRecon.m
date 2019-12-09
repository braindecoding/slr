% Script for making <id>_fmri_roi*_v6 format data for visual image reconstruction
%
% Original  By: Alex Harner (1),     alexh@atr.jp	06/06/27
% Rewritten By: Yoichi Miyawaki (1), yoichi_m@atr.jp	06/10/10
% Modified By: Alex Harner (1),	     alexh@atr.jp	06/10/16
% Modified By: Shigeyuki Ikeda (2),  shigeyuki-i@is.naist.jp    12/01/24
% Modified By: Yoichi Miyawaki (1),  yoichi_m@atr.jp    12/04/29
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group
% (2) NAIST Information science MathematicalInfo Labs
%
% Output:

clear all;

saveFnamePostFix = '-1to2mm_Th1_fromAna_s1071119ROI_resol10';

scriptName = 'make_fmri_roi_visRecon';
fprintf('\n============================================================');
fprintf('\n%s\n', scriptName);

%============================================================
%% option to print details
verbose = 0;

dataPath = '../data/';

%% Library paths:
libRootPath = '../../lib/';
libLocalPath = '../lib/';
addpath(genpath([libRootPath 'BDTB-1.2.2/']));
addpath(genpath([libRootPath 'spm5/']));
addpath(genpath(libLocalPath));

%------------------------------
%% General & Data paths:

% Name of the experiment:
P.Gen.experiment = 'visual reconstruction fMRI experiment (test new data format)';

% Subject ID
sbjId = 's1';
P.Gen.sbjId = sbjId;

% Set path to resliced data
P.Gen.path_data = [dataPath 's1_resliced/'];

% Total number of runs:
P.Gen.runs_max = 20 + 12;  %% train + test

%------------------------------
%% fMRI-specific:
% TR = secs per sample (1 sample = 1 TR = 1 volume for fMRI):
P.fMRI.TR = 2;

% first vol of each run:
P.fMRI.begin_vols = 5;

% Volume to which the others are aligned:
P.fMRI.vol_align = 5;

% Number of train samples in a run.
nTrainSmpl = 22;

% Maps task run numbers 1,2,... to file run letters:
P.expList{1} = {'a' 'b' 'd' 'e' 'g' 'h' 'j' 'k' 'm' 'n', ...
		'p' 'q', 's' 't' 'v' 'w' 'y' 'z' 'ab' 'ac'}; % for training
P.expList{2} = {'c' 'f','r','u'}; % for figure
P.expList{3} = {'i','x'}; % for NEURO small
P.expList{4} = {'l','aa'}; % for NEURO long
P.expList{5} = {'o','ad','ae','af'}; % for NEURO thin
P.fMRI.run_names = [P.expList{1}, P.expList{2}, P.expList{3}, ...
		    P.expList{4}, P.expList{5}];

P.expListStimId{1} = [1:20]; % for training
P.expListStimId{2} = [1:4]; % for figure
P.expListStimId{3} = [1:2]; % for NEURO
P.expListStimId{4} = [1:2]; % for NEURO
P.expListStimId{5} = [1:4]; % for NEURO

nTrainRuns = length(P.expList{1});
nTestFigRuns  = length(P.expList{2});
nTestNeuSRuns  = length(P.expList{3});
nTestNeuSLRuns  = length(P.expList{4});
nTestNeuSTRuns  = length(P.expList{5});

%------------------------------
%% Labels:

% P.labels_names - cell array containing string names of labels,
% were each label number maps to a column name:
stimDataDir = [dataPath '/' sbjId '_stimulusData/'];

%%% test stim types
P.labels_names = {
    'test pre rest'                  %  1
    'test rest';                     %  2
    'square10x10'                      %  3
    'smallFrame10x10'
    'largeFrame10x10'
    'plus10x10'
    'cross10x10'
    'Ns' %% neuro
    'Es'
    'Us'
    'Rs'
    'Os'
    'Nsl' %% neuro
    'Esl'
    'Usl'
    'Rsl'
    'Osl'
    'Nst' %% neuro
    'Est'
    'Ust'
    'Rst'
    'Ost'
    'training pre rest';             % 23
    'training rest';                 % 24
    };

%% labels_names for training block
labelNameOffset = length(P.labels_names);
for i=1:nTrainSmpl*length(P.expList{1})
    patternID = i + labelNameOffset;
    P.labels_names{patternID,1} = ['p' num2str(patternID)];
end

P.labels_rest = [1 2 23 24];
P.labels_rest_pre = [1 23];

P.ti_blocks_per_run = [repmat(nTrainSmpl, 1, nTrainRuns) ...    % training
                       repmat(10, 1, nTestFigRuns) ...   % test fig
                       repmat(10, 1, nTestNeuSRuns) ... % test neuS
                       repmat(10, 1, nTestNeuSLRuns) ... % test neuSL
                       repmat(10, 1, nTestNeuSTRuns) ... % test neuST
                       ];

onValInStimData = 153;
onVal = 1;

% P.labels_runs_blocks - a cell array with 1 cell for each run that contains
% a [1 x nBlock] matrix of labels for each block; used
% with P.ti_samples_per_block as input to fmri_blockToTrialLabels_visRecon
% to generate P.labels_samples and P.ti_*_sampInds:
k = 1; trainIdx = 1; testFigIdx = 1; testNeuSIdx = 1; testNeuSLIdx = 1; testNeuSTIdx = 1;
for i = 1:length(P.fMRI.run_names)
    %% load stim data.
    if ismember(P.fMRI.run_names{i}, P.expList{1})
        stim = load([stimDataDir sbjId '_normal_train' num2str(P.expListStimId{1}(trainIdx))]);
    elseif ismember(P.fMRI.run_names{i}, P.expList{2})
        stim = load([stimDataDir sbjId '_test' num2str(P.expListStimId{2}(testFigIdx))]);
        testFigIdx = testFigIdx + 1;
    elseif ismember(P.fMRI.run_names{i}, P.expList{3})
        stim = load([stimDataDir sbjId '_smallChar_test' num2str(P.expListStimId{3}(testNeuSIdx)) '_NEUROTPSJ']);
        testNeuSIdx = testNeuSIdx + 1;
    elseif ismember(P.fMRI.run_names{i}, P.expList{4})
        stim = load([stimDataDir sbjId '_smallCharLong_test' num2str(P.expListStimId{4}(testNeuSLIdx)) '_NEUROTPSJ']);
        testNeuSLIdx = testNeuSLIdx + 1;
    elseif ismember(P.fMRI.run_names{i}, P.expList{5})
        stim = load([stimDataDir sbjId '_smallCharThin_test' num2str(P.expListStimId{5}(testNeuSTIdx)) '_NEUROTPSJ']);
        testNeuSTIdx = testNeuSTIdx + 1;
    end
    
    if ismember(P.fMRI.run_names{i}, P.expList{1})
        order{i} = [size(stim.w.noise,3)*(trainIdx-1)+1:size(stim.w.noise,3)*trainIdx] + labelNameOffset;
        preRest = labelNameOffset - 1;
        rest = ones(size(order{i}))*(preRest + 1);
        
        order{i} = reshape([order{i}; rest],[1 2*length(order{i})]);
        order{i} = [preRest order{i}];

        patterns_tmp{i} = stim.w.noise(2:11,2:11,:);
        patterns{i} = stim.w.noise(2:11,2:11,:);
        patterns{i}(find(stim.w.noise(2:11,2:11,:) == onValInStimData)) = onVal;

        trainIdx = trainIdx + 1;
    elseif ismember(P.fMRI.run_names{i}, P.expList{2}) | ...
	  ismember(P.fMRI.run_names{i}, P.expList{3}) | ...
	  ismember(P.fMRI.run_names{i}, P.expList{4}) | ...
          ismember(P.fMRI.run_names{i}, P.expList{5})

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% check color type for s1070601
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for j = 1:length(stim.t.s)
            if j == 1
                order{i}(2*j - 1) = 1; % rest at pre-stimulus period
            else
                order{i}(2*j - 1) = 2; % rest between ON stimulus blocks
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% check type for s1070601
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            st = stim.t.s(j);
            type = stim.t.s(j).param.type;
            img = st.pattern(2:11,2:11);

            img(find(img == onValInStimData)) = onVal;
            type = strrep(type,'12x12','10x10');
            if ismember(P.fMRI.run_names{i}, P.expList{3})
                type = [type 's'];
            elseif ismember(P.fMRI.run_names{i}, P.expList{4})
                type = [type 'sl'];
            elseif ismember(P.fMRI.run_names{i}, P.expList{5})
                type = [type 'st'];
            end
            order{i}(2*j) = find(ismember(P.labels_names, type));

            patterns{i}(:,:,j) = img;
        end
        order{i}(2*j + 1) = 2; % rest at the end of run
    end
    P.labels_runs_blocks{i,1} = order{i};
    P.stim_patterns_cells{i,1} = patterns{i};
end


%------------------------------
%% Temporal Indices:
% Total number of runs:
P.Gen.runs_max = length(P.fMRI.run_names);

% Array of runs in this data file:
P.Gen.runs_in_file = 1:P.Gen.runs_max;

% Number of samples per block:
%P.ti_samples_per_block = [3];  % If constant, may be size [1x1] (as left);
% if it varies per block, then it should match labels_runs_blocks in size.
P.ti_samples_per_block = {...
    [10 repmat([3 3],1,21) 3 6]; % train1
    [10 repmat([3 3],1,21) 3 6]; % train2
    [10 repmat([3 3],1,21) 3 6]; % train3
    [10 repmat([3 3],1,21) 3 6]; % train4
    [10 repmat([3 3],1,21) 3 6]; % train5
    [10 repmat([3 3],1,21) 3 6]; % train6
    [10 repmat([3 3],1,21) 3 6]; % train7
    [10 repmat([3 3],1,21) 3 6]; % train8
    [10 repmat([3 3],1,21) 3 6]; % train9
    [10 repmat([3 3],1,21) 3 6]; % train10
    [10 repmat([3 3],1,21) 3 6]; % train11
    [10 repmat([3 3],1,21) 3 6]; % train12 
    [10 repmat([3 3],1,21) 3 6]; % train13
    [10 repmat([3 3],1,21) 3 6]; % train14
    [10 repmat([3 3],1,21) 3 6]; % train15
    [10 repmat([3 3],1,21) 3 6]; % train16
    [10 repmat([3 3],1,21) 3 6]; % train17
    [10 repmat([3 3],1,21) 3 6]; % train18
    [10 repmat([3 3],1,21) 3 6]; % train19
    [10 repmat([3 3],1,21) 3 6]; % train20
    [10 repmat([6 6],1,10)]; % test1
    [10 repmat([6 6],1,10)]; % test2
    [10 repmat([6 6],1,10)]; % test3
    [10 repmat([6 6],1,10)]; % test4
    [10 repmat([6 6],1,10)]; % NeuS
    [10 repmat([6 6],1,10)]; % NeuS
    [10 repmat([6 6],1,10)]; % NeuSL
    [10 repmat([6 6],1,10)]; % NeuSL
    [10 repmat([6 6],1,10)]; % NeuST
    [10 repmat([6 6],1,10)]; % NeuST
    [10 repmat([6 6],1,10)]; % NeuST
    [10 repmat([6 6],1,10)]; % NeuST
    };

%% Info for reading scripts (below):
% Path to raw fMRI data used in fmri_spmToMat:
P.pathRaw = P.Gen.path_data;

% Base file named used in fmri_makeFileNames:
P.baseFileName = ['ra' P.Gen.sbjId '_'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% roi setting for SPM Analyze ambil dari file yang VOX_
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Directory of ROI index & stat files:
roiDir		= [dataPath 's1_ROI/'];
%roiCellLen = 12;

roiBaseName = sprintf('s1_BAIC3T_%s_ang_dm1to2_%s_', 'LH', 'LH');
roiOrder = {'V1v', 'V2v', 'VP', 'V4v', 'V1d', 'V2d', 'V3', 'V3A'};
%roiNames_ang_LH = cell(numel(roiOrder),1);
%roifiles_ang_LH = cell(numel(roiOrder),1);
for ixRoi = 1:length(roiOrder)
  roiNames_ang_LH{ixRoi} = ['LH' roiOrder{ixRoi}];
  roifiles_ang_LH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiBaseName = sprintf('s1_BAIC3T_%s_ang_dm1to2_%s_', 'RH', 'RH');
roiOrder = {'V1v', 'V2v', 'VP', 'V4v', 'V1d', 'V2d', 'V3', 'V3A'};
%roiNames_ang_RH = cell(roiCellLen,1);
%roifiles_ang_RH = cell(roiCellLen,1);
for ixRoi = 1:length(roiOrder)
  roiNames_ang_RH{ixRoi} = ['RH' roiOrder{ixRoi}];
  roifiles_ang_RH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiBaseName = sprintf('s1_BAIC3T_%s_ecc_each_dm1to2_lag1_%s_', 'LH', 'LH');
roiOrder = {'ecc_lag0', 'ecc_lag1', 'ecc_lag2', 'ecc_lag3', 'ecc_lag4', 'ecc_lag5', ...
            'ecc_lag6', 'ecc_lag7', 'ecc_lag8', 'ecc_lag9', 'ecc_lag10','ecc_lag11'};
%roiNames_ecc_each_LH = cell(roiCellLen,1);
%roifiles_ecc_each_LH = cell(roiCellLen,1);
for ixRoi = 1:length(roiOrder)
  roiNames_ecc_each_LH{ixRoi} = ['LH' roiOrder{ixRoi}];
  roifiles_ecc_each_LH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiBaseName = sprintf('s1_BAIC3T_%s_ecc_each_dm1to2_lag1_%s_', 'RH', 'RH');
roiOrder = {'ecc_lag0', 'ecc_lag1', 'ecc_lag2', 'ecc_lag3', 'ecc_lag4', 'ecc_lag5', ...
            'ecc_lag6', 'ecc_lag7', 'ecc_lag8', 'ecc_lag9', 'ecc_lag10','ecc_lag11'};
%roiNames_ecc_each_RH = cell(roiCellLen,1);
%roifiles_ecc_each_RH = cell(roiCellLen,1);
for ixRoi = 1:length(roiOrder)
  roiNames_ecc_each_RH{ixRoi} = ['RH' roiOrder{ixRoi}];
  roifiles_ecc_each_RH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiBaseName = sprintf('s1_BAIC3T_%s_ang_each_dm1to2_lag1_%s_', 'LH', 'LH');
roiOrder = {'ang_lag0', 'ang_lag1', 'ang_lag2', 'ang_lag3', 'ang_lag4', 'ang_lag5', ...
            'ang_lag6', 'ang_lag7', 'ang_lag8', 'ang_lag9', 'ang_lag10','ang_lag11'};
%roiNames_ang_each_LH = cell(roiCellLen,1);
%roifiles_ang_each_LH = cell(roiCellLen,1);
for ixRoi = 1:length(roiOrder)
  roiNames_ang_each_LH{ixRoi} = ['LH' roiOrder{ixRoi}];
  roifiles_ang_each_LH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiBaseName = sprintf('s1_BAIC3T_%s_ang_each_dm1to2_lag1_%s_', 'RH', 'RH');
roiOrder = {'ang_lag0', 'ang_lag1', 'ang_lag2', 'ang_lag3', 'ang_lag4', 'ang_lag5', ...
            'ang_lag6', 'ang_lag7', 'ang_lag8', 'ang_lag9', 'ang_lag10','ang_lag11'};
%roiNames_ang_each_RH = cell(roiCellLen,1);
%roifiles_ang_each_RH = cell(roiCellLen,1);
for ixRoi = 1:length(roiOrder)
  roiNames_ang_each_RH{ixRoi} = ['RH' roiOrder{ixRoi}];
  roifiles_ang_each_RH{ixRoi} = [roiBaseName roiOrder{ixRoi}];
end

roiFiles = {roifiles_ang_LH{:} roifiles_ang_RH{:} ...
            roifiles_ecc_each_LH{:} roifiles_ecc_each_RH{:} ...
            roifiles_ang_each_LH{:} roifiles_ang_each_RH{:}}';

roiNames = {roiNames_ang_LH{:} roiNames_ang_RH{:} ...
            roiNames_ecc_each_LH{:} roiNames_ecc_each_RH{:} ...
            roiNames_ang_each_LH{:} roiNames_ang_each_RH{:}}';

P.roiFiles = roiFiles;
P.si_roi_all_names = roiNames;


%============================================================ Batas dari
%Pembentukan struct P disini. Kemudian setelah ini membangun struct D
% Get data for *_fmri_roi_v6.mat

%% Make labels_samples and *_samples from block info:
[D.labels_samples, D.ti_run_sampInds, D.ti_block_sampInds, D.stim_patterns] = ...
		fmri_blockToTrialLabels_visRecon(P.labels_runs_blocks, P.ti_samples_per_block, P.stim_patterns_cells, P.labels_rest);

% Expand ..begin_vols:
P.fMRI.begin_vols = expandPat(P.fMRI.begin_vols, [1 P.Gen.runs_max]);

%% Make D.label
D.label = [D.labels_samples; D.stim_patterns]'; % each pixel label (:,2:101) and labels_samples (:,1)

%% Make D.label_type
for i = 1:100 % 10 x 10 img
    label_type{1,i} = ['pixel' padZeros(i,'000')];
end;
D.label_type{1,1} = 'image';
D.label_type(1,2:101) = label_type;

% Convert rest labels number
idx = ismember(D.label(:,1),setdiff(P.labels_rest,P.labels_rest_pre));
if any(any(D.label(idx,2:end)~=-1,1))
    error('invalid image labels')
end
D.label(idx,2:end) = 2; %% put 'rest' label number

idx = ismember(D.label(:,1),P.labels_rest_pre);
if any(any(D.label(idx,2:end)~=-1,1))
    error('invalid image labels')
end
D.label(idx,2:end) = 3; %% put 'rest' label number

%% Make D.label_def
label_def = P.labels_names;
D.label_def{1,1} = label_def;
for i = 2:101 % 10 x 10 img
    D.label_def{1,i} = {'off','on','rest','prerest'}'; %% -> 0,1,2,3
end;

%% Make D.design and D.design_type with fmri_makeDesign_bdtb (new) ed SI:
% prtcl set up
prtcl.labels_runs_blocks = P.labels_runs_blocks;
prtcl.samples_per_label{1} = P.ti_samples_per_block;
prtcl.samples_per_block = P.ti_samples_per_block;

% make D.design(:,1:2) 'run' and 'block'
[D.design, D.design_type] = fmri_makeDesign(prtcl, D.stim_patterns);

% make D.design(:,3) 'figure_type' (from here)
D.design_type{end+1} = 'figure_type';
cols = size(D.design,2);
run_sp = 1;
run_ep = 0;
for i = 1:length(P.expList)
    run_ep = run_ep + length(P.expList{i});
    index_sp = find(D.design(:,1) == run_sp);
    index_ep = find(D.design(:,1) == run_ep);
    D.design(index_sp(1):index_ep(end),cols+1) = i;
    run_sp = run_sp + length(P.expList{i});
end;

% Create file lists with fmri_makeFileNames
P.ti_run_sampInds = D.ti_run_sampInds;
filesRaw = fmri_makeFileNames(P.baseFileName, P);
P = rmfield(P,'ti_run_sampInds');

%% path to first vols
P.fMRI.vol_first = [P.pathRaw filesRaw{1}];

%% path to roi data
P.roiPath = roiDir;

spm_defaults;

%% Make D.si_roi_all_volInds, D.si_roi_all_volInds_cells with make_roi_volIndex_visRecon: disini pengambilan file VOX_*, nama file VOX ada dalam fungsi dibawa ini
[D.si_roi_all_volInds_cells, D.si_roi_all_volInds] = make_roi_volIndex_visRecon(P.roiPath, P.roiFiles, P.fMRI.vol_first);

%% Make D.roi, D.roi_name, D.xyz D.si_roi_all_volInds_cells D.si_roi_all_volInds with fmri_readRois
rois.spm_ver = 5;
rois.roi_dir = roiDir;
j = 1;
% eliminate [] in roi_files and change file name : el_roi_files
for i=1:numel(P.roiFiles(:))
    if ~isempty(P.roiFiles{i})
        rois.roi_files{j} = ['VOX_' P.roiFiles{i} '.mat'];
        j = j + 1;
    else
        continue;
    end;
end;
rois.vol_first = [P.pathRaw filesRaw{1}];
paths = [];
[D.roi, D.roi_name, D.xyz] = fmri_readRois(rois, paths);


%% Make D.stat with fmri_readStats_bdtb (new) ed SI:
stats.stat_dir = roiDir;
stats.stat_files = rois.roi_files;
stats.stat_type = {'tval'};
paths = [];
[D.stat, D.stat_type] = fmri_readStats(stats, D.xyz, paths);
clear stats paths rois;


%% Make D.data with fmri_makeFileList and fmri_readEpiWithinRois bdtb:
P.fMRI.begin_vols = P.fMRI.begin_vols(1);
P.fMRI.base_file_name = P.baseFileName;
P.paths.to_realigned = P.pathRaw;

epi_files = fmri_makeFileList(D, P);
D.data    = fmri_readEpisWithinRois(D.xyz, epi_files);
% remove variables
clear epi_files;
P = rmfield(P, 'paths');
P.fMRI = rmfield(P.fMRI, 'base_file_name');

%% Order structs look nice:
P = orderfields(P);

%--------------------------------------
%% Write output:
% Make output directory if it doesn't exist:
pathDatMat = [dataPath sbjId '_fmri_mat/'];

if exist(pathDatMat,'dir') ~= 7,
    mkdir(pathDatMat)
end;

% eliminate unnecessary variables in D
D = rmfield(D,{'labels_samples','stim_patterns'});
D = rmfield(D,{'ti_run_sampInds','ti_block_sampInds','si_roi_all_volInds','si_roi_all_volInds_cells'});

fName = [pathDatMat P.Gen.sbjId '_fmri_roi' saveFnamePostFix '_v6.mat'];
fprintf('\nSaving:\n%s\n', fName);
vers = version;
if vers(1)=='6',
	save(fName, 'D'); 
else
	save(fName, 'D','-v6');
end;

clear all


%% end