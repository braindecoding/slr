function printResults(res)
% printResults - prints results with freq_table and correct_per
% printResults(res)
%
% Input:
%	res        - some result containing 'freq_table' and 'correct_per'
%
% ----------------------------------------------------------------------------------------
% Created by members of
%     ATR Intl. Computational Neuroscience Labs, Dept. of Neuroinformatics


%% Check and get pars:
if ~exist('res','var') || isempty(res),     error('Wrong args');	end
if size(res,2)~=1,                          res = res(:,end);       end

num_model   = size(res,1);
freq_table  = cell(num_model,1);
correct_per = cell(num_model,1);
for itm=1:num_model
    freq_table{itm,1}  = getFieldDef(res{itm,1},'freq_table',[]);
    correct_per{itm,1} = getFieldDef(res{itm,1},'correct_per',[]);
    
    if isempty(freq_table{itm,1}) || isempty(correct_per{itm,1}),   error('Wrong args');    end
end


%% Print results:
for itm=1:num_model
    fprintf('\nResults *************************');
    if num_model>1,     fprintf('\n Model: %s',res{itm,1}.model);   end
    fprintf('\n Percent Correct: %6.2f',correct_per{itm,1});
    fprintf('\n Frequency Table:\n');
    fprintf(['  ' repmat('%4d ', 1, size(freq_table{itm,1},2)) '\n'], freq_table{itm,1}');
end
