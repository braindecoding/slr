function handle = subplot_bdtb(nrows, ncols, this_plot, rmargin, cmargin, axis_off, dim)
%subplot_bdtb - subplot version modified to arrange in more detail
%
% This function supposes 'axis off' to decide the value of space.
% If use 'axis on,' set the bigger value at 'rmargin' and 'cmargin.'
%
% Input:
%   nrows     - plot number of row
%   ncols     - plot number of column
%   this_plot - number of current plot
% Optional:
%   rmargin   - margin of row (0~1, % of window-height)
%   cmargin   - margin of column (0~1, % of window-width)
%   axis_off  - axis off (1: default), or axis on (0)
%   dim       - dimension of count number (default: 2)
% Output:
%   handle    - handle of subplot
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if exist('nrows','var')==0 || isempty(nrows) || exist('ncols','var')==0 || isempty(ncols) || ...
        exist('this_plot','var')==0 || isempty(this_plot)
    error('This function needs three inputs: nrows, ncols, this_plot');
end
if this_plot<1 || nrows*ncols<this_plot
    error('''this_plot'' must be between 1 and nrows*ncols');
end

if exist('rmargin','var')==0 || isempty(rmargin)
    rmargin = 0.1;      % 10% of window-height
end
if exist('cmargin','var')==0 || isempty(cmargin)
    cmargin = rmargin;
end

if exist('axis_off','var')==0 || isempty(axis_off)
    axis_off = 1;
end

if exist('dim','var')==0 || isempty(dim)
    dim = 2;
end


%% Calculate size of plot-space:
psize_r = (1 - rmargin * (nrows + 1)) / nrows;
psize_c = (1 - cmargin * (ncols + 1)) / ncols;


%% Calculate position of plot-space:
if dim==2       % default
    this_num_r = ceil(this_plot/ncols);
    this_num_c = this_plot - (this_num_r - 1) * ncols;
else            % dim==1
    this_num_c = ceil(this_plot/nrows);
    this_num_r = this_plot - (this_num_c - 1) * nrows;
end

this_pos_r = 1 - (psize_r + rmargin) * this_num_r;
this_pos_c = cmargin + (psize_c + cmargin) * (this_num_c - 1);


%% Subplot:
handle = subplot('position', [this_pos_c this_pos_r psize_c psize_r]);

if axis_off,    axis off;       end
