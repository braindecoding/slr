function path = fixMkDir(path_in)
% fixMkDir - fixes a dir path and makes it if it doesn't exist
% path = fixMkDir(path_in)
%
% Input:
%   path_in  - any path directory (to a folder) (in Win or Unix)
% Output:
%   path     - path fixed for the current OS
%
% Calls:
%   fixDirname - fixes dirname with pathes
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('path_in','var') || isempty(path_in)
    path = '';
    return;
end


%% Fix dirname:
path = fixDirname(path_in);


%% Make directory
if ~exist(path,'dir')
	mkdir(path);
end
