# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_superconductor_links!(data::Dict{String,Any})
    

end

# Function to add sc key to branchdc data
function add_sc_links(data::Dict{String,Any},sc_links::Vector{String})
    for sc_link in sc_links
        if haskey(data["branchdc"],sc_link)
            sc_data[sc_link] = deepcopy(data["branchdc"][sc_link])
        end
    end
    return sc_data
end

# This function calculate the cooling losses based on length
function cooling_losses(length)
    p_losses = 500 # Losses equal to 500 kW per station and 1 station every 25 km
    P_cooling = (length/25)*p_losses

    return P_cooling
end