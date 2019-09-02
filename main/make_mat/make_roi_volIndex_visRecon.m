function [ roiCells, si_roi_all_volInds ] = make_roi_volIndex_visRecon( roiPath, roiFiles, volPathFile )
%fmri_readRois - finds volume indices and stat vals of all ROIs
%[roiCells, si_roi_all_volInds, stat_roi_all] = fmri_readRois(roiPath, roiFiles, volPathFile)
%
% Given a list of ROI files, their path, and a volume to read,
% finds the indices in the volume that match the selected ROI
% coordinates and corresponding stat (vmp, t-, f-,...) vals.
%
% Input:
%	roiPath      - a path to the ROI files
%	roiFiles     - a [M x N] cells of ROI file names
%	volPathFile  - a file with path of a volume to be read for XYZ info
%
% Output:
%	roiCells     - a [M x N] cell of volume indices for each ROI
%	si_roi_all_volInds - a [L x 1] matrix of all ROI volume indices (with dups)
%	stat_roi_all - a [L x S] matrix of stat values for each ROI index,
%					  where S is the number of stats
%
% Example: see /home/neo/code/fmri/data_conversion/make_fmri_roi_janken_v2.m
%
% Status: basic testing
%
% Created  By: Shigeyuki Ikeda (1),	shigeyuki-i@is.naist.jp	12/02/03

%% Add necessary paths (if needed):
str = which('spm_vol');
if isempty(str), addpath_amh('open/spm99/'); end;

%% Read volume (volPathFile) for XYZ coordinates:
volPathFile = fixPath(volPathFile);
roiPath = fixPath(roiPath);
fprintf('\nReading volume:\n %s\n for ROI.\n', volPathFile);
volInfo = spm_vol(volPathFile);
[Y,XYZ] = spm_read_vols(volInfo,[]);
clear Y;

%% Initize output variables:
roiCells = cell(size(roiFiles));
roiFiles = roiFiles(:);		% linearize
% Ikeda added si_roi_all_xyz, roi, and tvals (new)
si_roi_all_volInds = []; stat_roi_all = [];
bi = 1; ei = 1;
%% Loop through ROI files
for it=1:length(roiFiles)
	% Load ROI file (also if has not .mat or VOX_).
	fName = roiFiles{it};
    if isempty(fName)
      continue;
	end;
	%[path,fn,ext,ver] = fileparts(fName);
	[path,fn,ext] = fileparts(fName); % ym20120621
	if strcmpi(ext,'.mat') ~= 1,
		fName = [fName '.mat'];
	end;
	
	if     exist([roiPath fName],'file')==2,
		 fName = [roiPath fName];
	elseif exist([roiPath 'VOX_' fName],'file')==2,
		 fName = [roiPath 'VOX_' fName];
	end;
	fprintf('\nReading ROI file:\n %s\n', fName);
try	
	fInfo = load(fName);catch, fprintf('cannot read files');keyboard, end;
	% Extract roiCurr data:
	fVarName = fieldnames(fInfo);
	fVarName = fVarName{1};
	roiCurr  = eval(['fInfo.' fVarName]);	% [(xyz,t) x # roi voxels]
	% If statNum > 1 (previous), increase it:
	statNum  = max(0,min(size(roiCurr,1))-3);

	%% New algorithm for finding roiCurr values in XYZ volume data:
	% Because XYZ is very large and roiCurr is much smaller, the following
	% is done for speed:
	%  (1) Sort roiCurr by its X values (roiX)
	%  (2) Loop through roiCurr values, xyz = (x, y, z)
	%  (3) Find all values of a given x in XYZ and put them in XYZ1
	%  (4) Since XYZ1 is MUCH small than XYZ, we can then find y MUCH faster.
	%  (5) Likewise, with z in XYZ2.
	%  (6) Next iteration, check to see if the next x is the same as the last.
    %      If so, we don't need to reform XYZ1, thus avoiding the most costly find.
	%      Since we sorted roiCurr by X, there is a high probability that the
	%	   next x will be the same as the last, hence saving significant time.
	%  Time savings summary:
	%  2.84->1.03 sec for using a limited XYZ1 & XYZ2 for finding y & z.
	%  1.03->0.06 sec for sorting roiCurr by X to avoid finding X in XYZ
	%				  for same values of X
	
    roiX = roiCurr(1,:);			% get X values for sorting
	[roiX ixX] = sort(roiX,2);		% sort roiCurr by X values
	roiCurr = roiCurr(:,ixX);

	last = 1000*min(roiCurr(:));
	xyzLast = last*ones(3,1);
	clear roiX ixX last;
	
	roiCurrIx=[]; %roiCurrStat=[];
	for kt = 1:size(roiCurr,2) 		% loop over roi voxels
		xyz = roiCurr(1:3, kt);		% get one value of roiCurr
		
		x = xyz(1);					% get just X for speed
		if x ~= xyzLast(1),			% only if X if different from last,
			ix1 = find(XYZ(1,:)==x);% then find X in XYZ
			XYZ1 = XYZ(:,ix1);		% make a new XYZ with matching X
		end;

		y = xyz(2);
		if y ~= xyzLast(2),
			ix2 = find(XYZ1(2,:)==y);
			XYZ2 = XYZ1(:,ix2);
		end;

		z = xyz(3);
		if z ~= xyzLast(3),
			ix3 = find(XYZ2(3,:)==z);		
			XYZ3 = XYZ2(:,ix3);
		end;

		if length(ix3)==1,
			ix = ix1(ix2(ix3));
			
			roiCurrIx  = [roiCurrIx; ix];
			% 4:3+statNum is for handling additional stats as additional
			% rows in the ROI file:
			%roiCurrStat = [roiCurrStat; roiCurr(4:3+statNum,kt)'];
        else
		  fprintf('not unique roi\n')
		  ['ROI value not unique!']
		end;
		xyzLast = xyz;
	end;

	% Copy each ROI to output values:
	roiCells{it} = roiCurrIx;
	si_roi_all_volInds = [si_roi_all_volInds; roiCurrIx];
        try
	%stat_roi_all = [stat_roi_all; roiCurrStat];
        catch
            fprintf('hoge\n')
            keyboard
            end
	fprintf(' %d voxels found\n', length(roiCurrIx));
end;
end
