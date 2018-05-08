%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates the usage of a minimizer as a stepping target to the mapper
% Here, for a range of Cr-Contents the C-Content with the lowest Delta-G is
% searched
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% System Initialization

tcsys = sk_tc_system;
tcsys.Database='TCFE9';
tcsys.Elements='Fe Cr v si n c mo mn ni';
tcsys.RejPhases='*';
tcsys.ResPhases='sigma m23 laves m6c fcc bcc liquid';
tcsys.Init;

%% Conditions

BaseEq=tcsys.GetInitialEquilibrium;
conds = 'T=1323 P=1e8 N=1 W(cr)=0.1542 w(mn)=0.00843 w(c)=0.00009 w(ni)=0.00559 w(mo)=0.00972 w(v)=0.00282 w(n)=0.005864 w(si)=0.00967';
BaseEq.SetConditions(conds);

%% Calculate  Tsol

Eq1=BaseEq.Clone;
Eq1.SetCondition('t', 2000);
Eq1.Calculate;
Eq1.DeleteCondition('t');
Eq1.SetPhaseStatus('liq', 'fixed', 0);

tsol = Eq1.GetValue('t');


%% Calculate  Tliq

Eq2=BaseEq.Clone;
Eq2.SetCondition('t', 300);
Eq2.Calculate;
Eq2.DeleteCondition('t');
Eq2.SetPhaseStatus('liq', 'fixed', 1);

tliq = Eq2.GetValue('t');

%% Print
fprintf('Tsol:\t%g\n', tsol);
fprintf('Tliq:\t%g\n', tliq);
fprintf('Difference:\t%g\n', tliq-tsol);

%% The Same with Properties
disp('With Properties:');
fprintf('Difference:\t%g\n', BaseEq.GetProperty('tliq-tsol'));