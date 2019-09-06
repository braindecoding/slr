function numString=padZeros(number, zeroString)
% pad zeros before number
%
% e.g.,  '00012'=padZeros(12, '00000')


% numString='000';
c=num2str(number); cSize=size(c,2);
zeroString(size(zeroString,2)-cSize+1:size(zeroString,2))=c;
numString=zeroString;