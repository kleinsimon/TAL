tcsys = sk_tc_system;
tcsys.Database='TCFE9';
tcsys.Elements='Fe c cr si v mn';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc cem liquid';
tcsys.Init;

BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetCondition('t',       1500 + 273.15);
BaseEq.SetCondition('p',       101325);
BaseEq.SetCondition('n',       1);
BaseEq.SetCondition('w(c)',    0.006);
BaseEq.SetCondition('w(cr)',   0.008);
BaseEq.SetCondition('w(si)',   0.002);
BaseEq.SetCondition('w(v)',    0.0085);
BaseEq.SetCondition('w(mn)',   0.003);

Eq1 = BaseEq.Clone;
scheil=sk_tc_scheil1(Eq1);
scheil.StartT=1481 + 273.15;
%scheil.FDE={'C'};
%scheil.calculate;

%scheil.drawScheil;

