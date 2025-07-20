using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots

# Testing PFC addition 

## Data with no PFC added 

data = _PM.parse_file("./test/data/case5_acdc.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Data with PFC added
data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Printing results
println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])

error = resultIVR_PFC["objective"] - resultIVR["objective"]

solution_1 = resultIVR["solution"]
solution_2 = resultIVR_PFC["solution"]


branchdc_1 = solution_1["branchdc"]
branchdc_2 = solution_2["branchdc"] 

busdc_1 = solution_1["busdc"]
busdc_2 = solution_2["busdc"]

solution_2["pfc"]

branch_1 = solution_1["branch"]
branch_2 = solution_2["branch"]

ac_from = []
ac_to = []

for (i, branch) in branch_1
    push!(ac_from, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from = [t[1] for t in ac_from]  # Extract indices from ac_from
values_from = [t[2] for t in ac_from]   # Extract pf values from ac_from

indices_to = [t[1] for t in ac_to]      # Extract indices from ac_to
values_to = [t[2] for t in ac_to]       # Extract pt values from ac_to

# Plot the values
scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")

ac_from_pfc = []
ac_to_pfc = []

for (i, branch) in branch_2
    push!(ac_from_pfc, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to_pfc, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from_pfc = [t[1] for t in ac_from_pfc]  # Extract indices from ac_from
values_from_pfc = [t[2] for t in ac_from_pfc]   # Extract pf values from ac_from

indices_to_pfc = [t[1] for t in ac_to_pfc]      # Extract indices from ac_to
values_to_pfc = [t[2] for t in ac_to_pfc]       # Extract pt values from ac_to

# Plot the values
#scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")
#plot!(indices_to, values_to, label="pt (to)")
scatter!(indices_from_pfc, values_from_pfc, label="pf (from) PFC")


## Without PFC ##
# OF = 194.16396546937983
## With PFC ##
# OF = 194.16396531945702

## Adding congestion to the system
## All dc line capacity reduced from 100 MW to 30 MW

# No PFC

data = _PM.parse_file("./test/data/case5_acdc.m")

data["branchdc"]["1"]["rateA"] = 30
data["branchdc"]["2"]["rateA"] = 30
data["branchdc"]["3"]["rateA"] = 30

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

# PFC

data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

data["branchdc"]["1"]["rateA"] = 30
data["branchdc"]["2"]["rateA"] = 30
data["branchdc"]["3"]["rateA"] = 30

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])

solution_1 = resultIVR["solution"]
solution_2 = resultIVR_PFC["solution"]

branchdc_1 = solution_1["branchdc"]

branchdc_2 = solution_2["branchdc"]

solution_2["pfc"]

branch_1 = solution_1["branch"]
branch_2 = solution_2["branch"]

ac_from = []
ac_to = []

for (i, branch) in branch_1
    push!(ac_from, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from = [t[1] for t in ac_from]  # Extract indices from ac_from
values_from = [t[2] for t in ac_from]   # Extract pf values from ac_from

indices_to = [t[1] for t in ac_to]      # Extract indices from ac_to
values_to = [t[2] for t in ac_to]       # Extract pt values from ac_to

# Plot the values
scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")

ac_from_pfc = []
ac_to_pfc = []

for (i, branch) in branch_2
    push!(ac_from_pfc, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to_pfc, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from_pfc = [t[1] for t in ac_from_pfc]  # Extract indices from ac_from
values_from_pfc = [t[2] for t in ac_from_pfc]   # Extract pf values from ac_from

indices_to_pfc = [t[1] for t in ac_to_pfc]      # Extract indices from ac_to
values_to_pfc = [t[2] for t in ac_to_pfc]       # Extract pt values from ac_to

# Plot the values
#scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")
#plot!(indices_to, values_to, label="pt (to)")
scatter!(indices_from_pfc, values_from_pfc, label="pf (from) PFC")


## N-1 condition in the system

# Line 2 disconnected

# No PFC

data = _PM.parse_file("./test/data/case5_acdc.m")

data["branchdc"]["2"]["status"] = 0

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

# PFC

data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

data["branchdc"]["2"]["status"] = 0

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])


solution_1 = resultIVR["solution"]
solution_2 = resultIVR_PFC["solution"]

