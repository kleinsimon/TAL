tc_init_root;

elements = {'FE','C','CR','SI','v','mn','w','ni'};
rejphases = {'*'};
resphases = {'fcc bcc liquid'};
db = 'TCFE7';
tc_define_system(db, elements, rejphases, resphases);

tc_set_condition('t',1000 + 273.15);
tc_set_condition('p',101325);
tc_set_condition('n',1);
tc_set_condition('w(c)', 0.016);
tc_set_condition('w(cr)', 0.008);
tc_set_condition('w(si)', 0.002);
tc_set_condition('w(v)', 0.085);
tc_set_condition('w(mn)', 0.003);
tc_set_condition('w(w)', 0.02);
tc_set_condition('w(ni)', 0.02);

fun = sk_func_get_phase_vars;
fun.Variables_TC={'w','x'};

solvfun = sk_solver_eval_func;
solvfun.zObjects=fun;

mapper=sk_mapper;
mapper.Mode = 3;
mapper.zSolver = solvfun;
mapper.Components = {'t'};
mapper.Ranges={...
    [793.15, 2273.15, 20],...  %C
    };

mapper.doMapping;
mapper.getResult()