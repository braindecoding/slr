function [B, rowRep, colRep] = removeReps(A, dim)
%removeReps - removes successive repetitions from A
%[B, rowRep, colRep] = removeReps(A)
%
% Input:
%	A      - any [M x N] matrix
% Optional:
%	dim    - 0-both dims, 1-rows only, 2-cols only (default: 0)
% Output:
%	B      - A without successive repetitions
%   rowRep, colRep - row and column indices used to reconstruct A, as:
%	         A = repElements(B, rowRep, colRep);        
%
%	Example:
%	>> A = [1 1 2 2 2 2 1 1; 5 5 4 4 6 6 5 5; 5 5 4 4 6 6 5 5];
%	>> [B, rowRep, colRep] = removeReps(A);
%	>> B
%	B =     1     2     2     1
%           5     4     6     5
%	>> C = repElements(B, rowRep, colRep);
%	>> same(A,C)
%	ans = 1
%
% See also 'repElements'
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


% Defaults:
if exist('dim','var')==0, dim = 0; end;
rowRep = ones(size(A,1),1);
colRep = ones(1,size(A,2));
B = A;

% Error checking:
if ndims(A)~=2,
	fprintf('\n removeReps error: A should only have 2 dims!\n');
	return;
elseif dim<0 || dim>2,
	fprintf('\n removeReps error: dim must be 0 (both), 1 (rows), or 2 (cols) \n');
	return;
end;

% Remove along cols & find colRep:
if dim==2 || dim==0,
	Ia = [];
	for it = 1:size(A,1),
		av = A(it,:);
		I = [find(abs(diff(av))) length(av)];
		Ia = unique([Ia I]);
	end;
	B = A(:,Ia);
	colRep = ones(size(Ia));
	colRep(1) = Ia(1);
	for it = 2:length(Ia),
		colRep(it) = Ia(it) - Ia(it-1);
	end;
	A = B;
end;

% Remove along rows & find rowRep:
if dim==1 || dim==0,
	Ia = [];
	for it = 1:size(A,2),
		av = A(:,it);
		I = [find(abs(diff(av))) length(av)];
		Ia = unique([Ia I]);
	end;
	Ia = Ia';
	B = A(Ia,:);
	rowRep = ones(size(Ia));
	rowRep(1) = Ia(1);
	for it = 2:length(Ia),
		rowRep(it) = Ia(it) - Ia(it-1);
	end;
end;
