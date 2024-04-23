###################################################################
#####   Code to test new functions to add superconductor links #####
###################################################################

using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
#using Gurobi
using Ipopt

# Include new Functions
include("../../src/core/process_supercoductor_links.jl")

# Add system data
#data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
data = _PM.parse_file("test/data/superconductivity/case5_acdc_sc.m") # New test case
data_original = deepcopy(data)

nl_solver = Ipopt.Optimizer

# Define superconductor links
sc_links = ["1"] # Vector to state which dc branches are superconductor links
sc_data = Dict{String,Any}() # Dict to save sc branches data

sc_data = add_sc_links(data,sc_links)

process_superconductor_links!(data,sc_data)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

_PMACDC.process_additional_data!(data)
_PMACDC.process_additional_data!(data_original)
result = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)
result_original = _PMACDC.run_acdcopf(data_original,ACPPowerModel,nl_solver;setting = s)
result_2 = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)

print("-------------------------------------------------------\n")
print("                  Optimization Results                 \n")
print("-------------------------------------------------------\n")
print("\n Case 1: No SC Branches : ",result_original["objective"], "\n")
print("\n Case 2: 1  SC Branch   : ",result["objective"], "\n")
print("\n Case 3: 2  SC Branches : ",result_2["objective"], "\n")

##### Results ######
# case5_acdc    = 194.139
# case5_acdc_sc = 196.496  # No SC branches
# case5_acdc_sc = 202.236 # 1 SC branch

using CSV

data_list = []

for (conv_id,convdc) in result["solution"]["convdc"]
    for (param,value) in convdc
        push!(data_list, (conv_id, param, value))
    end
end

CSV.write("data.csv", data_list, header=["Entry","Parameter","value"])
