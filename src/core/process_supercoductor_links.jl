# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_superconductor_links!(data::Dict{String,Any},sc_data::Dict{String,Any})
    # Extract dc buses of converter and join them
    node_dc = sc_data["1"]["fbusdc"]
    for 
    # Calculate the losses and add them to the ac buses of converter
    # for loop to eliminate the branches

end

# Function to add sc key to branchdc data
function add_sc_links(data::Dict{String,Any},sc_links::Vector{String})
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
            sc_data[sc_link]["length"] = 200 # All sc branches 200 km, to modify later
        end
    end
    return sc_data
end

# This function calculate the cooling losses based on length
function cooling_losses(length)
    p_losses = 0.005 # Losses equal to 500 kW per station and 1 station every 25 km
    return ceil((length/25))*p_losses
end