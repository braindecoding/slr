function out = getFieldDef(S, field, default)
% getFieldDef - returns either S.<field> or default
% out = getFieldDef(S, field, default)
%
% If string 'field' is a field of structure S, it returns this value
% otherwise, it returns default in out.
%
% Input:
%   S       - any structure
%   field   - string with possible field of S
%   default - default to assign to 'out', if 'field' doesn't exist
% Output:
%   out     - any variable output
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('default','var') || isempty(default)
    default = [];
end

if ~exist('S','var') || isempty(S) || ~exist('field','var') || isempty(field)
    out = default;
    return;
end


%% Return value:
out = default;
if isfield(S,field)
    out = S.(field);
end
