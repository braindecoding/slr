%calCombCoef_figRecon_smlr('1x1','errFuncImageNonNegCon','V1V2')
%calCombCoef_figRecon_smlr('1x1','no_opt','V1V2')    
%calCombCoef_figRecon_smlr('1x1_1x2_2x1_2x2','errFuncImageNonNegCon','V1V2')
%calCombCoef_figRecon_smlr('1x2','errFuncImageNonNegCon','V1V2')
%calCombCoef_figRecon_smlr('2x1','errFuncImageNonNegCon','V1V2')
%calCombCoef_figRecon_smlr('2x2','errFuncImageNonNegCon','V1V2')
%cara jalanin nya extract decoder dulu pastikan di workspace kita memilih areaROI yang dimaksud
%nanti akan terpause, baru masuk ke langkah ini sesuai areROI

%% using scale 1x1 for proposal
calCombCoef_figRecon_smlr('1x1','errFuncImageNonNegCon','V1')
calCombCoef_figRecon_smlr('1x1','no_opt','V1')

calCombCoef_figRecon_smlr('1x1','errFuncImageNonNegCon','V2');
calCombCoef_figRecon_smlr('1x1','no_opt','V2');

calCombCoef_figRecon_smlr('1x1','errFuncImageNonNegCon','V3VP')
calCombCoef_figRecon_smlr('1x1','no_opt','V3VP')

calCombCoef_figRecon_smlr('1x1','errFuncImageNonNegCon','AllArea');
calCombCoef_figRecon_smlr('1x1','no_opt','AllArea');




