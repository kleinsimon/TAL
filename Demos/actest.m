tc_init_root;

varValues={'w(C)','w(MN)'};

elements = {'CR','FE','C','MN','AL','TI','B','CU','MO','SI','NI','AL'};
rejphases = {'*'};
resphases = {'fcc bcc m23 cem'};
db = 'TCFE7';
tc_define_system(db, elements, rejphases, resphases);

tc_set_condition('t',880 + 273.15);
tc_set_condition('p',101325);
tc_set_condition('n',1);
tc_set_condition('w(c)', 0.0021);
tc_set_condition('w(mn)', 0.0125);
tc_set_condition('w(cr)', 0.012);
tc_set_condition('w(al)', 0.0003);
tc_set_condition('w(ti)', 0.0003);
tc_set_condition('w(b)', 0.00003);
tc_set_condition('w(si)', 0);
tc_set_condition('w(ni)', 0);
tc_set_condition('w(cu)', 0);
tc_set_condition('w(mo)', 0);

startvals=tc_calc_ac1_ac3_ms({'w(c)'},0.0021);

solvfun = tc_func_eval_func;
solvfun.zFunction=@tc_calc_ac3;
solvfun.output_names={'AC3_K'};

mapper=mappingHelper;
mapper.zSolver = solvfun;
mapper.Components = varValues;
mapper.Ranges={...
    [0.001, 0.005, 6],...  %C
    [0, 0.05, 6]...  %Si
    };

mapper.doMapping;
mapper.getResult()