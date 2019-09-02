function trainLocalDecoder(expID,basisTypeSet,roiAreaName,cvMode,AUTO_OUT_FLAG)

DEBUG_FLAG = 0;

rootPath = '/home/';

%% path setting
dataPath = ['../data/']
libRootPath = ['../../lib/'];
libLocalPath = ['../lib/'];
addpath(genpath([libRootPath 'BDTB-1.2.2/']));
addpath(genpath([libRootPath 'SLR1.2.1alpha/']));
addpath(genpath(libLocalPath));

%% basis switch
for i = 1:length(basisTypeSet)
  switch basisTypeSet{i}
    case '1x1'
      idxPredLabelSet{i} = 1:100;
    case '1x2'
      idxPredLabelSet{i} = 1:90;
    case '2x1'
      idxPredLabelSet{i} = 1:90;
    case '2x2'
      idxPredLabelSet{i} = 1:81;
    case '3x3'
      idxPredLabelSet{i} = 1:64;
    otherwise
      error('invalid basis: %s is not supported currently',basisTypeSet{i})
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% parameter setting for individual subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if expID == 's1_s1071119'
    sbjID = 's1';
    parm.expData = [dataPath sbjID '_fmri_mat/' sbjID ...
                    '_fmri_roi-1to2mm_Th1_fromAna_' sbjID '071119ROI_resol10_v6'];
    parm.expP.sbjID = sbjID;
    parm.expP.idxRunRand = 1:20;
    parm.expP.onVal = 1;
    parm.expP.labels_rest_pre = [1 23];
    parm.expP.resol = 10;
    
    %%% data shuffling or not
    %parm.shuffle = 1;
    parm.shuffle = 0;

    parm.saveDirPostfix = '_baseByRestPre_smlr';

    if parm.shuffle
        parm.saveDirPostfix = [parm.saveDirPostfix '_shuffle' num2str(parm.shuffle)];
    end

    parm.sbjID = parm.expP.sbjID;
    parm.saveDirPostfix = [parm.saveDirPostfix '_s1071119ROI_resol10'];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CV for combination of decoders.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
randRun = parm.expP.idxRunRand;

