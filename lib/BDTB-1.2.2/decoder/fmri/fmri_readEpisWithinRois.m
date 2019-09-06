function [data, xyz] = fmri_readEpisWithinRois(xyz, file_list)
% fmri_readEpisWithinRois - reads EPI files, and returns data within ROIs
% [data, xyz] = fmri_readEpisWithinRois(xyz, file_list)
%
% Input:
%   xyz       - X,Y,Z-coordinate value of voxels within ROIs ([3(x,y,z) x space] format)
%               if empty, use all voxels (whole brain)
%   file_list - EPI file list
% Output:
%   data      - read data of voxels within ROIs ([time(sample) x space(voxel/channel)] format)
%   xyz       - X,Y,Z-coordinate value of voxels ([3(x,y,z) x space] format)
%
% Calls:
%   SPM, (c) >>>
%       spm_defaults  - sets the defaults which are used by SPM
%       spm_vol       - get header information etc for images
%       spm_read_vols - read in entire image volumes
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('xyz','var') || isempty(xyz)
    fprintf('''xyz'' is empty, use all voxels (whole brain)');
    xyz = [];
else
    xyz = getFieldDef(xyz,'xyz',xyz);   % unnest, if need
end

if ~exist('file_list','var') || isempty(file_list)
    error('''file_list'' must be specified');
end


%% Add path of SPM (if needed):
str = which('spm_vol');
if isempty(str)
    dirname = uigetdir(pwd,'Select ''SPM'' directory');
    if isequal(dirname,0)
        error('Can''t find ''SPM''');
    end
    addpath(dirname);
end

global defaults
if isempty(defaults)
    spm_defaults;
end


%% Make index of voxels within ROIs:
fprintf('\nMaking index of voxels:\n');

inf            = spm_vol(file_list{1});
[nouse, xyz_s] = spm_read_vols(inf);

if isempty(xyz)     % whole brain
    ind = 1:size(xyz_s,2);
    xyz = xyz_s;
else                % use ROI
    [nouse, ind] = ismember(xyz',xyz_s','rows');
end


%% Read EPI files:
fprintf('\nReading EPI files:\n');

data = zeros(length(file_list),length(ind));
for itf=1:length(file_list)
    I           = spm_vol(file_list{itf});
    V           = spm_read_vols(I);
    data(itf,:) = V(ind);
    
    fprintf('.');
    if mod(itf,60)==0,  fprintf('\n');  end
end

fprintf('\n');
