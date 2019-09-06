function [D, pars] = selectChanByTvals(D, pars)
% selectChanByStat - selects 'num_chans' channels (voxels) of 'data' based on a 'tvals'
% [D, pars] = selectChanByStat(D, pars)
%
% Input:
%   D.stat         - statistics (including 't-val') of each voxel/channel ([1 x space] format)
% Optional:
%   pars.num_chans - number of channels (voxels) to select or percent of existing ones
%   pars.tvals_min - min value of t-vals range to use
%   pars.tvals_max - max value of t-vals range to use
%   pars.verbose   - [1..3] print detail level 0=no printing (default: 1)
% Output:
%   D.data         - data within the selected channel
%   D.xyz          - X,Y,Z-coordinate values within the selected channel
%   D.stat         - statistics within the selected channel
%   D.roi          - voxel included ROIs ([rtype x space] format)
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D)
    error('''D''ata-struct must be specified');
end
if ~exist('pars','var'),	pars = [];      end

% Select t-val:
ind_t   = find(strcmpi(D.stat_type,'tval'));
if isempty(ind_t),      ind_t = 1;      end
tvals   = D.stat(ind_t,:);
num_all = length(tvals);

if isfield(pars,mfilename)      % unnest, if needed
    P    = pars;
    pars = P.(mfilename);
end
num_chans = getFieldDef(pars,'num_chans',num_all);
tvals_min = getFieldDef(pars,'tvals_min',-inf);
tvals_max = getFieldDef(pars,'tvals_max',inf);
verbose   = getFieldDef(pars,'verbose',1);

if num_chans<1,     num_chans = round(num_chans*num_all);       end


%% For UI:
if verbose
    fprintf(['\n' mfilename ' ------------------------------']);
end


%% Select channels in [tvals_min tvals_max] range:
inds_select = find(tvals >= tvals_min & tvals <= tvals_max);
num_select  = length(inds_select);

if num_chans>num_select
    num_chans = num_select;
    fprintf('\n Warning: num_chans > those between tvals_min & tvals_max,\n  setting num_chans = to this!');
end


%% Sort tvals:
tvals = tvals(inds_select);
[tvals, inds_sort] = sort(tvals,'descend');


%% Select data based on top num_chans t-vals:
inds_use = inds_select(inds_sort(1:num_chans));
D.data   = D.data(:,inds_use);
D.xyz    = D.xyz(:,inds_use);
D.stat   = D.stat(:,inds_use);
D.roi    = D.roi(:,inds_use);

pars.num_chans = num_chans;


%% User feedback:
if verbose
    fprintf('\n Selected %d channels between %g and %g\n', length(inds_use), min(D.stat(ind_t,:)), max(D.stat(ind_t,:)));
end


%% For 'P'ars-struct
if exist('P','var')
    P.(mfilename) = pars;
    pars          = P;
end
