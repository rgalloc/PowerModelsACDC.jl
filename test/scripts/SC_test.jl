###################################################################
#####   Code to test new functions to add superconductor links #####
###################################################################

using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using Gurobi
using Ipopt
using JSON

# Add system data
data = _PM.parse_file("test/data/superconductivity/case5_acdc.m")
#data = _PM.parse_file("test/data/superconductivity/case5_acdc_sc.m") # New test case only P2P
#data = _PM.parse_file("test/data/superconductivity/case67.m")
data_original = deepcopy(data)

nl_solver = Ipopt.Optimizer
#nl_solver = Gurobi.Optimizer

# Define superconductor links
sc_links = ["1","2"] # Vector to state which dc branches are superconductor links
#sc_links = ["1","2","3"] # For meshed
#sc_links = [string(i) for i in 1:11]
#sc_data = Dict{String,Any}() # Dict to save sc branches data

#sc_data = add_sc_links!(data,sc_links)
#sc_data = add_sc_links_2!(data,sc_links)
sc_data = _PMACDC.add_sc_links_3!(data,sc_links)

#process_superconductor_links2!(data)
#process_sc_meshed!(data)
_PMACDC.process_superconductor_links_new!(data)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

_PMACDC.process_additional_data!(data)
_PMACDC.process_additional_data!(data_original)
#result = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)
result_original = _PMACDC.run_acdcopf(data_original,ACPPowerModel,nl_solver;setting = s)
result_sc = _PMACDC.run_acdcopf_superconducting(data,ACPPowerModel,nl_solver;setting = s)
#result_2 = _PMACDC.run_acdcopf(data,ACPPowerModel,nl_solver;setting = s)

print("-------------------------------------------------------\n")
print("                  Optimization Results                 \n")
print("-------------------------------------------------------\n")
print("\n Case 1: No SC Branches : ",result_original["objective"], "\n")
#print("\n Case 2: 1  SC Branch(es)   : ",result["objective"], "\n")
print("\n Case 2: 2  SC Branch(es)   : ",result_sc["objective"], "\n")

# power flow in the dc lines
## Original
# 1 = 0.451
# 2 = 0.405
# 3 = 0.03

## With 1 and 2 SC
# 1 = 0.608
# 2 = 0.432
# 3 = 1.09


# # Saving results to JSON
# results_path = "/Users/rgallo/Library/CloudStorage/OneDrive-KULeuven/OPF_SC" 
# # Original case (No SC)
# json_string = JSON.json(result_original)
# result_file_name = join([results_path,"/result_original.json"])
# open(result_file_name,"w") do f
#     JSON.print(f, json_string)
# end

# # 1 SC Link
# json_string = JSON.json(result)
# result_file_name = join([results_path,"/result_1_SC_link.json"])
# open(result_file_name,"w") do f
#     JSON.print(f, json_string)
# end

# # Computation of losses
# losses = process_results!(result)
# losses_original = process_results!(result_original)

## Testing

con = Dict{String,Any}(
    "1" => Dict{String,Any}(
        "dc" => 1, "ac" => 2
    ),
    "2" => Dict{String,Any}(
        "dc" => 2, "ac" => 3
    ),
    "3" => Dict{String,Any}(
        "dc" => 3, "ac" => 5
    )
)
bran = Dict{String,Any}(
    "1" => Dict{String,Any}(
        "f" => 1, "t" => 2, "sc" => true    
    ),
    "2" => Dict{String,Any}(
        "f" => 2, "t" => 3, "sc" => true    
    ),
    "3" => Dict{String,Any}(
        "f" => 1, "t" => 3, "sc" => false    
    )
)
loa = Dict{String,Any}(
    "1" => Dict{String,Any}(
        "bus" => 2
    ),
    "2" => Dict{String,Any}(
        "bus" => 3
    ),
    "3" => Dict{String,Any}(
        "bus" => 4
    ),
    "4" => Dict{String,Any}(
        "bus" => 5
    )
)

matches = [
    (conv_id, branch_id) for (conv_id, conv_dc) in data["convdc"]
                        for (branch_id, branch_dc) in data["branchdc"]
                        if branch_dc["sc"] == true && (conv_dc["busdc_i"] == branch_dc["fbusdc"] || conv_dc["busdc_i"] == branch_dc["tbusdc"])
]

for (conv_id, branch_id) in matches
    if haskey(data["convdc"], conv_id)
        data["convdc"][conv_id]["sc"] = true # Modify the key-value pair as needed
         data["convdc"][conv_id]["Pacmax"] = 3*data["convdc"][conv_id]["Pacmax"]
         data["convdc"][conv_id]["Pacmin"] = 3*data["convdc"][conv_id]["Pacmin"] 
        #data["convdc"][conv_id]["Pacmax"] = 300
        #data["convdc"][conv_id]["Pacmin"] = 300

        if any(load["load_bus"] == data["convdc"][conv_id]["busac_i"] for (load_id, load) in data["load"])
            for (load_id, load) in data["load"]
                if load["load_bus"] == data["convdc"][conv_id]["busac_i"] # Add aux load from cooling
                    load["pd"] = load["pd"] + data["branchdc"][branch_id]["p_aux"]/2
                    load["qd"] = load["qd"] + data["branchdc"][branch_id]["q_aux"]/2
                end
            end
        else
            load_id_new = length(data["load"]) + 1 #Max load number + 1
            data["load"]["$load_id_new"] = Dict("source_id" => ["bus", data["convdc"][conv_id]["busac_i"]],
                                                    "load_bus" => data["convdc"][conv_id]["busac_i"],
                                                    "status" => 1, 
                                                    "qd" => data["branchdc"][branch_id]["p_aux"]/2, 
                                                    "pd" => data["branchdc"][branch_id]["q_aux"]/2,
                                                    "index" => load_id_new)
        end  
    end
end