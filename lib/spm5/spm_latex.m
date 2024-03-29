function spm_latex(c)
% Convert a job configuration structure into a series of LaTeX documents
%
% Note that this function works rather better in Matlab 7.x, than it
% does under Matlab 6.x.  This is primarily because of the slightly
% different usage of the 'regexp' function.
%____________________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% John Ashburner
% $Id: spm_latex.m 949 2007-10-16 08:19:45Z volkmar $

if nargin==0, c = spm_config; end;

fp = fopen('spm_manual.tex','w');
fprintf(fp,'\\documentclass[a4paper,titlepage]{book}\n');
fprintf(fp,'\\usepackage{epsfig,amsmath,pifont,moreverb,minitoc}\n');
fprintf(fp,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
    '\usepackage[colorlinks=true,',...
    'pdfpagemode=UseOutlines,',...
    'pdftitle={SPM5 Manual},','pdfauthor={The SPM Team},',...
    'pdfsubject={Statistical Parametric Mapping},',...
    'pdfkeywords={neuroimaging, MRI, PET, EEG, MEG, SPM}',...
    ']{hyperref}');

fprintf(fp,'\\pagestyle{headings}\n\\bibliographystyle{plain}\n\n');
fprintf(fp,'\\hoffset=15mm\n\\voffset=-5mm\n');
fprintf(fp,'\\oddsidemargin=0mm\n\\evensidemargin=0mm\n\\topmargin=0mm\n');
fprintf(fp,'\\headheight=12pt\n\\headsep=10mm\n\\textheight=240mm\n\\textwidth=148mm\n');
fprintf(fp,'\\marginparsep=5mm\n\\marginparwidth=21mm\n\\footskip=10mm\n\n');

fprintf(fp,'\\title{\\huge{SPM5 Manual}}\n');
fprintf(fp,'\\author{The FIL Methods Group (and honorary members)}\n');
fprintf(fp,'\\begin{document}\n');
fprintf(fp,'\\maketitle\n');
fprintf(fp,'\\dominitoc\\tableofcontents\n\n');
fprintf(fp,'\\newpage\n\\section*{The SPM5 User Interface}\n');
write_help(c,fp);
for i=1:numel(c.values),
   if isfield(c.values{i},'tag'),
       part(c.values{i},fp);
   end;
end;
%fprintf(fp,'\\parskip=0mm\n\\bibliography{methods_macros,methods_group,external}\n\\end{document}\n\n');
fprintf(fp,'\\parskip=0mm\n');
bibcstr = get_bib(fullfile(spm('dir'),'man','biblio'));

tbxlist = dir(fullfile(spm('dir'),'toolbox'));
for k = 1:numel(tbxlist)
    if tbxlist(k).isdir,
        bibcstr=[bibcstr(:); get_bib(fullfile(spm('dir'),'toolbox', ...
                 tbxlist(k).name))];
    end;
end;
bibcstr = strcat(bibcstr,',');
bibstr  = strcat(bibcstr{:});
fprintf(fp,'\\bibliography{%s}\n',bibstr(1:end-1));
fprintf(fp,'\\end{document}\n\n');
fclose(fp);
return;

function part(c,fp)
if isstruct(c) && isfield(c,'tag'),
    fprintf(fp,'\\part{%s}\n',texify(c.name));
    % write_help(c,fp);
    if isfield(c,'values'),
        for i=1:numel(c.values),
            if isfield(c.values{i},'tag'),
                fprintf(fp,'\\include{%s}\n',c.values{i}.tag);
                chapter(c.values{i});
            end;
        end;
    end;
    if isfield(c,'val'),
        for i=1:numel(c.val),
            if isfield(c.val{i},'tag'),
                if chapter(c.val{i}),
                    fprintf(fp,'\\include{%s}\n',c.val{i}.tag);
                end;
            end;
        end;
    end;
end;
return;

function sts = chapter(c)
fp = fopen([c.tag '.tex'],'w');
if fp==-1, sts = false; return; end;

fprintf(fp,'\\chapter{%s  \\label{Chap:%s}}\n\\minitoc\n\n\\vskip 1.5cm\n\n',texify(c.name),c.tag);
write_help(c,fp);

switch c.type,
case {'branch'},
    for i=1:numel(c.val),
        section(c.val{i},fp);
    end;
case {'repeat','choice'},
    for i=1:numel(c.values),
        section(c.values{i},fp);
    end;
end;
fclose(fp);
sts = true;
return;

function section(c,fp,lev)
if nargin<3, lev = 1; end;
sec = {'section','subsection','subsubsection','paragraph','subparagraph'};
if lev<=5,
    fprintf(fp,'\n\\%s{%s}\n',sec{lev},texify(c.name));
    write_help(c,fp);
    switch c.type,
    case {'branch'},
        for i=1:numel(c.val),
            section(c.val{i},fp,lev+1);
        end;
    case {'repeat','choice'},
        for i=1:numel(c.values),
            section(c.values{i},fp,lev+1);
        end;
    end;
else
    warning(['Too many nested levels... ' c.name]);
end;
return;

function write_help(hlp,fp)
if isstruct(hlp),
    if isfield(hlp,'help'),
       hlp = hlp.help;
    else
        return;
    end;
end;
if iscell(hlp),
    for i=1:numel(hlp),
        write_help(hlp{i},fp);
    end;
    return;
end;
str = texify(hlp);
fprintf(fp,'%s\n\n',str);
return;

function str = texify(str0)
st1  = findstr(str0,'/*');
en1  = findstr(str0,'*/');
st = [];
en = [];
for i=1:numel(st1),
    en1  = en1(en1>st1(i));
    if ~isempty(en1),
        st  = [st st1(i)];
        en  = [en en1(1)];
        en1 = en1(2:end);
    end;
end;

str = [];
pen = 1;
for i=1:numel(st),
    str = [str clean_latex(str0(pen:st(i)-1)) str0(st(i)+2:en(i)-1)];
    pen = en(i)+2;
end;
str = [str clean_latex(str0(pen:numel(str0)))];
return;

function str = clean_latex(str)
str  = strrep(str,'$','\$');
str  = strrep(str,'&','\&');
str  = strrep(str,'_','\_');
%str  = strrep(str,'\','$\\$');
str  = strrep(str,'|','$|$');
str  = strrep(str,'>','$>$');
str  = strrep(str,'<','$<$');
return;

function bibcstr = get_bib(bibdir)
biblist = dir(fullfile(bibdir,'*.bib'));
bibcstr={};
for k = 1:numel(biblist)
    [p n e v] = fileparts(biblist(k).name);
    bibcstr{k}  = fullfile(bibdir,n);
end;
