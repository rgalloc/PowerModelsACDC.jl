function mpc = prosecco_test()
% PROSECCO test case with offshore HVDC meshed grid
% June 2026

mpc.version  = '2';
mpc.baseMVA  = 100.0;

%% bus data
% bus_i type   Pd    Qd   Gs Bs area Vm    Va  baseKV zone Vmax Vmin
mpc.bus = [
    1     3     1500  0    0  0      1  1.00  0     400    1   1.1 0.90;  % Onshore 1, 400 kV ; load 1500 MW
    2     3     1200  0    0  0      1  1.00  0     400    1   1.1 0.90;  % Onshore 2, 400 kV ; load 1200 MW
    3     3     1400  0    0  0      1  1.00  0     400    1   1.1 0.90;  % Onshore 3, 400 kV ; load 1400 MW
    4     3     0     0    0  0      1  1.00  0     220    1   1.1 0.90;  % Offshore WF1, 220 kV
    5     3     0     0    0  0      1  1.00  0     220    1   1.1 0.90;  % Offshore WF2, 220 kV
];

%% generator data
% bus  Pg Qg  Qmax Qmin  Vg    mBase status Pmax   Pmin
mpc.gen = [
    1     0  0   5000 -5000  1.00  100    1   5000   0;   % External grid A
    2     0  0   5000 -5000  1.00  100    1   5000   0;   % External grid B
    3     0  0   5000 -5000  1.00  100    1   5000   0;   % External grid C
    4     0  0   1000 -1000  1.00  100    1   2000   0;   % WF1
    5     0  0   1000 -1000  1.00  100    1   2000   0;   % WF2
];

%% branch data
% fbus tbus   r       x       b   rateA rateB rateC ratio angle status angmin angmax
mpc.branch = [
%    4 5    0.0005  0.0015  0   2000  2000  2000  0     0     1      -60    60; % WF1-WF2
];


% number of poles (1=monopolar, 2=bipolar)
mpc.dcpol = 2;

%% dc bus data
%column_names%  busdc_i    grid    Pdc     Vdc   basekVdc    Vdcmax   Vdcmin   Cdc  area
mpc.busdc = [
    1      1     0    1       525     1.1    0.9    0   1;
    2      1     0    1       525     1.1    0.9    0   1;
    3      1     0    1       525     1.1    0.9    0   1;
    4      1     0    1       525     1.1    0.9    0   1;
    5      1     0    1       525     1.1    0.9    0   1;
    6      1     0    1       525     1.1    0.9    0   1;
    7      1     0    1       525     1.1    0.9    0   1;
    8      1     0    1       525     1.1    0.9    0   1;
];

%% dc branch data
%column_names%  fbusdc  tbusdc  r  l   c   rateA   rateB   rateC   status
mpc.branchdc = [
    1      6     0.00025   0  0    2000  2000  2000   1; % 12 km cable
    2      7     0.00025   0  0    2000  2000  2000   1; % 12 km cable
    3      8     0.00025   0  0    2000  2000  2000   1; % 12 km cable
    6      4     0.000750  0  0    2000  2000  2000   1; % 300 km cable
    6      7     0.000375  0  0    2000  2000  2000   1; % 150 km cable
    7      8     0.000375  0  0    2000  2000  2000   1; % 150 km cable
    5      8     0.000500  0  0    2000  2000  2000   1; % 200 km cable
    4      5     0.000500  0  0    2000  2000  2000   1; % 200 km cable
    5      6     0.001000  0  0    2000  2000  2000   1; % 400 km cable
%%%%%%%%%%
%    1      2     0.000375   0  0    2000  2000  2000   1; % 150 km cable
%    1      4     0.000750   0  0    2000  2000  2000   1; % 300 km cable
%    1      5     0.001000   0  0    2000  2000  2000   1; % 400 km cable
%    2      3     0.000375   0  0    2000  2000  2000   1; % 150 km cable
%    3      5     0.000500   0  0    2000  2000  2000   1; % 200 km cable
%    4      5     0.000500   0  0    2000  2000  2000   1; % 200 km cable
];

%% converters
%column_names%  busdc_i busac_i   type_dc   type_ac   P_g   Q_g   islcc      Vtar   rtf 	xtf     transformer  tm      bf   filter   rc    xc     reactor   basekVac      Vmmax   Vmmin    Imax   status   LossA  LossB  LossCrec LossCinv    droop    Pdcset      Vdcset  dVdcset    Pacmax  Pacmin   Qacmax   Qacmin
mpc.convdc = [
                    1      1          2          1     0     0       0        1.00  0.0002  0.0075       1        1      0.01   0    0.00012  0.0037    1        400        1.10    0.90     1.25     1      2.2    2.42   0.0028   0.0028       0.0050     0           1.00    0         2000   -2000      1000    -1000;
                    2      2          3          1     0     0       0        1.00  0.0002  0.0075       1        1      0.01   0    0.00012  0.0037    1        400        1.10    0.90     1.25     1      2.2    2.42   0.0028   0.0028       0.0050     0           1.00    0         2000   -2000      1000    -1000;
                    3      3          3          1     0     0       0        1.00  0.0002  0.0075       1        1      0.01   0    0.00012  0.0037    1        400        1.10    0.90     1.25     1      2.2    2.42   0.0028   0.0028       0.0050     0           1.00    0         2000   -2000      1000    -1000;
                    4      4          3          1     0     0       0        1.00  0.0002  0.0075       1        1      0.01   0    0.00012  0.0037    1        220        1.10    0.90     1.25     1      2.2    1.33   0.0008   0.0008       0.0050     0           1.00    0         2000   -2000      1000    -1000;
                    5      5          3          1     0     0       0        1.00  0.0002  0.0075       1        1      0.01   0    0.00012  0.0037    1        220        1.10    0.90     1.25     1      2.2    1.33   0.0008   0.0008       0.0050     0           1.00    0         2000   -2000      1000    -1000;
];

%% generator cost data
% 2  startup shutdown n   c2     c1   c0
mpc.gencost = [
    2     0       0      3  0   10    0;   % External grid A
    2     0       0      3  0   10    0;   % External grid B
    2     0       0      3  0   10    0;   % External grid C
    2     0       0      3  0  0.0    0;   % WF1
    2     0       0      3  0  0.0    0;   % WF2
];

%column_names% 				prob    branch_id1 	branch_id2  branch_id3  dcbranch_id1  dcbranch_id2  dcbranch_id3  gen_id1  gen_id2  gen_id3  dcconv_id1  dcconv_id2  dcconv_id3
mpc.contingencies = [
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0;
                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0  		  0 		  0; % row 11; converter 10
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0; % row 12; branch 1
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
%                            0.005       0 		    0 			 0   		  0 		     0 			   0   		  0 	  0 	   0   		 0 			  0 		  0;
];