branchdc_1 = solution_1["branchdc"]
branchdc_2 = solution_2["branchdc"]

dc_from = []
dc_to = []

for (i, branchdc) in branchdc_1
    push!(dc_from, (i, branchdc["pf"]))  # Save index and pf as a tuple
    push!(dc_to, (i, branchdc["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from = [t[1] for t in dc_from]  # Extract indices from ac_from
values_from = [t[2] for t in dc_from]   # Extract pf values from ac_from

indices_to = [t[1] for t in dc_to]      # Extract indices from ac_to
values_to = [t[2] for t in dc_to]       # Extract pt values from ac_to

dc_from_pfc = []
dc_to_pfc = []

for (i, branchdc) in branchdc_2
    push!(dc_from_pfc, (i, branchdc["pf"]))  # Save index and pf as a tuple
    push!(dc_to_pfc, (i, branchdc["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from_pfc = [t[1] for t in dc_from_pfc]  # Extract indices from ac_from
values_from_pfc = [t[2] for t in dc_from_pfc]   # Extract pf values from ac_from

indices_to_pfc = [t[1] for t in dc_to_pfc]      # Extract indices from ac_to
values_to_pfc = [t[2] for t in dc_to_pfc]       # Extract pt values from ac_to

# Plot the values
scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in DC branches")
scatter!(indices_from_pfc, values_from_pfc, label="pf (from) PFC")

branch_1 = solution_1["branch"]
branch_2 = solution_2["branch"]

ac_from = []
ac_to = []

for (i, branch) in branch_1
    push!(ac_from, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from = [t[1] for t in ac_from]  # Extract indices from ac_from
values_from = [t[2] for t in ac_from]   # Extract pf values from ac_from

indices_to = [t[1] for t in ac_to]      # Extract indices from ac_to
values_to = [t[2] for t in ac_to]       # Extract pt values from ac_to

# Plot the values
scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")



ac_from_pfc = []
ac_to_pfc = []

for (i, branch) in branch_2
    push!(ac_from_pfc, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to_pfc, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from_pfc = [t[1] for t in ac_from_pfc]  # Extract indices from ac_from
values_from_pfc = [t[2] for t in ac_from_pfc]   # Extract pf values from ac_from

indices_to_pfc = [t[1] for t in ac_to_pfc]      # Extract indices from ac_to
values_to_pfc = [t[2] for t in ac_to_pfc]       # Extract pt values from ac_to

# Plot the values
#scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")
#plot!(indices_to, values_to, label="pt (to)")
scatter!(indices_from_pfc, values_from_pfc, label="pf (from) PFC")

total_gen = solution_1["gen"]["1"]["pg"] + solution_2["gen"]["1"]["pg"]
total_load = 


solution_2["pfc"]

## Increased demand in the system with reduced capacity

# No PFC

data = _PM.parse_file("./test/data/case5_acdc.m")

data["branchdc"]["1"]["rateA"] = 30
data["branchdc"]["2"]["rateA"] = 30
data["branchdc"]["3"]["rateA"] = 30

data["load"]["1"]["pd"] = data["load"]["1"]["pd"]*1.2
data["load"]["2"]["pd"] = data["load"]["2"]["pd"]*1.2
data["load"]["3"]["pd"] = data["load"]["3"]["pd"]*1.2
data["load"]["4"]["pd"] = data["load"]["4"]["pd"]*1.2


_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

# PFC

data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

data["branchdc"]["1"]["rateA"] = 30
data["branchdc"]["2"]["rateA"] = 30
data["branchdc"]["3"]["rateA"] = 30

data["load"]["1"]["pd"] = data["load"]["1"]["pd"]*1.2
data["load"]["2"]["pd"] = data["load"]["2"]["pd"]*1.2
data["load"]["3"]["pd"] = data["load"]["3"]["pd"]*1.2
data["load"]["4"]["pd"] = data["load"]["4"]["pd"]*1.2

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])

solution_1 = resultIVR["solution"]
solution_2 = resultIVR_PFC["solution"]

branchdc_1 = solution_1["branchdc"]

branchdc_2 = solution_2["branchdc"]

solution_2["pfc"]

branch_1 = solution_1["branch"]

ac_from = []
ac_to = []

for (i, branch) in branch_1
    push!(ac_from, (i, branch["pf"]))  # Save index and pf as a tuple
    push!(ac_to, (i, branch["pt"]))    # Save index and pt as a tuple
end

# Extract indices and values from the tuples
indices_from = [t[1] for t in ac_from]  # Extract indices from ac_from
values_from = [t[2] for t in ac_from]   # Extract pf values from ac_from

indices_to = [t[1] for t in ac_to]      # Extract indices from ac_to
values_to = [t[2] for t in ac_to]       # Extract pt values from ac_to

# Plot the values
scatter(indices_from, values_from, label="pf (from)", xlabel="Branch Index", ylabel="Power Flow", title="Power Flow in AC branches")
#plot!(indices_to, values_to, label="pt (to)")

branch_2 = solution_2["branch"]


### PFC in new location (DC Bus 2)

## Data with no PFC added 

data = _PM.parse_file("./test/data/case5_acdc.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Data with PFC added
data = _PM.parse_file("./test/data/case5_acdc_pfc_2.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Printing results
println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])

solution_1 = resultIVR["solution"]
solution_2 = resultIVR_PFC["solution"]


branchdc_1 = solution_1["branchdc"]
branchdc_2 = solution_2["branchdc"] 

busdc_1 = solution_1["busdc"]
busdc_2 = solution_2["busdc"]

solution_2["pfc"]


#######
### Test with 67-bus system

data1 = _PM.parse_file("./test/data/case67.m")

_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)




### Test with 67-bus system with PFC in DC bus 1
data2 = _PM.parse_file("./test/data/case67_PFC.m")

_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

resultIVR_67_PFC["solution"]["pfc"]

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings with PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    println("DC Branch $branchdc_id: No PFC = $load1, With PFC = $load2, Delta = $delta")
end

### Creating congestion with N-1 condition in the system

## DC Branch 2 disconnected

## No PFC
data1 = _PM.parse_file("./test/data/case67.m")

data1["branchdc"]["2"]["status"] = 0

_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)

## With PFC
data2 = _PM.parse_file("./test/data/case67_PFC.m")

data2["branchdc"]["2"]["status"] = 0

_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

# for (branch_id, branch) in loading1["AC"]
#     println("AC Branch $branch_id loading: $branch")
# end

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings WITH PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

# for (branch_id, branch) in loading2["AC"]
#     println("AC Branch $branch_id loading: $branch")
# end

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
println("DC Branch ------ Load1 ------- Load2 ------- Delta")
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    #println("DC Branch $branchdc_id: Load1 = $load1, Load2 = $load2, Delta = $delta")
    #println("DC Branch ------ Load1 ------- Load2 ------- Delta")
    println("$branchdc_id, $load1, $load2, $delta")
end

## DC Branch 3 disconnected

## No PFC
data1 = _PM.parse_file("./test/data/case67.m")

data1["branchdc"]["3"]["status"] = 0

_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)

## With PFC
data2 = _PM.parse_file("./test/data/case67_PFC.m")

data2["branchdc"]["3"]["status"] = 0

_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

# for (branch_id, branch) in loading1["AC"]
#     println("AC Branch $branch_id loading: $branch")
# end

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings WITH PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

# for (branch_id, branch) in loading2["AC"]
#     println("AC Branch $branch_id loading: $branch")
# end

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
println("DC Branch ------ Load1 ------- Load2 ------- Delta")
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    println("$branchdc_id, $load1, $load2, $delta")
end



### Test with 67-bus system with PFC in DC bus 6
data1 = _PM.parse_file("./test/data/case67.m")

_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)


data2 = _PM.parse_file("./test/data/case67_PFC2.m")

_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

resultIVR_67_PFC["solution"]["pfc"]

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings with PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
println("DC Branch ------ Load1 ------- Load2 ------- Delta")
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    println("$branchdc_id, $load1, $load2, $delta")
end

### Adding congestion to the system with N-1 condition
# DC Branch 3 disconnected

data1 = _PM.parse_file("./test/data/case67.m")
data1["branchdc"]["3"]["status"] = 0
_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)


data2 = _PM.parse_file("./test/data/case67_PFC2.m")
data2["branchdc"]["3"]["status"] = 0
_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

resultIVR_67_PFC["solution"]["pfc"]

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings with PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
println("DC Branch ------ Load1 ------- Load2 ------- Delta")
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    println("$branchdc_id, $load1, $load2, $delta")
end

# DC Branch 7 disconnected

data1 = _PM.parse_file("./test/data/case67.m")
data1["branchdc"]["7"]["status"] = 0
_PMACDC.process_additional_data!(data1)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67 = _PMACDC.solve_acdcopf_iv(data1, _PM.IVRPowerModel, ipopt; setting = s)


data2 = _PM.parse_file("./test/data/case67_PFC2.m")
data2["branchdc"]["7"]["status"] = 0
_PMACDC.process_additional_data!(data2)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data2, _PM.IVRPowerModel, ipopt; setting = s)

