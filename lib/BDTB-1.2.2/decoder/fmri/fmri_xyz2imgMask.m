function  fmri_xyz2imgMask(xyz, spaceDefine, savefname)
% create mask image (analyze format) specified by xyz coordinate (MNI)
% fmri_xyz2imgMask(xyz, spaceDefine, savefname)
%
% Input:
%   xyz          - 3xN xyz coordinate in MNI system
%   spaceDefine  - space defining image for the specified coordinate
%   savefname    - filename of output file
% Output:
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('xyz','var') || isempty(xyz)
    warning('''xyz'' isn''t specified, so use all voxels');
end

if ~exist('spaceDefine','var') || isempty(spaceDefine) || ~exist(spaceDefine,'file')
    [spaceDefine, path] = uigetfile({'*.img','Analyze Image file (*.img)'},'Select space define file');
    if isequal(spaceDefine,0)
        error('''spaceDefine'' should be specified');
    end
    spaceDefine = fullfile(path, spaceDefine);
end

if ~exist('savefname','var') || isempty(savefname)
    [savefname, path] = uiputfile({'*.img','Analyze Image file (*.img)'},'Input save file name');
    if isequal(savefname,0)
        error('''savefname'' should be specified');
    end
    savefname = fullfile(path, savefname);
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


%% Create mask:
v       = spm_vol(spaceDefine);
[Y XYZ] = spm_read_vols(v);

ind1    = ismember(XYZ(1,:),xyz(1,:));
ind2    = ismember(XYZ(2,ind1),xyz(2,:));
ind3    = ismember(XYZ(3,ind1(ind2)),xyz(3,:));
volInds = ind1(ind2(ind3));

Y = zeros(size(Y));
Y(volInds) = 1;


%% Create image:
v.fname = savefname;
spm_write_vol(v,Y);

% end