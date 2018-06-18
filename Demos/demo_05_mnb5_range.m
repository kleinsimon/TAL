%Demonstrates the use of sk_range_extremes. Here, the max and min of MS are
%calculated in the normed range of 22MnB5

echo on

%% Initialize system
tcsys = sk_tc_system;
tcsys.Database='TCFE9';
tcsys.Elements='cr fe c mn al ti b cu mo si ni';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc m23 cem';
tcsys.Log=1;
tcsys.Init;

%%Set Conditions for 22MnB5
initEq=tcsys.GetInitialEquilibrium;
initEq.SetCelsius(950);
initEq.SetCondition('p',101325);
initEq.SetCondition('n',1);
initEq.SetCondition('w(*)', 0);
initEq.SetWpc('c', 0.25);
initEq.SetWpc('si', 0.4);
initEq.SetWpc('cr', 0.35);
initEq.SetWpc('ti', 0.05);
initEq.SetWpc('al', 0.06);
initEq.SetWpc('b', 0.005);

%%Set the properties to find extremes for
ms=sk_func_tc_properties(initEq);
ms.Properties={'ms_barbier(t_c=950)'};

ms2=sk_func_tc_properties(initEq);
ms2.Properties={'ms_andrews(t_c=950)'};

%% Initialize the extreme solver. Searches for min and max of the given Properties in the given range
extr=sk_range_extremes;
extr.zObjects={ms,ms2};
extr.Components={'w(C)','w(Si)','w(Mn)','w(Cr)','w(Ti)','w(Al)'};
extr.minComp=[0.0019 0.0001 0.011 0.0015 0.0002 0.0002];
extr.maxComp=[0.0025 0.004  0.014 0.0035 0.0005 0.0006];

%%Start calculation and print result.
extr.calculate;
extr.ResTable
