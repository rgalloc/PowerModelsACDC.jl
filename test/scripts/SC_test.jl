###################################################################
#####   Code to test new functions to add superconductor links #####
###################################################################

using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using Gurobi
using Ipopt
using JSON

# Include new function
include("../../src/core/process_supercoductor_links.jl")

# Add system data
#data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
#data = _PM.parse_file("test/data/superconductivity/case5_acdc_sc.m") # New test case only P2P
data = _PM.parse_file("test/data/superconductivity/case67.m")
data_original = deepcopy(data)

nl_solver = Ipopt.Optimizer
#nl_solver = Gurobi.Optimizer

# Define superconductor links
#sc_links = ["1","2"] # Vector to state which dc branches are superconductor links
#sc_links = ["1","2","3"] # For meshed
sc_links = [string(i) for i in 1:11]
#sc_data = Dict{String,Any}() # Dict to save sc branches data

#sc_data = add_sc_links!(data,sc_links)
#sc_data = add_sc_links_2!(data,sc_links)
sc_data = add_sc_links_3!(data,sc_links)

#process_superconductor_links2!(data)
process_sc_meshed!(data)

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
print("\n Case 2: 1  SC Branch(es)   : ",result["objective"], "\n")

# Saving results to JSON
results_path = "/Users/rgallo/Library/CloudStorage/OneDrive-KULeuven/OPF_SC" 
# Original case (No SC)
json_string = JSON.json(result_original)
result_file_name = join([results_path,"/result_original.json"])
open(result_file_name,"w") do f
    JSON.print(f, json_string)
end

# 1 SC Link
json_string = JSON.json(result)
result_file_name = join([results_path,"/result_1_SC_link.json"])
open(result_file_name,"w") do f
    JSON.print(f, json_string)
end

# # Computation of losses
# losses = process_results!(result)
# losses_original = process_results!(result_original)

