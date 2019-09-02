roiAreaList = {'V1V2'};

for i = 1:length(roiAreaList)
    for imgTestRunIdx = 1:10
    
        calCombCoef_randRecon_smlr('1x1','errFuncImageNonNegCon',imgTestRunIdx, roiAreaList{i})
        %calCombCoef_randRecon_smlr('1x1','no_opt','imgTestRunIdx, roiAreaList{i})
        %calCombCoef_randRecon_smlr('1x1_1x2_2x1_2x2','errFuncImageNonNegCon',imgTestRunIdx, roiAreaList{i})
        %calCombCoef_randRecon_smlr('1x2','errFuncImageNonNegCon',imgTestRunIdx, roiAreaList{i})
        %calCombCoef_randRecon_smlr('2x1','errFuncImageNonNegCon',imgTestRunIdx, roiAreaList{i})
        %calCombCoef_randRecon_smlr('2x2','errFuncImageNonNegCon',imgTestRunIdx, roiAreaList{i})
        
    end
end
