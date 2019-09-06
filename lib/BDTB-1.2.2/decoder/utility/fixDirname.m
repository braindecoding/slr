function dirname = fixDirname(dirname_in, OS)
% fixDirname - fixes dirname with pathes for the appropriate OS, converting slashes (\/)
% dirname = fixDirname(dirname_in, OS)
%
% Input:
%   dirname_in - path to directory
% Optional:
%   OS         - target OS for returned 'path'
%                0:UNIX,Mac, 1:Windows, same value as the return-value of 'ispc'
% Output:
%   dirname    - dirname_in fixed for the current OS or given 'OS'
%
% Calls:
%   fixPath - fixes pathes
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('dirname_in','var') || isempty(dirname_in)
    dirname = '';
    return;
end

if ~exist('OS','var') || isempty(OS)
    OS = ispc;
end


%% Add '\', if the end of 'dirname_in' isn't '\' or '/':
if ~strcmp(dirname_in(end),'\') && ~strcmp(dirname_in(end),'/')
    dirname_in = [dirname_in '\'];
end


%% Fix dirname:
dirname = fixPath(dirname_in,OS);
