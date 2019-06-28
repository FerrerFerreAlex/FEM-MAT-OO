filename='CantileverSquare';
ptype = 'MACRO';
initial_case = 'full';
%cost = {'compliance'};
cost = {'stressNorm'};
weights = 1;
constraint = {'volumeConstraint'};
filterType = 'P1';

optimizer = 'DualNestedInPrimal';
optimizerUnconstrained = 'PROJECTED GRADIENT';
designVariable = 'MicroParams';
homegenizedVariablesComputer = 'ByVademecum';
vademecumFileName = 'Rectangle';%'SmoothRectangle';
%vademecumFileName = 'SmoothRectangle';

nsteps = 4;
maxiter = 400;

Vfrac_initial = 0.3;
Vfrac_final = 0.3;

optimality_initial = 1e-8;
optimality_final = 1e-8;
constr_initial = 1e-3;
constr_final = 1e-3;

%printing = false;
printing = true;
monitoring = true;
monitoring_interval = 1;
plotting = true;

ub = 0.989;
lb = 0.011;
kfrac = 2;

pNorm_initial = 2;
pNorm_final = 16;

printMode = 'Shapes';


