%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Demonstrates basic Work with equilibria by the calculation of a gibbs
%enthalpy difference
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% System Initialization

echo on;

tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='Fe Cr v si n c mo mn ni';
tcsys.RejPhases='*';
tcsys.ResPhases='sigma m23 laves m6c fcc bcc liquid gas';
tcsys.Init;

%% Conditions

BaseEq=tcsys.GetInitialEquilibrium;
conds = 'T=1323 P=1e8 N=1 W(cr)=0.1542 w(mn)=0.00843 w(c)=0.00009 w(ni)=0.00559 w(mo)=0.00972 w(v)=0.00282 w(n)=0.005864 w(si)=0.00967';
BaseEq.SetConditions(conds);

Eq=BaseEq.Clone;
Eq.Calculate;

%% Calculation of Delta G between fcc and bcc, semi-automatic way

%Get Name of main Phase, restricted to fcc and bcc (optional)
matrix = Eq.GetMainPhase('vpv', {'fcc', 'bcc'});

%Get Composition of the matrix
LocalEq = Eq.GetLocalConditions(matrix);

%Create two empty equilibria
Eq1 = tcsys.GetNewEquilibrium;
Eq2 = tcsys.GetNewEquilibrium;

%Set their composition to the local composition of the matrix
Eq1.SetConditions(LocalEq);
Eq2.SetConditions(LocalEq);

%Allow only one Phase to be stable
Eq1.SetMinimization(0);
Eq1.SetPhaseStatus('*', 'SUSPENDED', 0);
Eq1.SetPhaseStatus('fcc', 'ENTERED', 0);

%Allow only the other Phase to be stable
Eq2.SetMinimization(0);
Eq2.SetPhaseStatus('*', 'SUSPENDED', 0);
Eq2.SetPhaseStatus('bcc', 'ENTERED', 0);

%get Gibbs enthalpy of both phases with the same composition
gm1 = Eq1.GetValue('gm(fcc)');
gm2 = Eq2.GetValue('gm(bcc)');

res = gm1-gm2;
disp(res);

%% The same using the static "get" mehod of sk_func_tc_properties

sk_func_tc_properties.get(Eq, 'dg("fcc","bcc")')

%% The same using the convenient Method of sk_tc_equilibrium (which does the same as before)

Eq.GetProperty('dg("fcc","bcc")')