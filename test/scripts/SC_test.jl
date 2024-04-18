###################################################################
#####   Code to test new function to add superconductor links #####
###################################################################

using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using Gurobi
using Ipopt

# Include new Functions
include("../../src/core/process_supercoductor_links.jl")

# Add system data
data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
data_original = deepcopy(data)

# Define superconductor links
sc_links = ["1","2"] # Vector to state whihc dc branches are superconductor links
sc_data = Dict{String,Any}() # Dict to save sc branches data

# for branch_id in data["branchdc"]
#     print("$branch_id\n")
#     for i in sc_links["sc_branch"]
#         print("DC Branch ","$i"," is superconductor link\n")
#     end
# end

sc_data = add_sc_links(data,sc_links)

# Copy data from dc branches into new dictionary
for sc_link in sc_links
    if haskey(data["branchdc"],sc_link)
        print("DC branch ",sc_link," is a superconductor link\n")
        sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
    end
end

convdc_sc = Dict{String,Any}
for branch_index in sc_data
    if sc_data[branch_index]["fbusdc"] == data["convdc"][branch_index]["busdc_i"] || sc_data[branch_index]["tbusdc"] == data["convdc"][branch_index]["busdc_i"]
        convdc_sc = deepcopy(data["convdc"][branch_index])
    end
end