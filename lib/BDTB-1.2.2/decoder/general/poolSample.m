function [D, pars] = poolSample(D, pars)
% pool and average data with same labels (within one run)
% function [D,pars] = poolSample(D,pars)
%
% Input:
%   D.data         - 2D matrix of any data ([time(sample) x space(voxel/channel)] format)
%   D.label        - condition labels of each sample ([time x 1] format)
%   D.design       - design matrix of experiment ([time x dtype] format)
%   D.design_type  - name of each design type ({1 x dtype] format)
%   pars.nPool     - number of pooling samples with same labels
%   pars.poolLabel - target label to pool
%   pars.poolSep   - pool samples in other block? 1:yes(default), 0:no
%   pars.useResid  - use residual sample? 0:delete, 1:add last block(default), 2:make one more block
% Output:
%   D.data         - averaged data
%   D.label        - averaged labels
%   D.design       - averaged design matrix
%   pars
% 
% Note:
%   tentatively, indexes of blocks are re-created on the basis of samples.
%   this is not bad assumption because averageBlocks should be before poolSample
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D),     error('Wrong args');	end
if ~exist('pars','var'),                pars = [];              end

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
nPool     = getFieldDef(pars,'nPool',0);
poolLabel = getFieldDef(pars,'poolLabel',[]);
poolSep   = getFieldDef(pars,'poolSep',1);
useResid  = getFieldDef(pars,'useResid',1);

% make inds:
% run:
ind = find(strcmpi(D.design_type,'run'));
if isempty(ind)
    error('''run'' isn''t found in ''D.design_type''');
end
inds_runs(2,:) = [find(diff(D.design(:,ind)))' size(D.design,1)];
inds_runs(1,:) = [1 inds_runs(2,1:end-1)+1];
num_runs       = size(inds_runs,2);
% block:
ind_block = find(strcmpi(D.design_type,'block'));


%% Pool data:
data     = cell(num_runs,1);
label    = cell(num_runs,1);
vol_inds = cell(1,num_runs);
for itr = 1:num_runs
    ix = inds_runs(1,itr):inds_runs(2,itr);

    % copy non-pooled data/label:
    poolAllIdx    = ix(ismember(D.label(ix),poolLabel));
    nonPoolIdx    = setdiff(ix,poolAllIdx);
    data{itr}     = D.data(nonPoolIdx,:)';
    label{itr}    = D.label(nonPoolIdx)';
    vol_inds{itr} = nonPoolIdx;

    % pool data:
    if ~isempty(poolAllIdx)
        for itl = 1:length(poolLabel)
            fprintf('pooling label %d\n',poolLabel(itl));

            % make pool-group:
            poolIdx = ix(D.label(ix)==poolLabel(itl));
            if ~isempty(poolIdx)
                if poolSep      % pool separated data/label 
                    nTotalPool = length(poolIdx);
                    pool_sum   = nTotalPool;
                else            % pool data/label within same block only
                    pool_pos   = find(diff(poolIdx)~=1);
                    nTotalPool = diff([0 pool_pos length(poolIdx)]);
                    pool_sum   = cumsum(nTotalPool);
                end

                % make begin/end-index of each pool-group:
                poolSegment = cell(length(nTotalPool),1);
                for itp=1:length(nTotalPool)
                    poolSegment{itp} = 1:nPool:nTotalPool(itp);
                    if itp~=1
                        poolSegment{itp} = poolSegment{itp} + pool_sum(itp-1);
                    end
                    if mod(nTotalPool(itp),nPool)   % there is residual sample
                        if useResid~=2 
                            poolSegment{itp} = poolSegment{itp}(1:end-1);   % delete residual block
                        end
                    end
                    
                    if ~isempty(poolSegment{itp})
                        poolSegment{itp}(2,:) = poolSegment{itp} + nPool - 1;
                        if useResid     % arrange for residual sample
                            poolSegment{itp}(2,end) = pool_sum(itp);
                        end
                    end
                end
                poolSegment = [poolSegment{:}];

                if ~isempty(poolSegment)
                    % make index of samples in each pool-group
                    poolIdxList = cell(size(poolSegment,2),1);
                    for segmentIdx=1:size(poolSegment,2)                                    
                        poolIdxList{segmentIdx} = poolIdx(poolSegment(1,segmentIdx):poolSegment(2,segmentIdx));
                    end

                    % add pooled data/label
                    for itp = 1:length(poolIdxList)
                        if length(unique(D.label(poolIdxList{itp})))~=1
                            error('invalid local average');
                        end
                        
                        data{itr}(:,end+1)   = mean(D.data(poolIdxList{itp},:))';
                        label{itr}(end+1)    = D.label(poolIdxList{itp}(1))';
                        vol_inds{itr}(end+1) = poolIdxList{itp}(1);
                    end
                end
            end
        end
    end
end

data     = [data{:}]';
label    = [label{:}]';
vol_inds = [vol_inds{:}];

D.data   = data;
D.label  = label;
D.design = D.design(vol_inds,:);


%% caution!!!
if ~isempty(ind_block)
    D.design(:,ind_block) = 1:size(D.design,1);
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
