function B = resize(A, newSize, filler)
%resize - resizes A to newSize, adding 'filler' when bigger
%B = resize(A, newSize, filler)
%
% Resizes a matrix or cell (of any type, any dimension) to 'newSize';
% cropping what's smaller and filling with 'filler' for what's bigger.
% Default filler = 0 for mats or [] for cells.
%
% Example:
%	>> A = [1 2 3 4];
%	>> B = resize(A, [2 3])
%	B = [1 2 3; 0 0 0]
%	>>B = resize(A, [2 3], 4)
%	B = [1 2 3; 4 4 4]
%
% Calls: same
% Status: tested for different types and sizes
%
% Created  By: Alex Harner (1),	alexh@atr.jp	06/03/06
% Modified By: Alex Harner (1),	alexh@atr.jp	06/07/25
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

oldSize = size(A);
% If newSize==oldSize, then return A as B:
if same(newSize,oldSize,1)==1,
	B = A; return;	% This should only allocate a pointer
end;

% Error checking:
oDims = length(oldSize);
nDims = length(newSize);
%if nDims > 4 | nDims < 2,
%	fprintf('\nError: newSize must have 2 to 4 dimensions!\n');
%	B = -1; return;
%end;

% If some dimension is larger, then we must fill:
% Filler depends on class:
type = class(A);
if strcmpi(type,'cell'),
	B = cell(newSize);
	if exist('filler','var')~=1,
		filler = [];	% default filler
	end;
	B(:) = {filler};
else,
	B = zeros(newSize);
	if exist('filler','var')~=1,
		filler = 0;		% default filler
	end;
	B(:) = filler;
	% If not double, change it:
	if strcmpi(type,'double')~=1,
		B = eval([type '(B)']);
	end;
end;

% Fix dims:
nDims = min(nDims,oDims);
newSize = newSize(1:nDims);
oldSize = oldSize(1:nDims);
% Copy the data to the new mat:
ms = min(oldSize, newSize);	% smallest size of each dimension
%B(1:ms(1),1:ms(2))                 = A(1:ms(1),1:ms(2));
%B(1:ms(1),1:ms(2),1:ms(3),1:ms(4)) = A(1:ms(1),1:ms(2),1:ms(3),1:ms(4));
str1 = 'B(1:ms(1),1:ms(2)';
str2 = 'A(1:ms(1),1:ms(2)';
for dt = 3:nDims,
	str1 = [str1 ',1:ms(' num2str(dt) ')'];
	str2 = [str2 ',1:ms(' num2str(dt) ')'];
end;
str = [str1 ') = ' str2 ');'];
eval([str1 ') = ' str2 ');']);

eval(str);