resultIVR_67_PFC["solution"]["pfc"]

diff = (resultIVR_67["objective"] - resultIVR_67_PFC["objective"])#/ resultIVR_67["objective"]

print("######################################################################################\n")
print("DC Branch Loadings NO PFC\n")
print("######################################################################################\n")

loading1 = compute_branch_loading(resultIVR_67, data1)

for (branchdc_id, branchdc) in loading1["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loadings with PFC\n")
print("######################################################################################\n")

loading2 = compute_branch_loading(resultIVR_67_PFC, data2)

for (branchdc_id, branchdc) in loading2["DC"]
    println("DC Branch $branchdc_id loading: $branchdc")
end

print("######################################################################################\n")
print("DC Branch Loading Comparison\n")
print("######################################################################################\n")

comparison = compare_branch_loading(loading1, loading2)
println("DC Branch ------ Load1 ------- Load2 ------- Delta")
for (branchdc_id, (load1, load2, delta)) in comparison["DC"]
    println("$branchdc_id, $load1, $load2, $delta")
end


###################################
###################################
###################################

#### Iteratively PFC running with PFC location and N-1 contingency

###################################
###################################
###################################

# OPF for NO PFC case and all N-1 contingencies in the DC grid

OF = Dict()
#Base case - no PFC
data1 = _PM.parse_file("./test/data/case67.m")
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

