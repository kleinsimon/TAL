%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates the calculation of Properties in the high and low alloyed parts of a scheil-simulated eutectic. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Inititialize system
tcsys = sk_tc_system;
tcsys.Database='TCFE8';
tcsys.Elements='Fe Si Mn Cr ti nb';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc liquid';
tcsys.Init;

%% Set Conditions
BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetCondition('w(*)', 0);
BaseEq.SetCondition('t',       1000 + 273.15);
BaseEq.SetCondition('p',       101325);
BaseEq.SetCondition('n',       1);

BaseEq.DisplayEquilibrium;

Eq2 = BaseEq.Clone;
Eq2.Calculate;

%%Properties to calculate: Md30 of the high- and low-alloyed part of the
%%eutectic
prop = sk_func_tc_properties(Eq2, 'abs(md30(low(scheil), t(1050+273.15)) - md30(high(scheil), t(1050+273.15)))');

%% Calculate the extremes in the normed range 
extr=sk_range_extremes;
extr.Components={'w(Si)', 'w(mn)', 'w(cr)', 'w(ti)', 'w(nb)'};
extr.zObjects={prop};
extr.minComp=[0     0   18.5    0.15    0] ./ 100;
extr.maxComp=[1     1   20.5    0.80    1] ./ 100;
extr.Mode=2;

extr.calculate;
extr.ResTable

