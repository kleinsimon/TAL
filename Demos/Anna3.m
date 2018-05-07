tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='C MN cr si ni mo v nb n fe';
tcsys.RejPhases='*';
tcsys.ResPhases='sigma m23 laves m6c fcc bcc liquid gas';
tcsys.Init;

initEq=tcsys.GetInitialEquilibrium;
conds = 'T=1323 P=1e8 N=1 W(C)=1.22E-3 W(MN)=2.68E-3 W(CR)=0.1545 W(SI)=4E-2 W(NI)=4.14E-3 W(MO)=1.074E-2 W(V)=9.56E-2 W(NB)=1.8E-3 W(N)=0.0101';
initEq.SetConditions(conds);
%initEq.DisplayEquilibrium;

baseEq=initEq.Clone();

fun = sk_func_get_values;
fun.tc_expressions={'gm(bcc)'};
%fun.phase1 = 'fcc';
%fun.phase2 = 'bcc';
fun.BaseEq = baseEq;

solvfun = sk_solver_eval_func;
solvfun.zObjects=fun;

mapper=sk_mapper;
mapper.Mode = 0;
mapper.zSolver = solvfun;
mapper.Components = {'w(n)','w(si)'};
mapper.Ranges={...
    [0. 0.04, 10],...  %N
    [0, 0.08, 10],...  %Si
    };

mapper.doMapping;
mapper.plot();
res=mapper.getResult();
