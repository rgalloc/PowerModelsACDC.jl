###################################################################
#####   Code to test new functions to add superconductor links #####
###################################################################

using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using Gurobi
using Ipopt

# Include new Functions
include("../../src/core/process_supercoductor_links.jl")

# Add system data
#data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
data = _PM.parse_file("test/data/superconductivity/case5_acdc_sc.m") # New test case
data_original = deepcopy(data)

nl_solver = Ipopt.Optimizer
#nl_solver = Gurobi.Optimizer

# Define superconductor links
sc_links = ["1"] # Vector to state whihc dc branches are superconductor links
#sc_data = Dict{String,Any}() # Dict to save sc branches data

#sc_data = add_sc_links!(data,sc_links)
#sc_data = add_sc_links_2!(data,sc_links)
sc_data = add_sc_links_3!(data,sc_links)

process_superconductor_links2!(data)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

_PMACDC.process_additional_data!(data)
_PMACDC.process_additional_data!(data_original)
result = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)
result_original = _PMACDC.run_acdcopf(data_original,ACPPowerModel,nl_solver;setting = s)
#result_2 = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)

print("-------------------------------------------------------\n")
print("                  Optimization Results                 \n")
print("-------------------------------------------------------\n")
print("\n Case 1: No SC Branches : ",result_original["objective"], "\n")
print("\n Case 2: 1  SC Branch   : ",result["objective"], "\n")