for (branchdc_id,branchdc) in data1["branchdc"]
    data_run = deepcopy(data1)
    data_run["branchdc"]["$branchdc_id"]["status"] = 0

    _PMACDC.process_additional_data!(data_run)

    resultIVR_67 = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
    OF["$branchdc_id"] = resultIVR_67["objective"]
end

# OPF for PFC in bus 1

OF_1 = Dict()
data2 = _PM.parse_file("./test/data/case67_PFC.m")

for (branchdc_id,branchdc) in data2["branchdc"]
    data_run = deepcopy(data2)
    data_run["branchdc"]["$branchdc_id"]["status"] = 0

    _PMACDC.process_additional_data!(data_run)

    resultIVR_67_PFC = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
    OF_1["$branchdc_id"] = resultIVR_67_PFC["objective"]
end





# Function to compute branch loading for AC and DC branches
function compute_branch_loading(result,data)
    loading = Dict("AC" => Dict(), "DC" => Dict())
    # AC Branches
    for (branch_id, branch) in result["solution"]["branch"]
        branch_rate = data["branch"]["$branch_id"]["rate_a"]
        #from
        branch_p_from = branch["pf"]
        branch_q_from = branch["qf"]
        branch_s_from = sqrt(branch_p_from^2 + branch_q_from^2)
        #to
        branch_p_to = branch["pt"]
        branch_q_to = branch["qt"]
        branch_s_to = sqrt(branch_p_to^2 + branch_q_to^2)

        branch_s = max(branch_s_from, branch_s_to)
        loading["AC"]["$branch_id"] = branch_s/branch_rate
    end
    # DC Branches
    for (branchdc_id, branchdc) in result["solution"]["branchdc"]
        branchdc_rate = data["branchdc"]["$branchdc_id"]["rateA"]
        #from
        branchdc_p_from = abs(branchdc["pf"])
        #to
        branchdc_p_to = abs(branchdc["pt"])

        branchdc_p = max(branchdc_p_from, branchdc_p_to)
        loading["DC"]["$branchdc_id"] = branchdc_p/branchdc_rate
    end
    return loading
