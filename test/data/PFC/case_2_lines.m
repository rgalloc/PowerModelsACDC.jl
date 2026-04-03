function mpc = case2_lines()
%
%% MATPOWER Case Format : Version 1
%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data
%	bus_i	type	Pd	Qd	Gs	Bs	area	Vm      Va	baseKV	zone	Vmax	Vmin
mpc.bus = [
	1       3       0	0	0   0   1       1.0     0	400     1       1.1     0.9;
    2       1       0	0	0   0   1       1.0     0	400     1       1.1     0.9;
	3       1       50	0	0   0   1       1.0     0	400     1       1.1     0.9;
];

%% branch data
%	fbus	tbus	r			 x			 b				  rateA	   rateB	   rateC	 ratio	  angle	    status	angmin	    angmax
mpc.branch = [
  1  2  0.001  0.01  0  200  200  200  0  0  1  -360  360;
];

%% generator data
%	bus	Pg      Qg	Qmax	Qmin	Vg	mBase       status	Pmax	Pmin	pc1 pc2 qlcmin qlcmax qc2min qc2max ramp_agc ramp_10 ramp_30 ramp_q apf
mpc.gen = [
	1	100  0	100  -100    1.0	100       1       250     0 0 0 0 0 0 0 0 0 0 0 0;
    3	0    0	100  -100    1.0	100       1       50     0 0 0 0 0 0 0 0 0 0 0 0;
];

%% dc grid topology
%colunm_names% dcpoles
mpc.dcpol=2;
% numbers of poles (1=monopolar grid, 2=bipolar grid)
%% bus data
%column_names%   busdc_i grid    Pdc     Vdc     basekVdc    Vdcmax  Vdcmin  Cdc
mpc.busdc = [
    1     1       0       1       500         1.1     0.9     0;
    2     1       0       1       500         1.1     0.9     0;
];

%% converters
%column_names%   busdc_i busac_i type_dc type_ac P_g   Q_g islcc  Vtar    rtf xtf  transformer tm   bf filter    rc      xc  reactor   basekVac    Vmmax   Vmmin   Imax    status   LossA LossB  LossCrec LossCinv  droop      Pdcset    Vdcset  dVdcset Pacmax Pacmin Qacmax Qacmin
mpc.convdc = [
    %2  1  1  1   60   40  0  1   0.01 0.01 1 1 0.01 1 0.01 0.01 1 500 1.1 0.9 1.1 1 1.103 0.887 2.885 2.885 0.0050   58.6274  1.0079 0 100 -100 50 -50;
    %3  2  2  1  -60  -40  0  1   0.01 0.01 1 1 0.01 1 0.01 0.01 1 500 1.1 0.9 1.1 1 1.103 0.887 2.885 2.885 0.0050  -58.6274  1.0079 0 100 -100 50 -50;
     1  2  1  1   60   20  0  1.01  0.01  0.01  1  1  0.01  1  0.01  0.01  1  400  1.1  0.9  1.1  1  1.0  0.01  2.0  2.0  0.005   60  1.01  0.0  100  -100  50  -50;
     2  3  2  1  -60  -20  0  1.00  0.01  0.01  1  1  0.01  1  0.01  0.01  1  400  1.1  0.9  1.1  1  1.0  0.01  2.0  2.0  0.005  -60  1.00  0.0  100  -100  50  -50;
];

%% branches
%column_names%   fbusdc  tbusdc  r      l        c   rateA   rateB   rateC   status
mpc.branchdc = [
    1       2       0.052   0   0    250     100     100     1;
    1       2       0.012   0   0    250     100     100     1;
 ];

%% generator cost data
%	1	startup	shutdown	n	x1	y1	...	xn	yn
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
	2	0	0	3	0  1	0;
    2	0	0	3	0  100	0;
];
