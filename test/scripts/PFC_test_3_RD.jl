using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 5) # Changed tolerance to 1e-8 from 1e-6
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

## Code to test PFC with Redispatch OPF
data_no_pfc = _PM.parse_file("./test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data_no_pfc_cong_67bus)