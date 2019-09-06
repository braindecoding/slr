function [stat, stat_type, xyz] = fmri_readStats(stats, xyz, paths)
% fmri_readStats - reads VOX files or Analyze files to get stats within xyz voxels
% [stat, stat_type, xyz] = fmri_readStats(files, xyz, paths)
%
% Input:
%   stats.stat_dir   - directory name including stat files
%   stats.stat_files - filenames of stat files,
%                      VOX files ([x,y,z,stat x vox] format) or Analyze image files (.img/.hdr) can use
%   stats.stat_type  - names of statistical type
%   xyz              - xyz-coordinate value of ROI ([3 x vox]),
%                      if absent, use all stats included files
%   paths.to_dat     - path of data-root
% Output:
%   stat             - statistic within xyz voxels
%   stat_type        - names of statistical type
%   xyz              - xyz-coordinate value
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('stats','var') || isempty(stats)
    error('''stats'' should be specified');
end

stats      = getFieldDef(stats,'stats',stats);  % unnest, if need
stat_dir   = getFieldDef(stats,'stat_dir','.');
stat_files = getFieldDef(stats,'stat_files',{});
stat_type  = getFieldDef(stats,'stat_type',{});
if isempty(stat_files)
    error('''stat_files'' should be specified');
elseif ~iscell(stat_files)
    stat_files = {stat_files};
end
num_type = numel(stat_files);

if ~exist('xyz','var') || isempty(xyz)
    warning('''xyz'' isn''t specified, use all stats');
    xyz = [];
end

if ~exist('paths','var')
    paths = [];
end
to_dat = getFieldDef(paths,'to_dat',[]);


%% Read files:
stat_t = cell(1,num_type);
xyz_t  = cell(1,num_type);
for itt=1:num_type
    if iscell(stat_files{itt})  % merge
        num_files = numel(stat_files{itt});
        temp_s    = cell(1,num_files);
        temp_c    = cell(1,num_files);
        for itf=1:num_files
            [temp_s{itf}, temp_c{itf}] = fmri_readStatsFile(fullfile(stat_dir,stat_files{itt}{itf}),to_dat);
        end
        temp_c            = [temp_c{:}];
        temp_s            = [temp_s{:}];
        [xyz_t{itt}, ind] = unique(temp_c','rows');
        xyz_t{itt}        = xyz_t{itt}';
        stat_t{itt}       = temp_s(ind);
    else
        [stat_t{itt}, xyz_t{itt}] = fmri_readStatsFile(fullfile(stat_dir,stat_files{itt}),to_dat);
    end
end


%% Select stats within xyz:
if isempty(xyz)     % use all stats:
    num_voxels = [0 cumsum(cellfun('length',stat_t))];
    
    xyz_all               = [xyz_t{:}];
    [xyz, nouse, ind_out] = unique(xyz_all','rows');
    xyz                   = xyz';
    
    stat = NaN(num_type,size(xyz,2));
    for itt=1:num_type
        stat(itt,ind_out(num_voxels(itt)+1:num_voxels(itt+1))) = stat_t{itt};
    end
else                % select stats within xyz:
    [xyz_u, nouse, ind_out] = unique(xyz','rows');
    stat                    = NaN(num_type,size(xyz,2));
    for itt=1:num_type
        [xyz_t_u, ind_in] = unique(xyz_t{itt}','rows');
        [ind1, ind2]      = ismember(xyz_u,xyz_t_u,'rows');
        stat(itt,ind1)    = stat_t{itt}(ind_in(ind2(ind1)));
    end
    stat = stat(:,ind_out);
end


%% ----------------------------------------------------------------------------
function [stat, xyz] = fmri_readStatsFile(filename, to_dat)
% reads file, and return stats and xyz-coordinate

if ~exist(filename,'file')
    filename = fullfile(to_dat,filename);
    if ~exist(filename,'file')
        error('Can''t find file: %s', filename);
    end
end

[path, file, ext] = fileparts(filename);
if strcmpi(ext,'.mat')                              % VOX file
    temp  = load(filename);
    fname = fieldnames(temp);
    temp  = temp.(fname{1});
    xyz   = temp(1:3,:);
    stat  = temp(4,:);
elseif strcmpi(ext,'.img') || strcmpi(ext,'.hdr')   % Analyze file
    str = which('spm_vol');
    if isempty(str)
        dirname = uigetdir(pwd,'Select ''SPM'' directory');
        if isequal(dirname,0)
            error('''SPM'' is needed to read Analyze file');
        end
        addpath(dirname);
    end
    filename    = fullfile(path, [file '.img']);
    inf         = spm_vol(filename);
    [stat, xyz] = spm_read_vols(inf);
    stat        = stat{itf}(:)';
else
    error('''files'' should be VOX file (.mat) or Analyze file (.img/.hdr)');
end