end

function compare_branch_loading(loading1, loading2)
    comparison = Dict("AC" => Dict(), "DC" => Dict())
    # AC Branches
    for (branch_id, load1) in loading1["AC"]
        load2 = get(loading2["AC"], branch_id, 0.0)
        delta = load2 - load1
        #comparison["AC"]["$branch_id"] = (load1, load2, load2/load1)
        comparison["AC"]["$branch_id"] = (load1, load2, delta)
    end
    # DC Branches
    for (branchdc_id, load1) in loading1["DC"]
        load2 = get(loading2["DC"], branchdc_id, 0.0)
        delta = load2 - load1
        comparison["DC"]["$branchdc_id"] = (load1, load2, delta)
    end
    return comparison
end


# print("######################################################################################\n")
# print("AC Branch Loadings\n")
# print("######################################################################################\n")

# for (branch_id, branch) in resultIVR_67["solution"]["branch"]
#     branch_rate = data["branch"]["$branch_id"]["rate_a"]
#     #from
#     branch_p_from = branch["pf"]
#     branch_q_from = branch["qf"]
#     branch_s_from = sqrt(branch_p_from^2 + branch_q_from^2)
#     #to
#     branch_p_to = branch["pt"]
#     branch_q_to = branch["qt"]
#     branch_s_to = sqrt(branch_p_to^2 + branch_q_to^2)

#     branch_s = max(branch_s_from, branch_s_to)
#     loading = branch_s/branch_rate
#     println("AC Branch $branch_id loading: $loading")
# end


# print("######################################################################################\n")
# print("DC Branch Loadings\n")
# print("######################################################################################\n")

# for (branchdc_id, branchdc) in resultIVR_67["solution"]["branchdc"]
#     branchdc_rate = data["branchdc"]["$branchdc_id"]["rateA"]
#     #from
#     branchdc_p_from = abs(branchdc["pf"])
#     #to
#     branchdc_p_to = abs(branchdc["pt"])

#     branchdc_p = max(branchdc_p_from, branchdc_p_to)
#     loading = branchdc_p/branchdc_rate
#     println("DC Branch $branchdc_id loading: $loading")
# end

### Calculate the loading of the lines AC and DC

# print("######################################################################################\n")
# print("AC Branch Loadings\n")
# print("######################################################################################\n")
# for (branch_id, branch) in resultIVR_67_PFC["solution"]["branch"]
#     branch_rate = data["branch"]["$branch_id"]["rate_a"]
#     #from
#     branch_p_from = branch["pf"]
#     branch_q_from = branch["qf"]
#     branch_s_from = sqrt(branch_p_from^2 + branch_q_from^2)
#     #to
#     branch_p_to = branch["pt"]
#     branch_q_to = branch["qt"]
#     branch_s_to = sqrt(branch_p_to^2 + branch_q_to^2)

#     branch_s = max(branch_s_from, branch_s_to)
#     loading = branch_s/branch_rate
#     println("AC Branch $branch_id loading: $loading")
# end
# print("######################################################################################\n")
# print("DC Branch Loadings\n")
# print("######################################################################################\n")
# for (branchdc_id, branchdc) in resultIVR_67_PFC["solution"]["branchdc"]
#     branchdc_rate = data["branchdc"]["$branchdc_id"]["rateA"]
#     #from
#     branchdc_p_from = abs(branchdc["pf"])
#     #to
#     branchdc_p_to = abs(branchdc["pt"])

#     branchdc_p = max(branchdc_p_from, branchdc_p_to)
#     loading = branchdc_p/branchdc_rate
#     println("DC Branch $branchdc_id loading: $loading")
# end


# data = _PM.parse_file("./test/data/case5_acdc.m")
# data = _PM.parse_file("./test/data/case5.m")

# _PMACDC.process_additional_data!(data)

# ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
# s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

# resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)
# resultACPM = _PM.solve_opf(data, _PM.ACPPowerModel, ipopt; setting = s)

# # ref_add_pfc!


