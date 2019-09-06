function [D, pars]  = selectBlockSample(D, pars)
% selectBlockSample - select samples in each block for each channel (voxel)
% [D, pars] = selectBlockSample(D, pars)
%
% Input:
%   D.data             - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label            - condition labels of each sample ([time x 1] format)
%   D.design           - design matrix of experiment ([time x dtype] format)
%   D.design_type      - name of each design type ({1 x dtype] format)
%   pars.inds          - inds of samples to be included for each block
% Optional:
%   pars.target_labels - labels with which data samples are only considered
%   pars.verbose       - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%   D.data             - selected data
%   D.label            - labels for each selected data
%   D.design           - design matrix of selected data
%
% Key:
%   nChans = # Channels, signals; voxels for fMRI; sensors for EEG; ~ space, patterns
%   nSamps = # Samples; nTRs, nVols, nTrials for fMRI (not MEG); ~ time
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D)
    error('''D''ata-struct must be specified');
end
if ~exist('pars','var'),	pars = [];      end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
inds          = getFieldDef(pars,'inds',[]);
if isempty(inds)
    error('inds to be included must be specified by .inds field');
end
target_labels = getFieldDef(pars,'target_labels',unique(D.label));
verbose       = getFieldDef(pars,'verbose',1);

% make block-inds:
ind = find(strcmpi(D.design_type,'block'));
if isempty(ind)
    error('''block'' isn''t found in ''D.design_type''');
end
inds_blocks(2,:) = [find(diff(D.design(:,ind)))' size(D.design,1)];
inds_blocks(1,:) = [1 inds_blocks(2,1:end-1)+1];
num_blocks       = size(inds_blocks,2);


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n # blocks: \t%d',num_blocks);
        fprintf('\n inds:\t%d',inds);
        fprintf('\n target_labels:  \t%d',target_labels);
    end
    fprintf('\n');
end


%% Select samples:
data_temp     = cell(num_blocks,1);
target_blocks = false(1,num_blocks);
for itb=1:num_blocks
    tmp = D.label(inds_blocks(1,itb):inds_blocks(2,itb));
    tmp = unique(tmp);
    if numel(tmp) ~= 1
        error('mutiple labels are contained in a single block');
    end
   
    if ismember(tmp,target_labels)
        target_blocks(itb) = 1;

        tmpBlkInds = inds_blocks(1,itb):inds_blocks(2,itb);
        tmpBlkInds = tmpBlkInds(inds);
        if isempty(tmpBlkInds)
            error('inds to be included are empty');
        end

        data_temp{itb} = D.data(tmpBlkInds,:);
    else
        data_temp{itb} = D.data(inds_blocks(1,itb):inds_blocks(2,itb),:);
    end
    clear tmp;
end

D.data = cell2mat(data_temp);


%% Make use_vol_inds:
vol_inds = cell(1,num_blocks);
for itb=1:num_blocks
    if target_blocks(itb)
        vol_inds{itb} = inds_blocks(1,itb)+inds(1)-1:inds_blocks(1,itb)+inds(end)-1;
    else
        vol_inds{itb} = inds_blocks(1,itb):inds_blocks(2,itb);
    end
end
vol_inds = cell2mat(vol_inds);


%% Make labels:
D.label = D.label(vol_inds,:);


%% Make design:
D.design = D.design(vol_inds,:);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
 