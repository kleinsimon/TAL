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

scheil.calculate;
Result=scheil.getSegregationFactors;
Result(:,'FE')=[];
scheil.drawScheil;

comp=Result.Properties.VariableNames;
mins=table2array(Result(1,:));
maxs=table2array(Result(2,:));

funliq=sk_func_calc_tliq;
funsol=sk_func_calc_tsol;

extr=sk_range_extremes;
extr.Components=cellfun(@(c)(sprintf('w(%s)',c)),comp,'UniformOutput',0);
extr.zObjects={funliq, funsol, sk_func_calc_ms};
extr.minComp=mins;
extr.maxComp=maxs;
extr.Mode=2;

extr.calculate;
extr.ResTable