# data = _PM.parse_file("./test/data/case5_acdc_pfc.m")
# data["pfc"] = Dict( "1" => Dict(
#                                 "pfc_status" => 1,
#                                 "terminal1_bus"  => 1,
#                                 "terminal2_bus"  => 4,
#                                 "terminal3_bus"  => 5,
#                                 "emin"  => -4/345,
#                                 "emax"  =>  4/345
# ))


# pm = _PM.instantiate_model(data, ACPPowerModel, build_opf; setting = s)
# ref_data = _PM.ref(pm)

# ref_data[:pfc] = Dict(x for x in ref_data[:pfc] if (x.second["pfc_status"] == 1 && x.second["terminal1_bus"] in keys(ref_data[:busdc]) && x.second["terminal2_bus"] in keys(ref_data[:busdc]) && x.second["terminal3_bus"] in keys(ref_data[:busdc])))

# ref_data[:arcs_from_12_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal2_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 2
# ref_data[:arcs_from_13_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal3_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 2 to 1
# ref_data[:arcs_to_12_pfc]   = [(i, pfc["terminal2_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 3
# ref_data[:arcs_to_13_pfc]   = [(i, pfc["terminal3_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 3 to 1
# ref_data[:arcs_pfc] = [ref_data[:arcs_from_12_pfc]; ref_data[:arcs_from_13_pfc]; ref_data[:arcs_to_12_pfc]; ref_data[:arcs_to_13_pfc]]

#         bus_arcs_pfc = Dict((i, []) for (i,busdc) in ref_data[:busdc])
#         for (l,i,j) in ref_data[:arcs_pfc]
#             push!(bus_arcs_pfc[i], (l,i,j))
#         end
#         ref_data[:bus_arcs_pfc] = bus_arcs_pfc



#        ## Variable testing 
# nw = 0
#         duty_cycle = _PM.var(pm, nw)[:duty_cycle] = JuMP.@variable(pm.model,
#         [i in _PM.ids(pm, nw, :pfc)], base_name="$(nw)_duty_cycle",
#         start = 0.5
#     )
# pfc_id = _PM.ids(pm,0, :pfc)

# pfc_current = _PM.var(pm, nw)[:pfc_current] = JuMP.@variable(pm.model,
#         [(l,i,j) in _PM.ref(pm, nw, :arcs_pfc)], base_name="$(nw)_pfc_current",
#         start = 0.5 # To avoid division by zero, maybe change later
#     )
#     _PM.ref(pm, 0, :pfc, 1)

#     pfc_current  = _PM.var(pm, 0, :pfc_current)

#     for a in bus_arcs_pfc
#         println(a)
#     end

#     JuMP.@constraint(pm.model, sum(pfc_current[a] for a in values(bus_arcs_pfc)) == 0)

#     bus_arcs_dcgrid = ref_data[:bus_arcs_dcgrid]

#     pfc = _PM.ref(pm, 0, :pfc, 1)

#     duty_cycle = _PM.var(pm, 0, :duty_cycle, 1)
#     c_voltage = _PM.var(pm, 0, :c_voltage, 1)
#     busdc_terminal_1 = _PM.var(pm, 0, :busdc, 1)
#     busdc_terminal_2 = _PM.var(pm, 0, :busdc, 2)

#     JuMP.@constraint(pm.model, duty_cycle >= 0)

#     arcs_pfc = _PM.ref(pm, 0, :arcs_pfc)
#     (l,i,j) = arcs_pfc

#     ipfc_dc = _PM.var(pm, 0, :pfc_current, arcs_pfc)

#     JuMP.@constraint(pm.model, duty_cycle - abs(ipfc_dc[1])/(abs(ipfc_dc[1]) + abs(ipfc_dc[2]) + 1e-6) == 0)

#     arcs_pfc
#     terminal_1 = pfc["terminal1_bus"]
#     terminal_2 = pfc["terminal2_bus"]
#     terminal_3 = pfc["terminal3_bus"]
#     i2 = ipfc_dc[(terminal_1,terminal_2,terminal_1)]
#     i3 = ipfc_dc[(terminal_1,terminal_3,terminal_1)]

#     JuMP.@constraint(pm.model, duty_cycle - abs(i3)/(abs(i3) + abs(i2) + 1e-6) == 0)


