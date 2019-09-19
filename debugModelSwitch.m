[resultsTr, parm] = modelSwitch(Dtr, parm, parm.model);

Dtr.label=D.label
Dtr.label = D.label(:,2:end);
Dtr.data=D.data

[resultsTr, parm] = modelSwitch(Dtr, parm, parm.model);