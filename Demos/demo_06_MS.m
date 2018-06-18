%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates the usage of properties in a mapper with fixed conditions
%Calculates MS, compares the different models and checks if other phases
%are stable
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% System init

tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='fe mn c';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc liq cem';
tcsys.Init;

%% Conditions

BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetDefaultConditions;
BaseEq.SetDegree(900);
BaseEq.SetWpc('C', 0.3);
BaseEq.SetWpc('MN', 25);

Eq=BaseEq.Clone;

%% Properties to calculate

fun = sk_func_tc_properties(Eq,{'ms_andrews(t=1200)' 'ms_barbier(t=1200)' 'ms_rowland(t=1200)' 'ms_steven(t=1200)' 'phase_content("fcc",t=1200)'});

solvfun = sk_solver_eval_func;
solvfun.zObjects=fun;

%% Initialize the mapper. Mode 0: all n vs m combinations

mapper=sk_mapper;
mapper.Mode = 0;
mapper.zSolver = solvfun;
mapper.Components = {'w(c)','w(mn)'};
mapper.Ranges={...
    [0.001, 0.003, 10],...   %Range for C
    [0.1 0.35 10],...  %Range for Mn
    };

mapper.doMapping;

res=mapper.getResult()
