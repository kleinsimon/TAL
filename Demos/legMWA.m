tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='cr fe c mn al ti cu mo si ni nb';
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
%initEq.SetWpc('b', 0.002);

initEq.Calculate;

initEq.GetProperty({'t_c(ac1)','t_c(ac3)','t_c(ms_barbier(ac3+50))'});

elm = {'C'	'Mn'	'Si'	'Cr'	'Mo'	'Ti'	'Nb'	'B'};

cnt = [
0.20	6.00	0.22	0.30	0.26	0.02	0.02	0.0029
0.20	7.50	0.12	0.25	0.25	0.02	0.03	0.0016
0.20	9.50	0.29	0.25	0.25	0.02	0.04	0.0023
0.25	3.00	1.50	0.27	0.26	0.02	0.02	0.0035
];

r=cell(size(cnt,1),1);

for i=1:size(cnt,1)
    S1=initEq.Clone;
    S1.SetCondition('w(*)',0);
    S1.SetConditionsForComponents(elm, cnt(i,:)/100, 'w');
    r{i}=S1.GetProperty({'t_c(ac1)','t_c(ac3)','t_c(ms_barbier(ac3+50))'});
end
