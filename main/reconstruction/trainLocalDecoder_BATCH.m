%trainLocalDecoder('s1_s1071119',{'1x1'},'V1V2','leave0',0);
%trainLocalDecoder('s1_s1071119',{'1x1'},'V1V2','leave1',0);

%trainLocalDecoder('s1_s1071119',{'1x2'},'V1V2','leave0',0);
%trainLocalDecoder('s1_s1071119',{'1x2'},'V1V2','leave1',0);

%trainLocalDecoder('s1_s1071119',{'2x1'},'V1V2','leave0',0);
%trainLocalDecoder('s1_s1071119',{'2x1'},'V1V2','leave1',0);
 
%trainLocalDecoder('s1_s1071119',{'2x2'},'V1V2','leave0',0);
%trainLocalDecoder('s1_s1071119',{'2x2'},'V1V2','leave1',0);


%% or juist write as follows,

trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V1V2','leave0',0);
trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V1V2','leave1',0);

trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V1','leave0',0);
trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V1','leave1',0);

trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V2','leave0',0);
trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V2','leave1',0);

trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V3','leave0',0);
trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'V3','leave1',0);

trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'AllArea','leave0',0);
trainLocalDecoder('s1_s1071119',{'1x1','1x2','2x1','2x2'},'AllArea','leave1',0);

%ada kekurangan pada label 60
trainLocalDecoder('s1_s1071119',{'2x2'},'AllArea','leave1',0);
