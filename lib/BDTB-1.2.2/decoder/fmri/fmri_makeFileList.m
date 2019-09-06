function epi_files = fmri_makeFileList(D, P)
% fmri_makeFileList - makes EPI file list from design, P.fMRI, and P.paths
% epi_files = fmri_makeFileLest(design, P)
%
% Input:
%   D.design      - design matrix
%   D.design_type - name of each design type
%   P.fMRI        - fMRI-specific parameters
%                   use 'begin_vols', 'run_names', and 'base_file_name'
%   P.paths       - path of directory having EPI files
% Output:
%   epi_files     - EPI file list
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('D','var') || isempty(D)
    error('''D''ata-struct should be specified');
end
design      = getFieldDef(D,'design',[]);
design_type = getFieldDef(D,'design_type',[]);
if isempty(design) || isempty(design_type)
    error('''D''ata-struct is wrong');
end

if ~exist('P','var') || isempty(P)
    error('''P''ars-struct should be specified');
end
fMRI  = getFieldDef(P,'fMRI', []);
paths = getFieldDef(P,'paths',[]);
if isempty(fMRI) || isempty(paths)
    error('''P''ars-struct is wrong');
end

base_file_name     = getFieldDef(fMRI,'base_file_name','a');
run_names          = getFieldDef(fMRI,'run_names','a');
begin_vols         = getFieldDef(fMRI,'begin_vols',1);
dir_name           = fixDirname(getFieldDef(paths,'to_realigned','.'));


%% Calculate num of files in each run
ind           = find(ismember(design_type,'run'));
if isempty(ind),    ind = 1;    end
num_runs      = design(end,ind);
num_files     = size(design,1);
num_files_run = diff([0 find(diff(design(:,ind)))' num_files]);
temp          = unique(num_files_run);
if length(temp)==1
    num_files_run = unique(num_files_run);
end


%% Make file list
fprintf('\nMaking EPI file list:\n');

dir_name  = repmat(dir_name,[num_files,1]);
base_name = repmat(base_file_name,[num_files,1]);
ext_name  = repmat('.img',[num_files,1]);
if length(num_files_run)==1
    run_name = cell(num_runs,1);
    for itr=1:num_runs
        run_name{itr} = repmat(run_names{itr},[num_files_run,1]);
    end
    num_name  = repmat(num2str(((0:num_files_run-1)+begin_vols)','%04d'),[num_runs,1]);
    epi_files = cell(num_files,1);
    for itr=1:num_runs
        inds            = ((itr-1)*num_files_run+1:itr*num_files_run);
        epi_files(inds) = cellstr([dir_name(inds,:) base_name(inds,:) run_name{itr} num_name(inds,:) ext_name(inds,:)]);
    end
else
    run_name = cell(num_runs,1);
    num_name = cell(num_runs,1);
    for itr=1:num_runs
        run_name{itr} = repmat(run_names{itr},[num_files_run(itr),1]);
        num_name{itr} = num2str(((0:num_files_run(itr)-1)+begin_vols)','%04d');
    end
    epi_files     = cell(num_files,1);
    sum_files_run = [0 cumsum(num_files_run)];
    for itr=1:num_runs
        inds            = (sum_files_run(itr)+1:sum_files_run(itr+1));
        epi_files(inds) = cellstr([dir_name(inds,:) base_name(inds,:) run_name{itr} num_name{itr} ext_name(inds,:)]);
    end
end
