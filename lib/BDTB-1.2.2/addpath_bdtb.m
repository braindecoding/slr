function addpath_bdtb
% addpath_bdtb - addpath directories for 'BDTb' functions
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


path = fileparts(which(mfilename));
%addpath(genpath(path));

addpath(fullfile(path,'decoder','fmri'));
addpath(fullfile(path,'decoder','general'));
addpath(fullfile(path,'decoder','utility'));
