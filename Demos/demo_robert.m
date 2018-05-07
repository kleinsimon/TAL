tcsys = sk_tc_system;
tcsys.Database='TCFE7';
tcsys.Elements='Fe C Si Mn Cr Ni';
tcsys.RejPhases='*';
tcsys.ResPhases='fcc bcc liquid hcp';
tcsys.Init;

BaseEq=tcsys.GetInitialEquilibrium;
BaseEq.SetCondition('t',       1000 + 273.15);
BaseEq.SetCondition('p',       101325);
BaseEq.SetCondition('n',       1);
BaseEq.SetWpc('c',  0.03);
BaseEq.SetWpc('si', 1.00);
BaseEq.SetWpc('mn', 2.00);
BaseEq.SetWpc('Cr', 19.5);
BaseEq.SetWpc('ni', 10.5);

BaseEq.DisplayEquilibrium;

Eq2 = BaseEq.Clone;
scheil=sk_tc_scheil(Eq2);
%scheil.calculate;
%scheil.drawScheil;

Eq1=BaseEq.Clone;

f1=sk_func_calc_robert(Eq1);
%f1.StartT=2200;


solver=sk_solver_eval_func;
solver.zObjects=f1;

mapper=sk_mapper;
mapper.zSolver=solver;
mapper.Components={'w(Ni)','w(CR)'};
mapper.Mode=0;
mapper.Ranges={ ...
  [0.175 0.195 10], ...
  [0.08 0.105 10], ...
};

mapper.doMapping;

%t=mapper.getResult
%sk_tool_plot3d_scatter(t,'FaceColor','interp', 'EdgeColor','none')
