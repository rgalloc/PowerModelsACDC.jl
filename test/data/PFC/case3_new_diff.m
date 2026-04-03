%% MATPOWER Case Format : Version 1
%%-----  Power Flow Data  -----%%
%% system MVA base
mpc.baseMVA = 100;

%% bus data (AC)
% bus_i type  Pd  Qd  Gs Bs area Vm    Va baseKV zone Vmax  Vmin
mpc.bus = [
    1     3    0   0   0  0   1    1.06 0   345    1    1.15  0.90;   % relax Vmax from 1.10 -> 1.15
    2     2    400 0   0  0   1    1.00 0   345    1    1.10  0.90;
    3     1    200 0   0  0   1    1.00 0   345    1    1.10  0.90;
];

%% generator data (AC)
% bus Pg  Qg Qmax Qmin Vg  mBase status Pmax Pmin ...
mpc.gen = [
    1   100  0  500 -500 1.06 100 1  400 100  0 0 0 0 0 0 0 0 0 0 0 0;  % Gen1
    2   100  0  500 -500 1.00 100 1  400 100  0 0 0 0 0 0 0 0 0 0 0 0;  % Gen2
    2   0    0  500 -500 1.00 100 1  400 0    0 0 0 0 0 0 0 0 0 0 0 0;  % ENS @ bus2 (keep if you still want ENS option)
    3   0    0  500 -500 1.00 100 1  200 0    0 0 0 0 0 0 0 0 0 0 0 0;  % ENS @ bus3
];

%% AC branches (optional — to make AC share like DC; you can omit)
% f t   r     x     b   rateA rateB rateC ratio angle status angmin angmax
mpc.branch = [
    % 1 2  0.01  0.05  0   1000  1000  1000  0     0     1     -360   360
];

%% DC buses
% busdc_i grid Pdc Vdc basekVdc Vdcmax Vdcmin Cdc
mpc.busdc = [
    1       1    0   1.0  345      1.10   0.90   0;
    2       1    0   1.0  345      1.10   0.90   0;
    3       1    0   1.0  345      1.10   0.90   0;
];

%% Converters (AC/DC) — set losses to zero; wide P/Q limits; neutral PF setpoints
% busdc_i busac_i type_dc type_ac P_g Q_g islcc Vtar rtf xtf transformer tm bf filter rc xc reactor basekVac Vmmax Vmmin Imax status LossA LossB LossCrec LossCinv droop Pdcset Vdcset dVdcset Pacmax Pacmin Qacmax Qacmin
mpc.convdc = [
    1   1   1   1   0    0    0  1    0.01 0.01 1 1 0.01 1 0.01 0.01 1 345 1.10 0.90  1.10  1  0     0     0       0       0      0      1.0000 0   500  -500  100   -100;  % Conv1 (lossless)
    2   2   2   1   0    0    0  1    0.01 0.01 1 1 0.01 1 0.01 0.01 1 345 1.10 0.90  1.10  1  0     0     0       0       0      0      1.0000 0   500  -500  100   -100;  % Conv2 (lossless)
    3   3   1   1   0    0    0  1    0.01 0.01 1 1 0.01 1 0.01 0.01 1 345 1.10 0.90  1.10  1  0     0     0       0       0      0      1.0000 0   500  -500  100   -100;  % Conv3 (lossless)
];

%% DC branches
% fbusdc tbusdc r     l c rateA rateB rateC status
mpc.branchdc = [
    1      2      0.052 0 0 1000 1000 1000 1;
    2      3      0.052 0 0 1000 1000 1000 1;
    1      3      0.073 0 0 1000 1000 1000 1;
];

%% Generator cost (unchanged)
% 2 startup shutdown n c2 c1 c0
mpc.gencost = [
    2 0 0 3 0.004 25 60;   % Gen1
    2 0 0 3 0.006 25 45;   % Gen2
    2 0 0 3 0     1000 0;  % ENS @ bus2
    2 0 0 3 0     1000 0;  % ENS @ bus3
];
