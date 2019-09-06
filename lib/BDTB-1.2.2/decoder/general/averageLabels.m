function [D, pars] = averageLabels(D, pars)
%averageLabels - averages data in each label for each channel (voxel)
%[D, pars] = averageBlocks(D, pars)
%
% Input:
%	D.data             - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%	D.label            - condition labels of each sample ([time x 1] format)
% Optional:
%	pars.begin_off     - number of samples to remove from the beginning of each block
%	pars.end_off       - number of samples to remove from the end of each block
%   pars.target_labels - labels with which data samples are only averaged 
%                        if absent, all data samples are averaged
%	pars.verbose       - [1..3] = print detail level; 0 = no printing (default=1)
% Output:
%	D.data             - averaged data
%   D.label            - labels for each averaged data
%   D.design           - design matrix of averaged samples
%
% Note:
%   This function assumes that 'label' is included 'block'.
%   It means there're not any label extending multiple block.
%
% Key:
%	nChans = # Channels, signals; voxels for fMRI; sensors for EEG; ~ space, patterns
%	nSamps = # Samples; nTRs, nVols, nTrials for fMRI (not MEG); ~ time
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D)
    error('''D''ata-struct must be specified');
end
if exist('pars','var')==0,      pars = [];              end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
begin_off     = getFieldDef(pars,'begin_off',0);
end_off       = getFieldDef(pars,'end_off',0);
target_labels = getFieldDef(pars,'target_labels',unique(D.label));% YM100501
verbose       = getFieldDef(pars,'verbose',1);


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
    if verbose>=2
        fprintf('\n # blocks: \t%d',num_blocks);
        fprintf('\n begin_off:\t%d',begin_off);
        fprintf('\n end_off:  \t%d',end_off);
        fprintf('\n target_labels:  \t%d',target_labels);
    end
    fprintf('\n');
end


%% Make index:
% label:
inds_label(2,:) = [find(diff(D.label))' length(D.label)];
inds_label(1,:) = [1 inds_label(2,1:end-1)+1];
num_lblock      = size(inds_label,2);
% run:
ind = find(strcmpi(D.design_type,'run'));
if isempty(ind),	ind = 1;    end
inds_runs(2,:) = [find(diff(D.design(:,ind)))' size(D.design,1)];
inds_runs(1,:) = [1 inds_runs(2,1:end-1)+1];


%% Calculate average:
data_temp     = cell(num_lblock,1);
target_lblock = false(1,num_lblock);
for itl=1:num_lblock
    if ismember(D.label(inds_label(1,itl)),target_labels)
        target_lblock(itl) = 1;
        
        bi = inds_label(1,itl) + begin_off;
        ei = inds_label(2,itl) - end_off;
        
        if bi>ei
            if ismember(inds_label(2,itl),inds_runs(2,:))
                % last block of each run, this error may be caused by 'shiftData'
                fprintf('\nWarning: End-point of label averaging is smaller than begin-point\n Use only begin-point\n');
                ei = bi;
            else
                error('begin/end_off is too many to keep samples of label averaging');
            end
        end
        data_temp{itl} = mean(D.data(bi:ei,:),1);
    else
        data_temp{itl} = D.data(inds_label(1,itl):inds_label(2,itl),:);
    end
end

D.data = cell2mat(data_temp);


%% Make labels:
temp = cell(num_lblock,1);
for itb=1:num_lblock
    if target_lblock(itb)
        temp{itb} = D.label(inds_label(1,itb));
    else
        temp{itb} = D.label(inds_label(1,itb):inds_label(2,itb));
    end
end
D.label = cell2mat(temp);


%% Make design:
temp = cell(num_lblock,1);
for itb=1:num_lblock
    if target_lblock(itb)
        temp{itb} = D.design(inds_label(1,itb),:);
    else
        temp{itb} = D.design(inds_label(1,itb):inds_label(2,itb),:);
    end
end
D.design = cell2mat(temp);


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
