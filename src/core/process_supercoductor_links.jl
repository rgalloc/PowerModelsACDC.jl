# Functions to add data related to superconductors links

# This function points at dc branches to eliminate the branch and join
# the converters in one DC node
# Additionally, the cooling power is added at both sides of the converters
# in their associated AC nodes, half at each end

function process_superconductor_links!(data::Dict{String,Any})
    

end

# Function to add sc key to branchdc data
function add_sc_links!(data::Dict{String,Any},sc_links::Dict{String,Any})
    for branch_id in data["branchdc"]
        print("$branch_id\n")
        for i in sc_links["sc_branch"]
            print("DC Branch ","$i"," is superconductor link\n")
        end
    end
end

# This function calculate the cooling losses based on length
function cooling_losses(length)
    p_losses = 500 # Losses equal to 500 kW per station and 1 station every 25 km
    P_cooling = (length/25)*p_losses

    return P_cooling
end