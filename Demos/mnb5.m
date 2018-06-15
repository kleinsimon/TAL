tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='cr fe c mn al ti b cu mo si ni';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc m23 cem liq';
tcsys.Log=1;
tcsys.Init;

initEq=tcsys.GetInitialEquilibrium;

initEq.SetCondition('t',880 + 273.15);
initEq.SetCondition('p',101325);
initEq.SetCondition('n',1);

initEq.SetCondition('w(*)', 0);
initEq.SetWpc('c', 0.234);
initEq.SetWpc('si', 0.289);
initEq.SetWpc('mn', 1.258);
initEq.SetWpc('cr', 0.119);
initEq.SetWpc('ti', 0.028);
initEq.SetWpc('al', 0.034);
initEq.SetWpc('b', 0.002);

initEq.GetValue('w(fcc,cr)')

initEq.GetValue('vpv(fcc)')