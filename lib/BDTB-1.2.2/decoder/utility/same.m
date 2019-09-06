function [an, count] = same(A, B, quick, thres, verb, Astr, Bstr)
% same - tests recursively whether A and B have all the same elements
% [an, count] = same(A, B, quick, thres, verb, Astr, Bstr)
%
% Inputs:
%	A, B    - anything (numeric, cells, structs, etc.)
% Optional:
%	quick   - for termination after first difference is found
%	thres   - same to within: abs(A-B)<thres; default: 1e-11
%	verb    - print what's different
%	Astr    - name of A variable
%	Bstr    - name of B variable
% Outputs:
%	an      - 1 if true, 0 if false
%	count   - number of items compared
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check pars:
if ~exist('quick','var') || isempty(quick),     quick = 0;          end;
if ~exist('thres','var') || isempty(thres),     thres = 1e-11;      end;
if ~exist('verb','var')  || isempty(verb),      verb = 1;           end;
if ~exist('Astr','var')  || isempty(Astr),      Astr = 'A';         end;
if ~exist('Bstr','var')  || isempty(Bstr),      Bstr = 'B';         end;

count = 0; an = 0;


%% Same class?:
if strcmp(class(A),class(B))==0
    if verb
        fprintf('\n Diff class of %s (%s) and %s (%s).', Astr, class(A), Bstr, class(B));
    end
    return
end


%% Same dims?:
if ndims(A) ~= ndims(B)
    if verb
        fprintf('\n Diff ndims of %s (%d) and %s (%d).', Astr, ndims(A), Bstr, ndims(B));
    end
    return
end


%% Same size?:
C  = eq(size(A),size(B));
if ~eq(sum(C),length(C))
    if verb
        fprintf('\n Diff size of %s [%s] and %s [%s].', Astr, num2str(size(A)), Bstr, num2str(size(B)));
    end
    return
end


%% Elements are the same?:
if isnumeric(A) || ischar(A) || islogical(A)
    if thres > 0
        C     = abs(A-B);
        C     = find(C>thres);
        count = numel(A)-length(C);
		an    = isempty(C);
    else
        C     = eq(B,A);
		count = sum(C(:));
		an    = eq(count, numel(C));
    end
    if an==0
        if verb
            fprintf('\n %d diff elements of %s and %s.', numel(A)-count, Astr, Bstr);
        end
        return
    end
    
% goes through cells recursively:
elseif isa(A, 'cell')
    an = 1;
    for it=1:numel(A)
        AstrIt   = [Astr '{' num2str(it) '}'];
		BstrIt   = [Bstr '{' num2str(it) '}'];
		[at, ct] = same(A{it}, B{it}, quick, thres, verb, AstrIt, BstrIt);
		count    = count + ct;
		if quick && an==0,	return;     end;
		an = an*at;
    end
    
% goes through structs recursively:
elseif isa(A, 'struct') && length(A)>1
    an = 1;
    for it=1:numel(A)
        AstrIt   = [Astr '(' num2str(it) ')'];
		BstrIt   = [Bstr '(' num2str(it) ')'];
		[at, ct] = same(A(it), B(it), quick, thres, verb, AstrIt, BstrIt);
		count    = count + ct;
		if quick && an==0,  return;     end;
		an = an*at;
    end
    
elseif isa(A, 'struct')
    names = fieldnames(A);
	an    = same(names, fieldnames(B), quick, thres, 0, Astr, Bstr);
    if an==0
        if verb
            fprintf('\n Diff fieldnames of %s and %s.', Astr, Bstr);
        end
		if quick,   return;     end;
    end
    for it=1:numel(names)
        name = names{it};
		if ~isfield(B,name),    continue;   end;
        Af       = A.(name);
        Bf       = B.(name);
		[at, ct] = same(Af, Bf, quick, thres, verb, [Astr '.' name], [Bstr '.' name]);
		count    = count + ct;
		if quick && an==0,  return;     end;
		an = an*at;
    end
end
