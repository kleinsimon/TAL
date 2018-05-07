tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='Fe c cr si v mn';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc cem liquid';
tcsys.Init;

BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetCondition('t',       1500 + 273.15);
BaseEq.SetCondition('p',       101325);
BaseEq.SetCondition('n',       1);
BaseEq.SetCondition('w(c)',    0.016);
BaseEq.SetCondition('w(cr)',   0.008);
BaseEq.SetCondition('w(si)',   0.002);
BaseEq.SetCondition('w(v)',    0.085);
BaseEq.SetCondition('w(mn)',   0.003);

Eq1 = BaseEq.Clone;
scheil=sk_tc_scheil(Eq1);
scheil.calculate;
Result=scheil.getSegregationFactors;
Result(:,'FE')=[];
scheil.drawScheil;

Eq1.DisplayEquilibrium;

comp=Result.Properties.VariableNames;
mins=table2array(Result(1,:));
maxs=table2array(Result(2,:));

% f1=sk_func_calc_tsol(Eq2);
% f1.StartT = 1000;
% f2=sk_func_calc_tliq(Eq2);
% f2.StartT = 200;
% f3=sk_func_calc_ms(Eq2);
% f3.SetTemp=900+273.15;
% f3.Models=3;
tsol = sk_func_tc_properties(Eq1, 'tsol(3000)');
tliq = sk_func_tc_properties(Eq1, 'tliq');
ms = sk_func_tc_properties(Eq1, 'ms_barbier(ac3+50)');

extr=sk_range_extremes;
extr.Components=cellfun(@(c)(sprintf('w(%s)',c)),comp,'UniformOutput',0);
extr.zObjects={tsol, tliq, ms};
extr.minComp=mins;
extr.maxComp=maxs;
extr.Mode=2;

%extr.calculate;
extr.ResTable
