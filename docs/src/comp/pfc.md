# Power Flow Controller (DC grid)

## Parameters

Set of parameters used to model power flow controlling devices as defined in the input data

| name | symb. | unit | type | default | definition |
|------|-------|------|------|---------|------------|
| index | $pfc$ | -   | Int  | -       | unique index of the PFC device |
| terminal1_bus | $t1$ | -   | Int  | -       | unique index of the bus root terminal |
| terminal2_bus | $t2$ | -   | Int  | -       | unique index of the bus output 1 terminal |
| terminal3_bus | $t3$ | -   | Int  | -       | unique index of the bus output 2 terminal |
| terminal1_bus | $t1$ | -   | Int  | -       | unique index of the bus input terminal |
| c_voltage_max | $c_max$ | kV   | Real  | -       | PFC internal capacitor maximum voltage |
| c_voltage_min | $c_min$ | kV   | Real  | -       | PFC internal capacitor minimum voltage |

## Variables

Optimization variables representing the PFC behaviour.

| name | symb. | unit | formulation | definition |
|------|-------|------|-------------|------------|
| duty cycle | $d$ | -   | IVR  | Duty cycle of the PFC |

