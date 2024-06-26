# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_superconductor_links!(data::Dict{String,Any},sc_data::Dict{String,Any})
    # Extract dc buses of converter, join them
    for (conv_id, conv_dc) in data["convdc"]
        for (branch_id, branch_dc) in sc_data
            if conv_dc["busdc_i"] == branch_dc["tbusdc"]
                conv_dc["busdc_i"] = branch_dc["fbusdc"]
            end
        end
        
        # Check if this works with the for loops
        if any(load["load_bus"] == conv_dc["busac_i"] for (load_id, load) in data["load"])
            for (load_id, load) in data["load"]
                if load["load_bus"] == conv_dc["busac_i"] # Add aux load from cooling
                    load["pd"] = load["pd"] + branch_dc["p_aux"]/2
                    load["qd"] = load["qd"] + branch_dc["q_aux"]/2
                end
            end
        else
            load_id_new = length(data["load"]) + 1
            data["load"][string(load_id_new)] = Dict("source_id" => ["bus", conv_dc["busac_i"]],
                                                     "load_bus" => conv_dc["busac_i"],
                                                     "status" => 1, 
                                                     "qd" => branch_dc["q_aux"]/2, 
                                                     "pd" => branch_dc["p_aux"]/2,
                                                     "index" => load_id_new)
        end    
    end    

    for (branch_id,branch_dc) in sc_data
        delete!(data["branchdc"],"$branch_id")
    end
end

# Function to add sc key to branchdc data
# Creates sc_data dictionary with superconducting branches data
# Merges sc_data with the grid data
# function add_sc_links!(data::Dict{String,Any},sc_links::Vector{String})
    
#     sc_data = Dict{String, Dict{String, Any}}() # Empty dict to save sc data

#     # Loop through input to copy data from main dict
#     for sc_link in sc_links
#         if haskey(data["branchdc"],sc_link)
#             sc_data["branchdc"][sc_link] = deepcopy(data["branchdc"][sc_link])

#             sc_data["branchdc"][sc_link]["length"] = 200 # All sc branches 200 km, to modify later
#             sc_data["branchdc"][sc_link]["p_aux"]  = cooling_losses(sc_data["branchdc"][sc_link]["length"])[1]
#             sc_data["branchdc"][sc_link]["q_aux"]  = cooling_losses(sc_data["branchdc"][sc_link]["length"])[2]
#             sc_data["branchdc"][sc_link]["sc"]     = true
#         end
#     end
#     merge!(data["branchdc"],sc_data)
#     return sc_data
# end

function add_sc_links_2!(data::Dict{String,Any},sc_links::Vector{String})
    sc_data = Dict{String,Any}() # Empy dict to save sc data
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
            sc_data[sc_link]["length"] = 200 # All sc branches 200 km, to modify later
            sc_data[sc_link]["p_aux"] = cooling_losses(sc_data[sc_link]["length"])[1]
            sc_data[sc_link]["q_aux"] = cooling_losses(sc_data[sc_link]["length"])[2]
        end
    end
    merge!(data["branchdc"],sc_data)
end

# Function modifying directly data dict
function add_sc_links_3!(data::Dict{String,Any},sc_links::Vector{String})
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            data["branchdc"][sc_link]["length"] = 100 # All sc branches 200 km, to modify later
            data["branchdc"][sc_link]["p_aux"]  = cooling_losses(data["branchdc"][sc_link]["length"])[1]
            data["branchdc"][sc_link]["q_aux"]  = cooling_losses(data["branchdc"][sc_link]["length"])[2]
            data["branchdc"][sc_link]["sc"]     = true
        end
    end

    for (branchdc_id, branch_dc) in data["branchdc"] # Possibly deleting this part
        if !haskey(branch_dc,"sc")
            branch_dc["sc"] = false
        end
    end  
end

function process_superconductor_links2!(data::Dict{String,Any})
    
    for (conv_id, conv_dc) in data["convdc"]        
        for (branch_id, branch_dc) in data["branchdc"]
            if branch_dc["sc"] == true
                if conv_dc["busdc_i"] == branch_dc["tbusdc"] || conv_dc["busdc_i"] == branch_dc["fbusdc"]
                    conv_dc["busdc_i"] = branch_dc["fbusdc"]
                    conv_dc["p_aux"] = branch_dc["p_aux"]/2
                    conv_dc["q_aux"] = branch_dc["q_aux"]/2
                    conv_dc["sc"]    =  true
                end                
            end
        end
        
        if haskey(conv_dc,"sc")
            if any(load["load_bus"] == conv_dc["busac_i"] for (load_id, load) in data["load"])
                for (load_id, load) in data["load"]
                    if load["load_bus"] == conv_dc["busac_i"] # Add aux load from cooling
                        load["pd"] = load["pd"] + conv_dc["p_aux"]
                        load["qd"] = load["qd"] + conv_dc["q_aux"]
                    end
                end
            else
                load_id_new = length(data["load"]) + 1
                data["load"][string(load_id_new)] = Dict("source_id" => ["bus", conv_dc["busac_i"]],
                                                        "load_bus" => conv_dc["busac_i"],
                                                        "status" => 1, 
                                                        "qd" => conv_dc["p_aux"], 
                                                        "pd" => conv_dc["q_aux"],
                                                        "index" => load_id_new)
            end  
        end
    end

    for (branch_id,branch_dc) in data["branchdc"]
        if branch_dc["sc"] == true
            delete!(data["branchdc"],"$branch_id")
        end
    end

end

# This function calculate the cooling losses based on length
function cooling_losses(length)
    p_losses = 0.005 # Losses equal to 500 kW per station and 1 station every 25 km
    pf = 0.85
    aux_power = []
    p_aux = ceil((length/25))*p_losses
    q_aux = round(p_aux*tan(acos(pf)),digits=3)
    push!(aux_power,p_aux) # Active power losses
    push!(aux_power,q_aux) # Reactive power losses
    return aux_power # Vector with [p_aux,q_aux]
end

function process_results!(result::Dict{String,Any})
    # Function to compute network losses
    losses = Dict{String,Any}()
    losses["branches_ac"] = 0
    losses["branches_dc"] = 0
    losses["convdc"] = Dict{String,Any}()

    # AC branches losses
    for (branch_id,branch) in result["solution"]["branch"]
        losses["branches_ac"] = losses["branches_ac"] + loss_calc(branch["pt"],branch["pf"])
    end
    # DC branches losses
    for (branchdc_id,branchdc) in result["solution"]["branchdc"]
        losses["branches_dc"] = losses["branches_dc"] + loss_calc(branchdc["pt"],branchdc["pf"])
    end
end

# Calculates the magnitude of the losses
function loss_calc(x,y)
    return abs( abs(x) - abs(y) )
end