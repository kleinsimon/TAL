tcsys = sk_tc_system;
tcsys.Database='TCFE9';
tcsys.Elements='cr fe c mn al ti b cu mo si ni';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc m23 cem';
tcsys.Log=1;
tcsys.Init;


initEq=tcsys.GetInitialEquilibrium;


initEq.SetCondition('t',880 + 273.15);
initEq.SetCondition('p',101325);
initEq.SetCondition('n',1);


initEq.SetCondition('w(*)', 0);
initEq.SetWpc('c', 0.25);
initEq.SetWpc('si', 0.4);
initEq.SetWpc('cr', 0.35);
initEq.SetWpc('ti', 0.05);
initEq.SetWpc('al', 0.06);
initEq.SetWpc('b', 0.005);



ac3=sk_func_tc_properties(initEq);
ac3.Properties={'ac3'};

ms=sk_func_tc_properties(initEq);
ms.Properties={'ms_barbier(ac3+50)'};


extr=sk_range_extremes;
extr.Components={'w(C)','w(Si)','w(Mn)','w(Cr)','w(Ti)','w(Al)'};
extr.zObjects={ac3, ms};
extr.minComp=[0.0019 0.0001 0.011 0.0015 0.0002 0.0002];
extr.maxComp=[0.0025 0.004  0.014 0.0035 0.0005 0.0006];
extr.Mode=2;

extr.calculate;
extr.ResTable
