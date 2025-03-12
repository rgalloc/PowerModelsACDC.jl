# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_sc_links!(data::Dict{String,Any},sc_links::Vector{String})

    add_sc_links!(data,sc_links)

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
end

# Function to define which DC branches are superconducting
function add_sc_links!(data::Dict{String,Any},sc_links::Vector{String})

    Sbase = data["baseMVA"]

    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            data["branchdc"][sc_link]["length"] = 100 # All sc branches 100 km, to modify later
            data["branchdc"][sc_link]["p_aux"]  = cooling_power(data["branchdc"][sc_link]["length"],Sbase)[1]*0.1 #0.1 to reduce the relative magnitude of the losses with respect to the total system load of the 5 bus case.
            data["branchdc"][sc_link]["q_aux"]  = cooling_power(data["branchdc"][sc_link]["length"],Sbase)[2]*0.1
            data["branchdc"][sc_link]["sc"]     = true
            data["branchdc"][sc_link]["rateA"]  = 3*data["branchdc"][sc_link]["rateA"]
        end
    end

    for (~, branch_dc) in data["branchdc"]
        if !haskey(branch_dc,"sc")
            branch_dc["sc"] = false
        end
    end  
end

# This function calculate the cooling power based on length
function cooling_power(length,Sbase)
    # Sb = 100 MVA
    p_losses = 0.5/Sbase # Losses equal to 500 kW per station and 1 station every 25 km
    pf = 0.85 # Assumption
    aux_power = []
    p_aux = ceil((length/25))*p_losses
    q_aux = round(p_aux*tan(acos(pf)),digits=3)
    push!(aux_power,p_aux) # Active power losses
    push!(aux_power,q_aux) # Reactive power losses
    return aux_power # Vector with [p_aux,q_aux]
end