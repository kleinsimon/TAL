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
initEq.SetWpc('cr', 0.13);
initEq.SetWpc('ti', 0.028);
initEq.SetWpc('al', 0.034);
initEq.SetWpc('b', 0.002);

initEq.Calculate;

prop=sk_func_tc_properties(initEq);
prop.Properties={'t_c(ac1)','t_c(ac3)','t_c(ms_barbier(ac3+50))'};

solvfun = sk_solver_eval_func;
solvfun.zObjects={prop};

varValues={'w(C)','w(Mn)','w(Cr)','w(Ni)','w(Si)','w(Mo)'};

mapper=sk_mapper;
mapper.Mode = 3;
mapper.zSolver = solvfun;
mapper.Components = varValues;
mapper.Ranges={...
    [0.001, 0.005, 6]...  %C
    [0.0, 0.10, 11]...  %Mn
    [0.0, 0.10, 11]...  %Cr
    [0.0, 0.02, 6]...  %Ni
    [0.0, 0.02, 6]...  %Si
    [0.0, 0.02, 6]...  %Mo
    };

mapper.doMapping;
mapper.getResult()