#     ## KCL constraint test
#     # Original
#     JuMP.@constraint(pm.model, sum(igrid_dc[a] for a in bus_arcs_dcgrid) + sum(iconv_dc[c] for c in bus_convs_dc) + sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0) # deal with pd

#     # New
#     JuMP.@constraint(pm.model, sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0) # deal with pd

#     ref_data[:branchdc] = Dict([x for x in ref_data[:branchdc] if (x.second["status"] == 1 && x.second["fbusdc"] in keys(ref_data[:busdc]) && x.second["tbusdc"] in keys(ref_data[:busdc]))])
#     # DC grid arcs for DC grid branches
#     ref_data[:arcs_dcgrid_from] = [(i,branch["fbusdc"],branch["tbusdc"]) for (i,branch) in ref_data[:branchdc]]
#     ref_data[:arcs_dcgrid_to]   = [(i,branch["tbusdc"],branch["fbusdc"]) for (i,branch) in ref_data[:branchdc]]
#     ref_data[:arcs_dcgrid] = [ref_data[:arcs_dcgrid_from]; ref_data[:arcs_dcgrid_to]]
#     #bus arcs of the DC grid
#     bus_arcs_dcgrid = Dict([(bus["busdc_i"], []) for (i,bus) in ref_data[:busdc]])
#     for (l,i,j) in ref_data[:arcs_dcgrid]
#         push!(bus_arcs_dcgrid[i], (l,i,j))
#     end
#     ref_data[:bus_arcs_dcgrid] = bus_arcs_dcgrid

#     ref_data[:convdc] = Dict([x for x in ref_data[:convdc] if (x.second["status"] == 1 && x.second["busdc_i"] in keys(ref_data[:busdc]) && x.second["busac_i"] in keys(ref_data[:bus]))])

#     ref_data[:arcs_conv_acdc] = [(i,conv["busac_i"],conv["busdc_i"]) for (i,conv) in ref_data[:convdc]]

#     # Bus converters for existing ac buses
#     bus_convs_dc = Dict([(bus["busdc_i"], []) for (i,bus) in ref_data[:busdc]])
#     ref_data[:bus_convs_dc]= assign_bus_converters!(ref_data[:convdc], bus_convs_dc, "busdc_i") 

#     igrid_dc = _PM.var(pm, nw)[:igrid_dc] = JuMP.@variable(pm.model,
#     [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_igrid_dc",
#     start = (_PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 0.0) / 1)
#     )

#     ### Test with branches and pfc
#     igrid_dc = _PM.var(pm, nw)[:igrid_dc] = JuMP.@variable(pm.model,
#     [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_igrid_dc",
#     start = (_PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 0.0) / 1)
#     )

#     igrid_dc_set = Dict(
#     1 => [],
#     2 => [(2, 2, 3), (1, 2, 4)],
#     3 => [(2, 3, 2), (3, 3, 5)],
#     4 => [(1, 4, 2)],
#     5 => [(3, 5, 3)]
# )

# pfc_current_set = Dict(
#     1 => [(1, 1, 4), (1, 1, 5)],
#     2 => [],
#     3 => [],
#     4 => [(1, 4, 1)],
#     5 => [(1, 5, 1)]
# )

#     JuMP.@constraint(pm.model, sum(igrid_dc[a] for a in igrid_dc_set) + sum(ipfc_dc[a] for a in pfc_current_set)== 0)

#     JuMP.@constraint(pm.model,sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0)
    
#     keys(igrid_dc)


#     ##### Testing function

#     data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

#     data["pfc"] = Dict( 1 => Dict(
#                                 "pfc_status" => 1,
#                                 "terminal1_bus"  => 1,
#                                 "terminal2_bus"  => 4,
#                                 "terminal3_bus"  => 5,
#                                 "c_voltage_min"  => -4/345,
#                                 "c_voltage_max"  =>  4/345,
#                                 "duty_cycle_min" => 0.01,
#                                 "duty_cycle_max" => 0.99,
#                                 "pfc_current_min" => -1.2,
#                                 "pfc_current_max" => 1.2
#                                     )
#                     )
#     _PMACDC.process_additional_data!(data)
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
#     s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
#     resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)