function mpc = cigreb4_final()
% Feasible hybrid AC/DC test case with separated onshore gens & loads
% - Onshore AC: 400 kV (buses 1, 2 as generator buses; buses 10, 11 as load buses)
% - Offshore AC: 220 kV (buses 3, 4 as offshore WF collector buses)
% - HVDC grid: 525 kV (busdc 1..6) with SAME topology & parameters as original
% - VSC-MMC converters connect offshore AC islands and onshore AC to the MTDC mesh
% - Costs favor wind; OPF should dispatch WFs and route power via HVDC
%
% Notes:
% * This file keeps your DC buses and DC branch parameters IDENTICAL to the original case.
% * AC side adds a 400 kV tie 1-2 and feeders 1-10 and 2-11 to separate gens & loads.
% * By default, bus 1 is REF (type 3); bus 2 is PV (type 2). If you enable multi-slack in
%   PowerModelsACDC and want bus 2 also as REF, set mpc.bus(2,2) = 3 in your script.

mpc.version  = '2';
mpc.baseMVA  = 100.0;

%%========================
%% AC BUS DATA
%%========================
% bus_i type   Pd    Qd   Gs Bs area Vm    Va  baseKV zone Vmax Vmin
mpc.bus = [
    1     1     1000  0    0  0      1  1.00  0     400    1   1.1 0.90;  % Onshore Gen A (REF), 400 kV
    2     1     1000  0    0  0      1  1.00  0     400    1   1.1 0.90;  % Onshore Gen B (PV),  400 kV
    10    3     0     0    0  0      1  1.03  0     400    1   1.1 0.90;  % Onshore Load A, 400 kV
    20    2     0     0    0  0      1  1.02  0     400    1   1.1 0.90;  % Onshore Load B, 400 kV
    3     2     0     0    0  0.02   1  1.00  0     220    1   1.1 0.90;  % Offshore WF1 AC island, 220 kV
    4     2     0     0    0  0.02   1  1.00  0     220    1   1.1 0.90;  % Offshore WF2 AC island, 220 kV
];

%%========================
%% AC GENERATORS
%%========================
% bus  Pg Qg  Qmax Qmin  Vg    mBase status Pmax   Pmin
mpc.gen = [
    10    0  0   500 -500  1.03  100    1   3000    0;   % External grid A
    20    0  0   500 -500  1.02  100    1   3000    0;   % External grid B
    3     0  0   50  -50   1.00  100    1   2000    0;   % WF1 (offshore AC island)
    4     0  0   50  -50   1.00  100    1   2000    0;   % WF2 (offshore AC island)
];

%%========================
%% AC BRANCHES
%%========================
% fbus tbus   r       x       b   rateA rateB rateC ratio angle status angmin angmax
mpc.branch = [
    1    2   0.0020  0.0200  0.0  3000  3000  3000   0     0     1     -360   360;  % 400 kV intertie between onshore hubs
    10   1   0.0020  0.0200  0.0  3000  3000  3000   0     0     1     -360   360;  % Gen A feeder to Load A
    20   2   0.0020  0.0200  0.0  3000  3000  3000   0     0     1     -360   360;  % Gen B feeder to Load B
];
% No AC lines to buses 3 & 4 (offshore AC remains islanded, connected only via VSCs)

%%========================
%% DC GRID
%%========================
% number of poles (1=monopolar, 2=bipolar)
mpc.dcpol = 2;

%% bus data
%column_names%  busdc_i    grid    Pdc     Vdc   basekVdc    Vdcmax   Vdcmin   Cdc  area
mpc.busdc = [
    1      1     0    1       525     1.1    0.9    0   1;
    2      1     0    1       525     1.1    0.9    0   1;
    3      1     0    1       525     1.1    0.9    0   1;
    4      1     0    1       525     1.1    0.9    0   1;
    5      1     0    1       525     1.1    0.9    0   1;
    6      1     0    1       525     1.1    0.9    0   1;
];

%% dc branches
%column_names%  fbusdc  tbusdc  r  l   c   rateA   rateB   rateC   status
mpc.branchdc = [
    1      3     0.00025   0  0    2000  2000  2000   1;
    2      4     0.00025   0  0    2000  2000  2000   1;
    3      5     0.00750   0  0    2000  2000  2000   1;
    5      6     0.00500   0  0    2000  2000  2000   1;
    4      6     0.00500   0  0    2000  2000  2000   1;
    3      4     0.00750   0  0    2000  2000  2000   1;
    3      6     0.00999   0  0    2000  2000  2000   1;
];


%% converters
%column_names%  busdc_i busac_i   type_dc   type_ac   P_g   Q_g   islcc      Vtar   rtf 	xtf     transformer  tm      bf   filter   rc    xc     reactor   basekVac      Vmmax   Vmmin    Imax   status   LossA  LossB  LossCrec LossCinv    droop    Pdcset      Vdcset  dVdcset    Pacmax  Pacmin   Qacmax   Qacmin
mpc.convdc = [
    1   1   2   1     0    0   0    1.02  0.010 0.050  1    1   0.01  1     0.010 0.050  0     400      1.10  0.90  1.20  1   0.010 0.010 0.002  0.002  0      0   1.00   0     2000  -2000  1000  -1000;
    2   2   3   1     0    0   0    1.02  0.010 0.050  1    1   0.01  1     0.010 0.050  0     400      1.10  0.90  1.20  1   0.010 0.010 0.002  0.002  0.010  0   1.00   0     2000  -2000  1000  -1000;
    5   3   1   1     0    0   0    0.98  0.010 0.100  1    1   0.01  1     0.010 0.050  0     220      1.10  0.90  1.20  1   0.010 0.010 0.002  0.002  0      0   1.00   0     2000  -2000  1000  -1000;
    6   4   1   1     0    0   0    0.98  0.010 0.100  1    1   0.01  1     0.010 0.050  0     220      1.10  0.90  1.20  1   0.010 0.010 0.002  0.002  0      0   1.00   0     2000  -2000  1000  -1000;
];

%%========================
%% GENERATOR COSTS (WFs cheapest → OPF prefers wind)
%%========================
% 2  startup shutdown n   c2     c1   c0
mpc.gencost = [
    2     0       0      3  0.002   80    0;   % Ext-grid A (onshore)
    2     0       0      3  0.002   82    0;   % Ext-grid B (onshore)
    2     0       0      3  0.002   40    0;   % WF1 (offshore)
    2     0       0      3  0.002   40    0;   % WF2 (offshore)
];