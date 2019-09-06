function [nse] = read_neuralynx_nse(filename, begrecord, endrecord)

% READ_NEURALYNX_NSE reads a single electrode waveform file
%
% Use as
%   [nse] = read_neuralynx_nse(filename)
%   [nse] = read_neuralynx_nse(filename, begrecord, endrecord)

% Copyright (C) 2005-2007, Robert Oostenveld
%
% $Log: read_neuralynx_nse.m,v $
% Revision 1.8  2007/03/21 17:06:57  roboos
% updated the documentation
%
% Revision 1.7  2006/12/13 15:46:31  roboos
% read and keep timestamps as uint64
%
% Revision 1.6  2006/12/12 11:31:31  roboos
% cleaned up the code, made code more consistent with other neuralynx functions, moved subfunctions to seperate files, use numeric arrays instead of cell-arrays for storing the data
%
% Revision 1.5  2006/03/29 15:01:30  roboos
% fix for previous update: only apply the scaling to uV if data has been read
%
% Revision 1.4  2006/03/29 14:43:26  roboos
% scale the output data to uV, using ADBitVolts and an additional 1e6
%
% Revision 1.3  2006/03/23 18:02:44  roboos
% change endrecord from inf into the actual number present
% preallocate memory to hold the results
%
% Revision 1.2  2005/09/09 12:30:08  roboos
% implemented the core functionality
%
% Revision 1.1  2005/08/05 13:41:39  roboos
% new implementation
%

if nargin<2
  begrecord = 1;
end
if nargin<3
  endrecord = inf;
end

% the file starts with a 16*1024 bytes header in ascii, followed by a number of records
hdr = neuralynx_getheader(filename);
fid = fopen(filename, 'rb', 'ieee-le');

% determine the length of the file
fseek(fid, 0, 'eof');
headersize = 16384;
recordsize = 112;
NRecords   = floor((ftell(fid) - headersize)/recordsize);

if begrecord<1
  error('cannot read before the first record');
elseif endrecord>NRecords
  endrecord = NRecords;
end

if endrecord>=begrecord
  % rewind to the first record to be read
  fseek(fid, headersize + (begrecord-1)*recordsize, 'bof');

  numrecord    = (endrecord-begrecord+1);
  TimeStamp    = zeros(1,numrecord,'uint64');
  ScNumber     = zeros(1,numrecord);
  CellNumber   = zeros(1,numrecord);
  Param        = zeros(8,numrecord);
  Samp         = zeros(32,numrecord);

  k = 1;
  while (begrecord+k-1)<=endrecord
    % read a single electrode record
    TimeStamp(k)   = fread(fid,  1, 'uint64=>uint64');
    ScNumber(k)    = fread(fid,  1, 'int32');
    CellNumber(k)  = fread(fid,  1, 'int32');
    Param(:,k)     = fread(fid,  8, 'int32');
    Samp(:,k)      = fread(fid, 32, 'int16');
    k = k + 1;
  end

  nse.TimeStamp   = TimeStamp;
  nse.ScNumber    = ScNumber;
  nse.CellNumber  = CellNumber;
  nse.Param       = Param;
  % apply the scaling factor from ADBitVolts and convert to uV
  nse.dat         = Samp * hdr.ADBitVolts * 1e6;
end
fclose(fid);

nse.NRecords = NRecords;
nse.hdr      = hdr;
