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
% initEq.SetCondition('w(c)', 0.0021);
% initEq.SetCondition('w(mn)', 0.0125);
% initEq.SetCondition('w(cr)', 0.012);
% initEq.SetCondition('w(al)', 0.0003);
% initEq.SetCondition('w(ti)', 0.0003);
% initEq.SetCondition('w(b)', 0.00003);
% initEq.SetCondition('w(si)', 0);
% initEq.SetCondition('w(ni)', 0);
% initEq.SetCondition('w(cu)', 0);
% initEq.SetCondition('w(mo)', 0);

initEq.SetCondition('w(*)', 0);
initEq.SetWpc('c', 0.234);
initEq.SetWpc('si', 0.289);
initEq.SetWpc('mn', 1.258);
initEq.SetWpc('cr', 0.119);
initEq.SetWpc('ti', 0.028);
initEq.SetWpc('al', 0.034);
initEq.SetWpc('b', 0.002);

%ac3=tc_calc_ac3({'w(c)'},0.0021);