switch cvMode
  case 'leave2'
    [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(randRun,2,2);
  case 'leave1'
    [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(randRun,0,2);
  case 'leave0'
    [idxTrainRunSet, idxTrainRunSetStr] = createCvIdx_nLeaveUnique(randRun,0,0);
end

parm.saveDirPostfix = [parm.saveDirPostfix '_' cvMode];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for pararell processing marker file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
runningInfo = struct;
[status runningInfo.hostname] = system('hostname');
if isunix
    [status runningInfo.username] = system('whoami');
    [s runningInfo.ppid] = system('echo $PPID');
    [s runningInfo.env] = system('env|sort');
end

clear tmp*

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% print 'parm' for confirmation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(parm)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% loop for basisType.  Don't overwrite parmForBasisTypeLoop in loop!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parmForBasisTypeLoop = parm;
for idxBasisType = 1:length(basisTypeSet)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% reset and initialize parm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm = parmForBasisTypeLoop;
    parm.basisType = basisTypeSet{idxBasisType};
    idxPredLabelList  = idxPredLabelSet{idxBasisType};

    fprintf([repmat('=',1,80) '\n']);
    fprintf(['basisType : ' parm.basisType '\n']);
    fprintf([repmat('=',1,80) '\n']);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% load data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(parm.expData, 'D');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% basis setting
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    switch parm.basisType
      case '1x1'
        parm.basis = [1]; parm.conds = [0 1];
      case '1x2'
        parm.basis = [1 1]; parm.conds = [0 1 2];
      case '2x1'
        parm.basis = [1; 1]; parm.conds = [0 1 2];
      case '2x2'
        parm.basis = [1 1; 1 1]; parm.conds = [0 1 2 3 4];
      otherwise
        error('invalid basis setting');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% convert basis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    resol = parm.expP.resol;
    [labelConverted basisW] = convertBasis2D_overlap(D.label(:,2:end), [resol resol], parm.basis);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% initialize D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %D.stim_patternsOrig = D.label;
    D.label = [D.label(:,1) labelConverted];
    %D.stim_convert_weights = basisW;
    parm.basisConvertW = basisW;
    %clear pre_restMask restMask resol labelConverted basisW

    %D.runSampInds   = D.ti_run_sampInds;
    %D.blockSampInds = D.ti_block_sampInds;  % only used with averaging blocks
    %D.roiAllCells   = D.si_roi_all_volInds_cells;
    %D.siVolInds     = D.si_roi_all_volInds;
    %D.siRoiInds     = 1:length(D.siVolInds)';

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Preprocessing parameter setting
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% ROI selection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    roiEccList = {'ecc_lag0','ecc_lag1','ecc_lag2',...
                  'ecc_lag3','ecc_lag4','ecc_lag5',...
                  'ecc_lag6','ecc_lag7','ecc_lag8',...
                  'ecc_lag9','ecc_lag10','ecc_lag11',...
                 };
    
    switch roiAreaName
      case 'AllArea'
        roiAreaList = {'V1','V2','V3','VP','V4'};
        parm.roiName = 'AllArea_Ecc1to11';
      case 'V1V2'        
        roiAreaList = {'V1','V2'};        
        parm.roiName = 'V1V2_Ecc1to11';
      case 'V1'
        roiAreaList = {'V1'};        
        parm.roiName = 'V1_Ecc1to11';
      case 'V2'
        roiAreaList = {'V2'};        
        parm.roiName = 'V2_Ecc1to11';
      case 'V3'
        roiAreaList = {'V3','VP'};                
        parm.roiName = 'V3VP_Ecc1to11';
      otherwise
        error('Invalid roiAreaName');
    end
    
    roiAreaMask = false(1,numel(D.roi_name));
    for idx = 1:numel(roiAreaList)
        roiAreaMask = roiAreaMask | cellfun(@(x) any(strfind(x,roiAreaList{idx})), D.roi_name);
    end

    roiEccMask = false(1,numel(D.roi_name));
    for idx = 1:numel(roiEccList)
        roiEccMask = roiEccMask | cellfun(@(x) any(strfind(x,roiEccList{idx})), D.roi_name);
    end
    
    parm.fmri_selectRoi.rois_use{1} = {roiAreaMask};
    parm.fmri_selectRoi.rois_use{2} = {roiEccMask};
    parm.fmri_selectRoi.within_operation = 1;
    parm.fmri_selectRoi.across_operation = 0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Outlier rejection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm.reduceOutliers.remove = 1;
    parm.reduceOutliers.method = 2;
    parm.reduceOutliers.app_dim = 1;
    parm.reduceOutliers.min_val = 100;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Linear detrend
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm.detrend_bdtb.sub_mean = 0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Hemodynamic delay compensation 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm.shiftData.shift = 2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Block average
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % no need to setting additional parameters
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Normazize
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm.normByBaseline.mode = 0;
    parm.normByBaseline.base_conds = parm.expP.labels_rest_pre;
    
    procs1 = {'fmri_selectRoi'; 
              'reduceOutliers'; 
              'detrend_bdtb'; 
              'shiftData'; 
              'averageBlocks'; 
              'normByBaseline'};

    [D,unuse] = procSwitch(D,parm,procs1);

    fprintf('--- end of general preprocessing. (procs1)\n\n');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% save preprocessed D for each basisType
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fnamePreprocessedData = sprintf('de_%s_%s%s_%s_preprocessed.mat', parm.sbjID, parm.roiName, parm.saveDirPostfix, parm.basisType);
    parm.fnamePreprocessedData = fnamePreprocessedData;
    if ~exist(fnamePreprocessedData,'file')
        fprintf('--- save %s\n\n', fnamePreprocessedData);
        save(fnamePreprocessedData,'parm','D');
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Decoding methods setting.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% model selection
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parm.model = {'slr121a'};    
    
    parm.slr121a.nlearn   = 500;
    parm.slr121a.amax     = 1e8;
    parm.slr121a.verbose  = 1;
    parm.slr121a.conds = parm.conds;
    parm.slr121a.normMeanMode = 'feature';
    parm.slr121a.normScaleMode = 'feature';
    parm.slr121a.normMode = 'training';
    parm.slr121a.R = 0; %% if you want to use kernel
    parm.slr121a.xcenter = []; %% if you want to use kernel
    parm.slr121a.kernel_func = 'none'; %% if you want to use kernel: none, linear, or Gaussian
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% for trainRun loop
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    parmForTrainRunLoop = parm;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% loop for idxTrainRun and idxTestRun.  Don't overwrite parmForLabelLoop in loop!!
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for idxTr = 1:length(idxTrainRunSet)

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% reset and initialize parm
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        parm = parmForTrainRunLoop;

        idxTrainRun = idxTrainRunSet{idxTr};
        idxTestRun  = setdiff(parm.expP.idxRunRand, idxTrainRun);
        idxFigRun = setdiff(1:D.design(end,ismember(D.design_type,'run')), parm.expP.idxRunRand);

        fprintf([repmat('=',1,80) '\n']);
        fprintf(['idxTrainRun : ' num2str(idxTrainRun) '\n']);
        fprintf([repmat('=',1,80) '\n']);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%% prepare train data (and test data if needed)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %% no rest data
        [Dtr.data Dtr.label runIdxTr] = getNoRestData(D,idxTrainRun);
        Dtr.label = Dtr.label(:,2:end);
        Dtr.xyz = D.xyz;
        parm.runIdxTr = runIdxTr;

        if ~isempty(idxTestRun)
            [Dte.data Dte.label runIdxTe] = getNoRestData(D,idxTestRun);
            Dte.label = Dte.label(:,2:end);
            Dte.xyz = D.xyz;
            parm.runIdxTe = runIdxTe;
        end
        if ~isempty(idxFigRun)
            [Dfig.data Dfig.label runIdxFig] = getNoRestData(D,idxFigRun);
            Dfig.label = Dfig.label(:,2:end);
            Dfig.xyz = D.xyz;
            parm.runIdxFig = runIdxFig;
        end

        Dtr.label = Dtr.label/parm.expP.onVal;
        if ~isempty(idxTestRun)
            Dte.label = Dte.label/parm.expP.onVal;
        end
        if ~isempty(idxFigRun)
            Dfig.label = Dfig.label/parm.expP.onVal;
        end

        parm.idxTrainRun = idxTrainRun;
        parm.idxTestRun = idxTestRun;
        parm.idxFigRun = idxFigRun;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% for idxPredLabel loop
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        dataTrForLabelLoop = Dtr.data;
        labelTrForLabelLoop = Dtr.label;
        if ~isempty(idxTestRun)
            dataTeForLabelLoop = Dte.data;
            labelTeForLabelLoop = Dte.label;
        end
        if ~isempty(idxFigRun)
            dataFigForLabelLoop = Dfig.data;
            labelFigForLabelLoop = Dfig.label;
        end
        parmForLabelLoop = parm;


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% loop for idxPredLabel.  Don't overwrite dataTrForLabelLoop and parmForLabelLoop in loop!!
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for idxPredLabel = idxPredLabelList
            fprintf([repmat('=',1,80) '\n']);
            fprintf(['idxPredLabel : ' num2str(idxPredLabel) '\n']);
            fprintf([repmat('=',1,80) '\n']);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% reset and initialize parm
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            parm = parmForLabelLoop;
            parm.idxPredLabel = idxPredLabel;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% save setting and checking
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            trainRunStr = strrep(num2str(parm.idxTrainRun, ' %1d'), ' ', '-');
            saveDir = sprintf('de_%s_%s%s/%s/label%03d',...
			      parm.sbjID, parm.roiName,parm.saveDirPostfix,parm.basisType,idxPredLabel);
            saveName = sprintf('%s_label%03d_train%s', parm.basisType, idxPredLabel, trainRunStr);

            %% check save dir
            if ~exist(saveDir, 'dir')
                if ~mkdir(saveDir);
                    error(['Cannot create directory - ' saveDir]);
                end
            end
            %% check write permission
            saveCheckFname = sprintf('saveCheck_%10.0f',now*10^10);
            try
                save([saveDir '/' saveCheckFname], 'saveDir');
            catch
                error(['Cannot write files in directory - ' saveDir]);
            end
            delete([saveDir '/' saveCheckFname '.mat']);

            %% check files.
            if (exist([saveDir '/' saveName '.mat'],'file') | ...
                    exist([saveDir '/' saveName '_RUNNING_INFO.mat'])) ...
                    & ~DEBUG_FLAG
                %% skip...
                fprintf(repmat('=',1,80)); fprintf('\n');
                fprintf('file already exist.\n');
                fprintf(repmat('=',1,80)); fprintf('\n\n');
                continue;
            else
                save([saveDir '/' saveName '_RUNNING_INFO'], 'runningInfo');
            end	    
	    
            parm.saveDir  = saveDir;
            parm.saveName = saveName;

            fprintf('saveDir  : %s\n', saveDir);
            fprintf('saveName : %s\n', saveName);
            clear i saveCheckFname saveDir saveName

            Dtr.data = dataTrForLabelLoop;
            Dtr.label = labelTrForLabelLoop(:,idxPredLabel);
            if ~isempty(idxTestRun)
                Dte.data = dataTeForLabelLoop;
                Dte.label = labelTeForLabelLoop(:,idxPredLabel);
            end
            if ~isempty(idxFigRun)
                Dfig.data = dataFigForLabelLoop;
                Dfig.label = labelFigForLabelLoop(:,idxPredLabel);
            end
	    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% data shuffling to examine correlation
	    %%% 
	    %%% shuffling on training data -> delta_I_diag
	    %%% (trained by uncorrelated data, then test correalted data
	    %%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if parm.shuffle
                tmpLabel = labelTr(:,idxPredLabel);
                tmpCond = parm.conds;
                tmpDataCat = [];
                tmpLabelCat = [];

		for condIdx = 1:length(tmpCond)
                    shuffleIdx = tmpLabel == tmpCond(condIdx);
                    tmpData = Dte.data(:,shuffleIdx);
		    tmpData2 = [];
                    for vIdx = 1:size(tmpData,1)
                        tmpData2(vIdx,:) = tmpData(vIdx,randperm(size(tmpData,2)));
                    end
                    tmpDataCat =[tmpDataCat tmpData2];
                    tmpLabelCat = [tmpLabelCat repmat(tmpCond(condIdx),1,size(tmpData2,2))];
                end
		
                Dtr.data = tmpDataCat;
                Dtr.label = tmpLabelCat;
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% Estimating model parameter and testing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% train (random image)
            parm.modelSwitch.mode = 1;	    
            fprintf('=== Training ===\n')
            [resultsTr, parm] = modelSwitch(Dtr, parm, parm.model);
            
            %% test (random image)
            if ~isempty(idxTestRun)
                parm.modelSwitch.mode = 2;
                fprintf('=== Test ===\n')
                [resultsTe, parm] = modelSwitch(Dte, parm, parm.model);
            end
            
            %% test (figure image)
            if ~isempty(idxFigRun)
                parm.modelSwitch.mode = 2;           
                fprintf('=== Figure test ===\n')
                [resultsFig, parm] = modelSwitch(Dfig, parm, parm.model);
            end            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%% save results
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(idxTrainRun)
	      resultsTr = [];
	    end
	    if isempty(idxTestRun)
	      resultsTe = [];
	    end
	    if isempty(idxFigRun)
	      resultsFig = [];
	    end
            
            saveVars = {'parm', 'resultsTr', 'resultsTe', 'resultsFig'};

            save([parm.saveDir '/' parm.saveName], saveVars{:});

            fprintf(['--- save "' parm.saveDir '/' parm.saveName '"\n\n']);
        end
        clear idxTrainRun idxTestRun idxFigRun
    end
end

fprintf([repmat('=',1,80) '\n']);
fprintf('--- end of script\n');


if AUTO_OUT_FLAG
  exit
end

