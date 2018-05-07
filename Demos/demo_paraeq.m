tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='Fe C Cr';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc';
tcsys.Log=1;
tcsys.Init;

BaseEq=tcsys.GetInitialEquilibrium;

BaseEq.SetCondition('t', 1100);
BaseEq.SetCondition('p', 101325);
BaseEq.SetCondition('n', 1);
BaseEq.SetCondition('n(cr)', 0.005);
BaseEq.SetCondition('n(c)', 0.005);

BaseEq.DisplayEquilibrium;

para = sk_tc_paraequilibrium(BaseEq);

para.calculate;
para.Display;