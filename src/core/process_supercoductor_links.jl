# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

# For P2P links
function process_superconductor_links2!(data::Dict{String,Any})
    
    for (conv_id, conv_dc) in data["convdc"]        
        for (branch_id, branch_dc) in data["branchdc"]
            if branch_dc["sc"] == true
                if conv_dc["busdc_i"] == branch_dc["tbusdc"] || conv_dc["busdc_i"] == branch_dc["fbusdc"]
                    conv_dc["busdc_i"] = branch_dc["fbusdc"]
                    conv_dc["p_aux"] = branch_dc["p_aux"]/2 # Active power required for the auxiliaries (cooling stations)
                    conv_dc["q_aux"] = branch_dc["q_aux"]/2 # Reactive power required for the auxiliaries (cooling stations)
                    conv_dc["sc"]    =  true
                    # Increase capacity of converters (not in pu as they are converted later)
                    conv_dc["Pacmax"] = 300
                    conv_dc["Pacmin"] = -300
                    # conv_dc["Imax"] = 3 # Its calculated in the function process_additional_data based on P and Q
                    
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
                load_id_new = length(data["load"]) + 1 #Max load number + 1
                data["load"]["$load_id_new"] = Dict("source_id" => ["bus", conv_dc["busac_i"]],
                                                        "load_bus" => conv_dc["busac_i"],
                                                        "status" => 1, 
                                                        "qd" => conv_dc["p_aux"], 
                                                        "pd" => conv_dc["q_aux"],
                                                        "index" => load_id_new)
            end  
        end
    end

    for (branch_id,branch_dc) in data["branchdc"] # Open line instead of deleting
        if branch_dc["sc"] == true
            #delete!(data["branchdc"],"$branch_id")
            branch_dc["status"] = 0
        end
    end

end

# Function to add sc key to branchdc data

function add_sc_links_3!(data::Dict{String,Any},sc_links::Vector{String})
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            data["branchdc"][sc_link]["length"] = 100 # All sc branches 100 km, to modify later
            data["branchdc"][sc_link]["p_aux"]  = cooling_losses(data["branchdc"][sc_link]["length"])[1]*0.1
            data["branchdc"][sc_link]["q_aux"]  = cooling_losses(data["branchdc"][sc_link]["length"])[2]*0.1
            data["branchdc"][sc_link]["sc"]     = true
        end
    end

    for (branchdc_id, branch_dc) in data["branchdc"] # Possibly deleting this part
        if !haskey(branch_dc,"sc")
            branch_dc["sc"] = false
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

## Put these functions in a different file

# Function to calculate losses in transmission/conversion
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

    return losses
end

# Calculates the magnitude of the losses
function loss_calc(x,y)
    return abs( abs(x) - abs(y) )
end