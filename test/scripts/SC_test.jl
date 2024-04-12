using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using Gurobi
using Ipopt

# Add system data
data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
data_original = deepcopy(data)

# Define superconductor links
# First define all branches as sc
sc_links = Dict{String,Any}("sc_branch" => [1,2,3]) # Dict to save the branch_id of sc_links

for branch_id in data["branchdc"]
    print("$branch_id\n")
    for i in sc_links["sc_branch"]
        print("DC Branch ","$i"," is superconductor link\n")
    end
end