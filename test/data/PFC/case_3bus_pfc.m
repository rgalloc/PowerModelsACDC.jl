function mpc = case3_bus()
%
%% MATPOWER Case Format : Version 1
%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm      Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
    1       3     0     0   0  0  1    1.0  0   400   1   1.1 0.9;  % slack gen
    2       2     400   0   0  0  1    1.0  0   400   1   1.1 0.9;  % PV gen + load
    3       1     200   0   0  0  1    1.0  0   400   1   1.1 0.9;  % load only
];

%% branch data
%	fbus	tbus	r			 x			 b				  rateA	   rateB	   rateC	 ratio	  angle	    status	angmin	    angmax
mpc.branch = [

];

%% generator data
%	bus	Pg      Qg	Qmax	Qmin	Vg	mBase       status	Pmax	Pmin	pc1 pc2 qlcmin qlcmax qc2min qc2max ramp_agc ramp_10 ramp_30 ramp_q apf
mpc.gen = [
    1   100  0  500  -500  1.0 100 1  400 100  0 0 0 0 0 0 0 0 0 0 0 0;  % AC generator at bus1
    2   100  0  500  -500  1.0 100 1  400 100  0 0 0 0 0 0 0 0 0 0 0 0;  % AC generator at bus2
    2   100  0  500  -500  1.0 100 1  400 0    0 0 0 0 0 0 0 0 0 0 0 0;  % ENS generator at bus2
    3   100  0  500  -500  1.0 100 1  200 0    0 0 0 0 0 0 0 0 0 0 0 0;  % ENS generator at bus3
];

%% dc grid topology
%colunm_names% dcpoles
mpc.dcpol=2;
% numbers of poles (1=monopolar grid, 2=bipolar grid)
%% bus data
%column_names%   busdc_i grid    Pdc     Vdc     basekVdc    Vdcmax  Vdcmin  Cdc
mpc.busdc = [
    1 1 0 1.0 500 1.10 0.9 0;
    2 1 0 1.0 500 1.10 0.9 0;
    3 1 0 1.0 500 1.10 0.9 0;
    4 1 0 1.0 500 1.1 0.80 0;
    5 1 0 1.0 500 1.1 0.80 0;
];

%% converters
%column_names%   busdc_i busac_i type_dc type_ac P_g   Q_g islcc  Vtar    rtf xtf  transformer tm   bf filter    rc      xc  reactor   basekVac    Vmmax   Vmmin   Imax    status   LossA LossB  LossCrec LossCinv  droop      Pdcset    Vdcset  dVdcset Pacmax Pacmin Qacmax Qacmin
mpc.convdc = [
    1 1 2 1  100   20  0  1     0.01   0.01   1  1 	0.01   0  0.01   0.01  0  500  1.1  0.9  1.1  1  1.103  0.887  2.885 2.885  0.005  100  1.01  0.0  500  -500  50  -50;
    2 2 3 1  100   20  0  1     0.01   0.01   1  1 	0.01   0  0.01   0.01  0  500  1.1  0.9  1.1  1  1.103  0.887  2.885 2.885  0.005  100  1.01  0.0  500  -500  50  -50;
    3 3 3 1  -200  -20 0  1     0.01   0.01   1  1 	0.01   0  0.01   0.01  0  500  1.1  0.9  1.1  1  1.103  0.887  2.885 2.885  0.005  -200 1.01  0.0  500  -500  50  -50;
];

%% branches
%column_names%   fbusdc  tbusdc  r      l        c   rateA   rateB   rateC   status
mpc.branchdc = [
    5 2 0.010757 0 0 1000 1000 1000 1;
    4 3 0.010757 0 0 1000 1000 1000 1;
    2 3 0.010757 0 0 1000 1000 1000 1;
 ];

%% pfc
%column_names% terminal1_bus terminal2_bus terminal3_bus c_voltage_min c_voltage_max duty_cycle_min duty_cycle_max pfc_current_min pfc_current_max pfc_status
mpc.pfc = [
1       4       5       -4     4     0.0     1.0     -1575    1575 1;
];

%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
    2 0 0 3 0.004 25   60;
    2 0 0 3 0.006 25   45;
    2 0 0 3 0     1000  0; % ENS generator at bus2
    2 0 0 3 0     1000  0; % ENS generator at bus3
];
