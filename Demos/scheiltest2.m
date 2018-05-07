tc_init_root;

elements = {'FE','C','CR','SI','v','mn','w','ni'};
rejphases = {'*'};
resphases = {'fcc bcc cem liquid'};
db = 'TCFE7';
tc_define_system(db, elements, rejphases, resphases);

tc_set_condition('t',       1500 + 273.15);
tc_set_condition('p',       101325);
tc_set_condition('n',       1);
tc_set_condition('w(c)',    0.016);
tc_set_condition('w(cr)',   0.008);
tc_set_condition('w(si)',   0.002);
tc_set_condition('w(v)',    0.085);
tc_set_condition('w(mn)',   0.003);
tc_set_condition('w(w)',    0.02);
tc_set_condition('w(ni)',   0.02);

tc_compute_equilibrium;

scheil=sk_scheil;
scheil.Step=1;
scheil.StartT=1400 + 273.15;
%scheil.StartT=sk_func_calc_tliq.get(1000) + 10;

scheil.doCalculation;
Result=scheil.Results;
scheil.drawScheil;