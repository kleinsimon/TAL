TCSYS = sk_tc_system;
TCSYS.Database='TCFE9';
TCSYS.Elements='Fe c cr si v mn';
TCSYS.RejPhases='*';
TCSYS.ResPhases='fcc bcc cem liquid';
TCSYS.Init;

BaseEq=TCSYS.GetInitialEquilibrium;
BaseEq.SetCondition('t',       1500 + 273.15);
BaseEq.SetCondition('p',       101325);
BaseEq.SetCondition('n',       1);
BaseEq.SetCondition('w(c)',    0.016);
BaseEq.SetCondition('w(cr)',   0.008);
BaseEq.SetCondition('w(si)',   0.002);
BaseEq.SetCondition('w(v)',    0.085);
BaseEq.SetCondition('w(mn)',   0.003);
Eq1 = BaseEq.Clone;

Eq1.Calculate;

scheil=sk_tc_scheil(Eq1);
scheil.StartT=1651;
scheil.calculate;
scheil.drawScheil;

