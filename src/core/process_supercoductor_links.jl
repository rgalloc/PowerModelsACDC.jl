# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_superconductor_links!(data::Dict{String,Any},sc_data::Dict{String,Any})
    # Extract dc buses of converter, join them

    for (branch_id,branch_dc) in sc_data
        for (conv_id,conv_dc) in data["convdc"]
            if conv_dc["busdc_i"] == branch_dc["fbusdc"] || conv_dc["busdc_i"] == branch_dc["tbusdc"]
                conv_dc["busdc_i"] = branch_dc["fbusdc"] # Connect converter at both sides of sc branch to same dc busdc_i
                for (load_id,load) in data["load"]
                    if load["load_bus"] == conv_dc["busac_i"] # Update later to consider no previous load
                        load["pd"] = load["pd"] + branch_dc["p_loss"]/2 # Adds half the losses at each side of the converter
                        load["qd"] = load["qd"] + branch_dc["q_loss"]/2
                    end
                end
            end
        end
        delete!(data["branchdc"],"$branch_id")
    end

end

# Function to add sc key to branchdc data
function add_sc_links(data::Dict{String,Any},sc_links::Vector{String})
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
            sc_data[sc_link]["length"] = 200 # All sc branches 200 km, to modify later
            sc_data[sc_link]["p_loss"] = cooling_losses(sc_data[sc_link]["length"])
            sc_data[sc_link]["q_loss"] = round(sc_data[sc_link]["p_loss"]*tan(acos(pf)),digits=3)
        end
    end
    return sc_data
end

function add_sc_links_2!(data::Dict{String,Any},sc_links::Vector{String})
    sc_data = Dict{String,Any}() # Empy dict to save sc data
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
            sc_data[sc_link]["length"] = 200 # All sc branches 200 km, to modify later
            sc_data[sc_link]["p_loss"] = cooling_losses(sc_data[sc_link]["length"])
            sc_data[sc_link]["q_loss"] = round(sc_data[sc_link]["p_loss"]*tan(acos(pf)),digits=3)
        end
    end
    merge!(data["branchdc"],sc_data)
end

# This function calculate the cooling losses based on length
function cooling_losses(length)
    p_losses = 0.005 # Losses equal to 500 kW per station and 1 station every 25 km
    pf = 0.85
    p_load = ceil((length/25))*p_losses
    q_load = round(p_load*tan(acos(pf)),digits=3)
    return p_load#q_load
end