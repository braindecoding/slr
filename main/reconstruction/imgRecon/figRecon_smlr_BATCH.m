%figRecon_smlr('1x1','errFuncImageNonNegCon','V1V2')
%figRecon_smlr('1x1','no_opt','V1V2')
%figRecon_smlr('1x1_1x2_2x1_2x2','errFuncImageNonNegCon','V1V2')
%figRecon_smlr('1x2','errFuncImageNonNegCon','V1V2')
%figRecon_smlr('2x1','errFuncImageNonNegCon','V1V2')
%figRecon_smlr('2x2','errFuncImageNonNegCon','V1V2')

%% using scale 1x1 for proposal
figRecon_smlr('1x1','errFuncImageNonNegCon','V1');
figRecon_smlr('1x1','no_opt','V1');

figRecon_smlr('1x1','errFuncImageNonNegCon','V2');
figRecon_smlr('1x1','no_opt','V2');

figRecon_smlr('1x1','errFuncImageNonNegCon','V3VP');
figRecon_smlr('1x1','no_opt','V3VP');

figRecon_smlr('1x1','errFuncImageNonNegCon','AllArea');
figRecon_smlr('1x1','no_opt','AllArea');

