tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='fe mn c';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc liq cem';
tcsys.Init;

BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetDefaultConditions;
BaseEq.SetDegree(900);
BaseEq.SetWpc('C', 0.3);
BaseEq.SetWpc('MN', 25);

Eq=BaseEq.Clone;

fun = sk_func_tc_properties(Eq,{'double(ms_barbier(t=1200))' 'double(phase_content("fcc",t=1200))'});

solvfun = sk_solver_eval_func;
solvfun.zObjects=fun;

mapper=sk_mapper;
mapper.Mode = 0;
mapper.zSolver = solvfun;
mapper.Components = {'w(c)','w(mn)'};
mapper.Ranges={...
    [0.001, 0.003, 10],...  
    [0.1 0.35 10],...  
    };

mapper.doMapping;

res=mapper.getResult();
