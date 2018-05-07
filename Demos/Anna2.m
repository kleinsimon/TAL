tc_init_root;
tc_select_equilibrium(1);

varValues={'w(n)','w(si)'};

elements = {'C','MN','cr','si','ni','mo','v','nb','n','fe'};
rejphases = {'*'};
resphases = {'sigma m23 laves m6c fcc bcc liquid gas'};
db = 'TCFE7';
tc_define_system(db, elements, rejphases, resphases);

tc_set_condition('t',1050 + 273.15);
tc_set_condition('p',101325);
tc_set_condition('n',1);
tc_set_condition('w(c)', 0.00122);
tc_set_condition('w(mn)', 0.00268);
tc_set_condition('w(cr)', 0.1545);
tc_set_condition('w(si)', 0.014);
tc_set_condition('w(ni)', 0.00414);
tc_set_condition('w(mo)', 0.01074);
tc_set_condition('w(v)', 0.0956);
tc_set_condition('w(nb)', 0.0018);
tc_set_condition('w(n)', 0.0101);

fun = sk_func_calc_deltaG;
fun.phase1 = 'fcc';
fun.phase2 = 'bcc';

solvfun = sk_solver_eval_func;
solvfun.zObjects=sk_func_get_main_phase;

mapper=sk_mapper;
mapper.Mode = 0;
mapper.zSolver = solvfun;
mapper.Components = varValues;
mapper.Ranges={...
    [0. 0.04, 10],...  %N
    [0, 0.08, 10],...  %Si
    };

mapper.doMapping;
%mapper.plot();
res=mapper.getResult()

