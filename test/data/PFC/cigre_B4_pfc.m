%
%   AC/DC grid OPF test case based on:
%   Cigre B4 DC grid benchmark model
%   
%  
%
%

function mpc = cigreb4()
mpc.version = '2';
mpc.baseMVA = 100.0;

%% bus data
%	bus_i	type		Pd		Qd		  Gs	 Bs	   area		Vm	   Va		   baseKV	zone	  Vmax			 Vmin
mpc.bus = [
    1   3   1000	0	0   0   1       1.06	0	400     1       1.1     0.9;
    2   1   1000	0	0   0   1       1   	0	400     1       1.1     0.9;
    3   1   0	    0	0   0   1       1   	0	220     1       1.1     0.9;
    4   1   0	    0	0   0   1       1   	0	220     1       1.1     0.9;
];

%% generator data
%	bus	   Pg	Qg  Qmax  Qmin	  Vg	mBase	status	   Pmax	  Pmin	  Pc1	 Pc2   Qc1min	Qc1max    Qc2min	Qc2max	ramp_agc	    ramp_10	      ramp_30	  ramp_q	   apf         alpha
mpc.gen = [
    1	   0    0	500   -500    1.06	 100       1       2000     0      0 0 0 0 0 0 0 0 0 0 0;
    2	   40   0	300   -300    1      100       1       2000     0      0 0 0 0 0 0 0 0 0 0 0;
    3      40   0	300   -300    1      100       1       2000     0      0 0 0 0 0 0 0 0 0 0 0;
    4      40   0	300   -300    1      100       1       2000     0      0 0 0 0 0 0 0 0 0 0 0;
];

%% branch data
%	fbus	tbus	r			 x			 b				  rateA	   rateB	   rateC	 ratio	  angle	    status	angmin	    angmax
mpc.branch = [
];

%% dc grid topology
%colunm_names% dcpoles
mpc.dcpol=2;
% numbers of poles (1=monopolar grid, 2=bipolar grid)
%% bus data
%column_names%  busdc_i    grid    Pdc     Vdc   basekVdc    Vdcmax   Vdcmin   Cdc  area
mpc.busdc = [
    1   1       0       1       525         1.1     0.9     0   1;
    2   1       0       1       525         1.1     0.9     0   1;
    3   1       0       1       525         1.1     0.9     0   1;
    4   1       0       1       525         1.1     0.9     0   1;
    5   1       0       1       525         1.1     0.9     0   1;
    6   1       0       1       525         1.1     0.9     0   1;
];

%% converters
%column_names%  busdc_i busac_i   type_dc   type_ac   P_g   Q_g   islcc      Vtar   rtf 	xtf     transformer  tm      bf   filter   rc    xc     reactor   basekVac      Vmmax   Vmmin    Imax   status   LossA  LossB  LossCrec LossCinv    droop    Pdcset      Vdcset  dVdcset    Pacmax  Pacmin   Qacmax         Qacmin
mpc.convdc = [
    1   1   2   1   -577.5  0   0   1   0.01    0.01    1   1   0.01    0   0.01    0.01    0   525 1.1     0.9     1.1     1        1.103 0.887  2.885    2.885      0.0050    -465.9871   0.9999		0 		 2000  	-2000  	   1000 		-1000;
    2   2   2   1   -577.5  0   0   1   0.01    0.01    1   1   0.01    0   0.01    0.01    0   525 1.1     0.9     1.1     1        1.103 0.887  2.885    2.885      0.0050    -465.9871   0.9999		0 		 2000  	-2000  	   1000 		-1000;
    5   3   2   1   -577.5  0   0   1   0.01    0.01    1   1   0.01    0   0.01    0.01    0   525 1.1     0.9     1.1     1        1.103 0.887  2.885    2.885      0.0050    -465.9871   0.9999		0 		 2000  	-2000  	   1000 		-1000;
    6   4   2   1   -577.5  0   0   1   0.01    0.01    1   1   0.01    0   0.01    0.01    0   525 1.1     0.9     1.1     1        1.103 0.887  2.885    2.885      0.0050    -465.9871   0.9999		0 		 2000  	-2000  	   1000 		-1000;
];

%% dc branches
%column_names%  fbusdc  tbusdc  r  l   c   rateA   rateB   rateC   status
mpc.branchdc = [
    1   3   0.0689   0    0   2500   2500   2500   1;
    2   4   0.0689   0    0   2500   2500   2500   1;
    3   5   2.0667   0    0   2500   2500   2500   1;
    5   6   1.3778   0    0   2500   2500   2500   1;
    4   6   1.3778   0    0   2500   2500   2500   1;
    3   4   2.0667   0    0   2500   2500   2500   1;
    3   6   2.7556   0    0   2500   2500   2500   1;
];

%% generator cost data
%	2	startup	shutdown	n	c(n-1)	...	c0
mpc.gencost = [
2	0	0	3	0  1	0;
2	0	0	3   0  2	0;
2	0	0	3   0  0.5	0;
2	0	0	3   0  0.5	0;
];

%% pfc
%column_names% terminal1_bus terminal2_bus terminal3_bus c_voltage_min c_voltage_max duty_cycle_min duty_cycle_max pfc_current_min pfc_current_max pfc_status
mpc.pfc = [
    1       10       11       -4     4    0.0     1.0     -1575    1575 1;
];
