function B = expandPat(A, newSize)
%expandPat - expands A by repeating but cropping to newSize
%B = expandPat(A, newSize)
%
% Expands a matrix A to newSize using repmat (repeating the pattern),
% but cropping the pattern at newSize (its absolute size, not rep #).
%
% Input: A - matrix of any class, any dimension
%
% Calls: resize -> same
% Status: tested for different sizes, dims, and types
%
% Created  By: Alex Harner (1),	alexh@atr.jp	06/06/28
% Modified By: Alex Harner (1),	alexh@atr.jp	06/07/25
% (1) ATR Intl. Computational Neuroscience Labs, Decoding Group

% Check and fix dims:
oldSize = size(A);
nDims = length(newSize);
oDims = length(oldSize);
if nDims<oDims,
	fprintf('\nError: newSize can not be smaller than size(A)!');
	B = A; return;
end;
for n = oDims:nDims-1,
	oldSize = [oldSize 1];
end;
% Determine repeating:
repSize = ceil(newSize./oldSize);
B = repmat(A, repSize);
% Crop off extra from repmat:
B = resize(B, newSize);
