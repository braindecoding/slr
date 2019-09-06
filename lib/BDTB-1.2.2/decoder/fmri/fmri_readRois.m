function [roi, roi_name, xyz] = fmri_readRois(rois, paths)
% fmri_readRois - reads ROI files specified by P.rois
% [roi, roi_name, xyz] = fmri_readRois(rois, paths)
%
% Input:
%   rois.spm_ver   - SPM ver used for making ROI (default: 5)
%   rois.roi_dir   - directory of ROI
%   rois.roi_files - ROI names (and file name ends)
%                    if empty, use all voxels (whole brain)
%   paths.to_dat   - path of data-root
% Output:
%   roi            - voxel included ROIs ([rtype x space] format)
%   roi_name       - name of each ROI ({rtype} format)
%   xyz            - X,Y,Z-coordinate value of voxels within ROI ([3(x,y,z) x space] format)
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('rois','var') || isempty(rois)
    error('''rois'' should be specified');
end

rois      = getFieldDef(rois,'rois',rois);	% unnest, if need
spm_ver   = getFieldDef(rois,'spm_ver',5);
roi_dir   = getFieldDef(rois,'roi_dir','.');
roi_files = getFieldDef(rois,'roi_files',{});
if isempty(roi_files)
    fprintf('\nUse all voxels (whole brain):\n');
    roi       = [];
    roi_name  = {};
    xyz       = [];
    return;
elseif ~iscell(roi_files)
    roi_files = {roi_files};
end
roi_name = reshape(roi_files,1,[]);

if ~exist('paths','var')
    paths = [];
end
to_dat = getFieldDef(paths,'to_dat',[]);


%% Read ROI files:
xyz_files = cell(1,length(roi_name));

for itr=1:numel(roi_files)
    roi_file                = roi_files{itr};
    [nouse, file_name, ext] = fileparts(roi_file);
    if ~strcmp(ext,'.mat')
        roi_file = [file_name '.mat'];
    end
    file_name = fullfile(roi_dir,roi_file);
    if ~exist(file_name,'file')
        file_name = fullfile(roi_dir,['VOX_' roi_file]); 
        if ~exist(file_name,'file')
            file_name = fullfile(to_dat,roi_dir,roi_file);
            if ~exist(file_name,'file')
                file_name = fullfile(to_dat,roi_dir,['VOX_' roi_file]);
                if ~exist(file_name,'file')
                    error('Can''t find file: %s', file_name);
                end
            end
        end
    end

    fprintf('\nReading ROI file:\n %s\n', file_name);
    
    roi        = load(file_name);
    field_name = fieldnames(roi);
    roi        = roi.(field_name{1});
    
    xyz_files{itr} = roi(1:3,:);
    
    if spm_ver==99
        xyz_files{itr}(1,:) = -xyz_files{itr}(1,:);
    end
    
    fprintf(' %d voxels found\n', size(roi,2));
end


%% Make rois-matrix:
fprintf('\nMaking ROI matrix:\n');

num_voxels = cellfun(@(x)size(x,2), xyz_files);
num_voxels = [0 cumsum(num_voxels)];

xyz_all = [xyz_files{:}];

[xyz, ind_in, ind_out] = unique(xyz_all(1:3,:)','rows');
xyz     = xyz';
ind_in  = ind_in';
ind_out = ind_out';

roi = zeros(length(roi_name),length(ind_in));
for itr=1:length(roi_name)
    ind          = ind_out(num_voxels(itr)+1:num_voxels(itr+1));
    roi(itr,ind) = 1;
end
