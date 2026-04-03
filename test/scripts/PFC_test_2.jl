using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5) # Changed tolerance to 1e-8 from 1e-6
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

# ## Test 3 bus UPC system
# data_no_pfc = _PM.parse_file("./test/data/PFC/case3_new.m")
# _PMACDC.process_additional_data!(data_no_pfc)
# result_no_pfc = _PMACDC.solve_acdcopf_iv(data_no_pfc, _PM.IVRPowerModel, ipopt; setting = s)

# data_pfc = _PM.parse_file("./test/data/PFC/case3_new_pfc.m")
# _PMACDC.process_additional_data!(data_pfc)
# result_pfc = _PMACDC.solve_acdcopf_iv(data_pfc, _PM.IVRPowerModel, ipopt; setting = s)

# # Print results for 3 bus system Objective values
# println("================================")
# println("3 Bus System Results Summary")
# println("================================")
# println("Case | Objective Function Value")
# println("----------------------------------")
# println("No PFC | $(result_no_pfc["objective"])")
# println("With PFC | $(result_pfc["objective"])")

# ## Test with Cigre Grid
# data_cigre = _PM.parse_file("./test/data/PFC/cigre_B4.m")


# ## Test 3 bus with reduced voltage

# data_no_pfc = _PM.parse_file("./test/data/PFC/case_3bus.m")
# _PMACDC.process_additional_data!(data_no_pfc)
# result_no_pfc = _PMACDC.solve_acdcopf_iv(data_no_pfc, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_no_pfc, data_no_pfc)
# check_duty_cycle(result_no_pfc, data_no_pfc)

# data_with_pfc = _PM.parse_file("./test/data/PFC/case_3bus_pfc.m")
# _PMACDC.process_additional_data!(data_with_pfc)
# result_with_pfc = _PMACDC.solve_acdcopf_iv(data_with_pfc, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_with_pfc, data_with_pfc)
# check_pfc_var(result_with_pfc, data_with_pfc)
# check_duty_cycle(result_with_pfc, data_with_pfc)

# #Collecting results for the table
# results = [
#     ("No PFC", result_no_pfc["objective"]),
#     ("With PFC", result_with_pfc["objective"]),
# ]

# # Printing the results in a table format
# println("================================")
# println("Latest Results Summary")
# println("================================")
# println("Case | Objective Function Value")
# println("----------------------------------")
# for (case, objective) in results
#     println("$case | $objective")
# end
# println("================================")

### 24-hour simulation

# ------------------------------
# 1) Example 24-hour load profile (active power multipliers)
#    You can set q_mult = nothing to scale Q with same m, or provide a vector.
# ------------------------------
# load_profile = [    
#     0.85, 0.82, 0.80, 0.80, 0.82, 0.86, 0.92, 0.98,
#     1.02, 1.05, 1.06, 1.05, 1.04, 1.02, 1.01, 1.03,
#     1.08, 1.12, 1.10, 1.04, 0.98, 0.93, 0.90, 0.88]
        
# q_profile = nothing  # or e.g., [ ... 24 values ... ]

# # Plotting the load profile
# plot(load_profile, title="24-hour Load Profile", xlabel="Hour", ylabel="Active Power Multiplier", legend=false)

# # Loading data
# data = _PM.parse_file("./test/data/PFC/case3_new.m")
# data= _PM.parse_file("./test/data/PFC/case_3bus.m")
# _PMACDC.process_additional_data!(data)

# # Vectors to store results
# time_steps = collect(1:length(load_profile))
# data_24h = Vector{Dict{String,Any}}(undef, length(time_steps))
# results_24h = Vector{Dict{String,Any}}(undef, length(time_steps))
# solution_status = Vector{Any}(undef, length(time_steps))

# #Scale the load
# scale_load!(data, data_24h, time_steps, load_profile)

# # Plotting the load for each time step in the 24-hour simulation
# load_values_1 = []
# load_values_2 = []

# for t in time_steps
#     data_t = data_24h[t]
#     load_t = data_t["load"]
#     push!(load_values_1, load_t["1"]["pd"])
#     push!(load_values_2, load_t["2"]["pd"])
# end

# plot(time_steps, load_values_1, label="Load 1", xlabel="Hour", ylabel="Active Power Demand (pu)", title="Load Demand over 24 Hours")
# plot!(time_steps, load_values_2, label="Load 2")

# # Running the 24-hour simulation
# for t in time_steps
#     # if t == 5
#     #     data_24h[t]["branchdc"]["1"]["rateA"] = 0.4  # Reduce rating of DC branch 1 at hour 5
#     # end
#     results_24h[t] = _PMACDC.solve_acdcopf_iv(data_24h[t], _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
#     solution_status[t] = results_24h[t]["termination_status"]
# end

# #Extract the objective values
# objective_values = [results_24h[t]["objective"] for t in time_steps]

# # Plotting the objective function values over 24 hours
# bar(time_steps, objective_values, xlabel="Hour", ylabel="Objective Function Value", title="Objective Function over 24 Hours", legend=false)

# # Plotting generator outputs
# gen_ids = collect(keys(results_24h[1]["solution"]["gen"]))
# gen_outputs_24h = [results_24h[t]["solution"]["gen"][gen_id]["pg"] for t in time_steps, gen_id in gen_ids]


# ##### Test with 5 BUS SYSTEM WITH PFC #####

# # No PFC
# data_no_pfc = _PM.parse_file("./test/data/PFC/case5_acdc.m")
# _PMACDC.process_additional_data!(data_no_pfc)
# result_no_pfc = _PMACDC.solve_acdcopf_iv(data_no_pfc, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_no_pfc, data_no_pfc)
# check_duty_cycle(result_no_pfc, data_no_pfc)

# # With PFC
# data_with_pfc = _PM.parse_file("./test/data/PFC/case5_acdc_pfc_B2.m")
# _PMACDC.process_additional_data!(data_with_pfc)
# result_with_pfc = _PMACDC.solve_acdcopf_iv(data_with_pfc, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_with_pfc, data_with_pfc)
# check_pfc_var(result_with_pfc, data_with_pfc)
# check_duty_cycle(result_with_pfc, data_with_pfc)

# # Added congestion in AC line no PFC
# data_no_pfc_cong1 = _PM.parse_file("./test/data/PFC/case5_acdc.m")
# _PMACDC.process_additional_data!(data_no_pfc_cong1)
# data_no_pfc_cong1["branch"]["1"]["rate_a"] = 0.5  # Reduce rating of AC branch 1
# result_no_pfc_cong1 = _PMACDC.solve_acdcopf_iv(data_no_pfc_cong1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_no_pfc_cong1, data_no_pfc_cong1)
# check_duty_cycle(result_no_pfc_cong1, data_no_pfc_cong1)

# # Added congestion in AC line with PFC
# data_with_pfc_cong1 = _PM.parse_file("./test/data/PFC/case5_acdc_pfc_B2.m")
# _PMACDC.process_additional_data!(data_with_pfc_cong1)
# data_with_pfc_cong1["branch"]["1"]["rate_a"] = 0.5  # Reduce rating of AC branch 1
# result_with_pfc_cong1 = _PMACDC.solve_acdcopf_iv(data_with_pfc_cong1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_with_pfc_cong1, data_with_pfc_cong1)
# check_pfc_var(result_with_pfc_cong1, data_with_pfc_cong1)
# check_duty_cycle(result_with_pfc_cong1, data_with_pfc_cong1)

# # Added congestion in DC line no PFC
# data_no_pfc_cong2 = _PM.parse_file("./test/data/PFC/case5_acdc.m")
# _PMACDC.process_additional_data!(data_no_pfc_cong2)
# data_no_pfc_cong2["branchdc"]["1"]["rateA"] = 0.3  # Reduce rating of DC branch 1
# result_no_pfc_cong2 = _PMACDC.solve_acdcopf_iv(data_no_pfc_cong2, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_no_pfc_cong2, data_no_pfc_cong2)
# check_duty_cycle(result_no_pfc_cong2, data_no_pfc_cong2)

# # Added congestion in DC line with PFC
# data_with_pfc_cong2 = _PM.parse_file("./test/data/PFC/case5_acdc_pfc_B2.m")
# _PMACDC.process_additional_data!(data_with_pfc_cong2)
# data_with_pfc_cong2["branchdc"]["1"]["rateA"] = 0.3  # Reduce rating of DC branch 1
# result_with_pfc_cong2 = _PMACDC.solve_acdcopf_iv(data_with_pfc_cong2, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_with_pfc_cong2, data_with_pfc_cong2)
# check_pfc_var(result_with_pfc_cong2, data_with_pfc_cong2)
# check_duty_cycle(result_with_pfc_cong2, data_with_pfc_cong2)

# # N-1 in the AC side
# data_no_pfc_cong3 = _PM.parse_file("./test/data/PFC/case5_acdc.m")
# _PMACDC.process_additional_data!(data_no_pfc_cong3)
# delete!(data_no_pfc_cong3["branch"], "1")  # Remove AC branch 2 to simulate N-1 contingency
# result_no_pfc_cong3 = _PMACDC.solve_acdcopf_iv(data_no_pfc_cong3, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_no_pfc_cong3, data_no_pfc_cong3)
# check_duty_cycle(result_no_pfc_cong3, data_no_pfc_cong3)

# # With PFC N-1 in the AC side
# data_with_pfc_cong3 = _PM.parse_file("./test/data/PFC/case5_acdc_pfc_B2.m")
# _PMACDC.process_additional_data!(data_with_pfc_cong3)
# delete!(data_with_pfc_cong3["branch"], "1")  # Remove AC branch 2 to simulate N-1 contingency
# result_with_pfc_cong3 = _PMACDC.solve_acdcopf_iv(data_with_pfc_cong3, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# check_power_flows(result_with_pfc_cong3, data_with_pfc_cong3)
# check_pfc_var(result_with_pfc_cong3, data_with_pfc_cong3)
# check_duty_cycle(result_with_pfc_cong3, data_with_pfc_cong3)


# # Collecting results for the table
# results = [
#     ("No PFC                     ", result_no_pfc["objective"]),
#     ("With PFC                   ", result_with_pfc["objective"]),
#     ("No PFC with AC Congestion  ", result_no_pfc_cong1["objective"]),
#     ("With PFC with AC Congestion", result_with_pfc_cong1["objective"]),
#     ("No PFC with DC Congestion  ", result_no_pfc_cong2["objective"]),
#     ("With PFC with DC Congestion", result_with_pfc_cong2["objective"]),
#     ("No PFC N-1 AC side         ", result_no_pfc_cong3["objective"]),
#     ("With PFC N-1 AC side       ", result_with_pfc_cong3["objective"]),
# ]

# # Printing the results in a table format
# println("================================")
# println("Latest Results Summary")
# println("================================")
# println("Case                        | Objective Function Value")
# println("--------------------------------------------------------")
# for (case, objective) in results
#     println("$case | $objective")
# end
# println("================================")

## 24 hour simulation for 5 bus system with and without PFC

# load_profile = [    
#     0.85, 0.82, 0.80, 0.80, 0.82, 0.86, 0.92, 0.98,
#     1.02, 1.05, 1.06, 1.05, 1.04, 1.02, 1.01, 1.03,
#     1.08, 1.12, 1.10, 1.04, 0.98, 0.93, 0.90, 0.88]

# # Vectors to store results
# time_steps = collect(1:length(load_profile))
# data_24h_no_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
# results_24h_no_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
# solution_status_no_pfc = Vector{Any}(undef, length(time_steps))   
# data_24h_with_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
# results_24h_with_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
# solution_status_with_pfc = Vector{Any}(undef, length(time_steps))

# # Loading data
# data_no_pfc = _PM.parse_file("./test/data/PFC/case5_acdc.m")
# data_with_pfc = _PM.parse_file("./test/data/PFC/case5_acdc_pfc_B2.m")

# #Processing additional data
# _PMACDC.process_additional_data!(data_no_pfc)
# _PMACDC.process_additional_data!(data_with_pfc)

# #Scale the load
# scale_load!(data_no_pfc, data_24h_no_pfc, time_steps, load_profile)
# scale_load!(data_with_pfc, data_24h_with_pfc, time_steps, load_profile)

# # Running the 24-hour simulation without PFC
# for t in time_steps
#     results_24h_no_pfc[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc[t], _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
#     solution_status_no_pfc[t] = results_24h_no_pfc[t]["termination_status"]
# end

# # Running the 24-hour simulation with PFC
# for t in time_steps
#     results_24h_with_pfc[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc[t], _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
#     solution_status_with_pfc[t] = results_24h_with_pfc[t]["termination_status"]
# end

# # Objective values extraction
# objective_values_no_pfc = [results_24h_no_pfc[t]["objective"] for t in time_steps]
# objective_values_with_pfc = [results_24h_with_pfc[t]["objective"] for t in time_steps]
# objective_diff = [objective_values_no_pfc[t] - objective_values_with_pfc[t] for t in time_steps]

# # Duty cycle value extraction for PFC
# duty_cycle_values = [results_24h_with_pfc[t]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps]

# #Compare objective values 
# println("================================")
# println("24-hour Simulation Results Summary")
# println("================================")
# println("Hour | Objective No PFC | Objective With PFC | Benefit")
# println("------------------------------------------------")
# for t in time_steps
#     benefit_indicator = objective_diff[t] >= 0 ? "✔" : "✖"
#     println(" $t  |     $(objective_values_no_pfc[t])     |      $(objective_values_with_pfc[t])    $benefit_indicator")
# end
# println("================================")

#### Test 67 bus system with and without PFC #####

# Base case 67 bus system no PFC
data_no_pfc_67bus = _PM.parse_file("./test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data_no_pfc_67bus)
# for (branchdc_id,branchdc) in data_no_pfc_67bus["branchdc"]
#     if branchdc_id != 11
#         data_no_pfc_67bus["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_no_pfc_67bus = _PMACDC.solve_acdcopf_iv(data_no_pfc_67bus, _PM.IVRPowerModel, ipopt; setting = s)

# DC_loading = Dict{String,Float64}()
# AC_loading = Dict{String,Float64}()

# DC_loading = get_DC_branch_loading_single_time_step(result_no_pfc_67bus, data_no_pfc_67bus, DC_loading)
# AC_loading = get_AC_branch_loading_single_time_step(result_no_pfc_67bus, data_no_pfc_67bus, AC_loading)



# println("67 Bus System without PFC: $(result_no_pfc_67bus["objective"])")
# check_power_flows(result_no_pfc_67bus, data_no_pfc_67bus)
# check_duty_cycle(result_no_pfc_67bus, data_no_pfc_67bus)

# Base case 67 bus system with PFC at B1
data_with_pfc_67busB1 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB1)
# for (branchdc_id,branchdc) in data_with_pfc_67busB1["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB1["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB1 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB1, _PM.IVRPowerModel, ipopt; setting = s)
# println("67 Bus System with PFC: $(result_with_pfc_67bus["objective"])")
# check_pfc_var(result_with_pfc_67bus, data_with_pfc_67bus)
# check_duty_cycle(result_with_pfc_67bus, data_with_pfc_67bus)
# check_power_flows(result_with_pfc_67bus, data_with_pfc_67bus)

# DC_loading = get_DC_branch_loading_single_time_step(result_with_pfc_67busB1, data_with_pfc_67busB1, DC_loading)
# AC_loading = get_AC_branch_loading_single_time_step(result_with_pfc_67busB1, data_with_pfc_67busB1, AC_loading)


data_with_pfc_67busB2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB2)
# for (branchdc_id,branchdc) in data_with_pfc_67busB2["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB2["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB2 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB2, _PM.IVRPowerModel, ipopt; setting = s)

DC_loading = get_DC_branch_loading_single_time_step(result_with_pfc_67busB2, data_with_pfc_67busB2, DC_loading)

data_with_pfc_67busB3 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB3)
# for (branchdc_id,branchdc) in data_with_pfc_67busB3["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB3["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB3 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB3, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67busB4 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB4)
# for (branchdc_id,branchdc) in data_with_pfc_67busB4["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB4["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB4 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB4, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67busB5 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB5)
# for (branchdc_id,branchdc) in data_with_pfc_67busB5["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB5["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB5 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB5, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67busB6 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB6)
# for (branchdc_id,branchdc) in data_with_pfc_67busB6["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB6["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB6 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB6, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67busB7 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB7)
# for (branchdc_id,branchdc) in data_with_pfc_67busB7["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB7["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB7 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB7, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67busB8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
_PMACDC.process_additional_data!(data_with_pfc_67busB8)
# for (branchdc_id,branchdc) in data_with_pfc_67busB8["branchdc"]
#     if branchdc_id != 11
#         data_with_pfc_67busB8["branchdc"][branchdc_id]["rateA"] *= 0.5
#     end
# end
result_with_pfc_67busB8 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67busB8, _PM.IVRPowerModel, ipopt; setting = s)

# Collecting results for the table
results_67bus = [
    ("No PFC                     ", result_no_pfc_67bus["objective"]),
    ("With PFC B1                ", result_with_pfc_67busB1["objective"]),
    ("With PFC B2                ", result_with_pfc_67busB2["objective"]),
    ("With PFC B3                ", result_with_pfc_67busB3["objective"]),
    ("With PFC B4                ", result_with_pfc_67busB4["objective"]),
    ("With PFC B5                ", result_with_pfc_67busB5["objective"]),
    ("With PFC B6                ", result_with_pfc_67busB6["objective"]),
    ("With PFC B7                ", result_with_pfc_67busB7["objective"]),
    ("With PFC B8                ", result_with_pfc_67busB8["objective"]),
]

# Printing the results in a table format
println("================================")
println("67 Bus System Results Summary")
println("================================")
println("Case                        | Objective Function Value | Higher than No PFC")
println("---------------------------------------------------------------")
for (case, objective) in results_67bus
    is_higher = objective > result_no_pfc_67bus["objective"] ? "✔" : "✖"
    println("$case | $objective | $is_higher")
end


percentage_savings = [
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB1["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB2["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB3["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB4["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB5["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB6["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB7["objective"]) / result_no_pfc_67bus["objective"] * 100,
    (result_no_pfc_67bus["objective"] - result_with_pfc_67busB8["objective"]) / result_no_pfc_67bus["objective"] * 100,
]

percentage_savings = round.(percentage_savings, digits=3)

scatter(1:8, percentage_savings, seriestype=:bar, markershape = :circle, color = :green, markersize = 5, xlabel="PFC Location", ylabel="Percentage Savings (%)", title="Percentage Savings with PFC for Different Locations", legend=false, xticks=1:8)
savefig("/Users/rgallo/Desktop/figures/pfc_savings_67bus_one_time.png")


# Plot duty cycles for each PFC placement
pfc_cases = [
    result_with_pfc_67busB1["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB2["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB3["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB4["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB5["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB6["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB7["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67busB8["solution"]["pfc"]["1"]["duty_cycle"],
]

scatter(1:8, pfc_cases, seriestype=:bar, markershape = :circle, color = :blue, markersize = 5, xlabel="PFC Location", ylabel="Duty Cycle", title="PFC Duty Cycle for Different Locations", legend=false, xticks=1:8, ylim=(0, 1))
savefig("/Users/rgallo/Desktop/figures/pfc_duty_cycle_67bus_one_time.png")

# Plot internal capacitor voltage for each PFC placement
pfc_voltage = [
    result_with_pfc_67busB1["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB2["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB3["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB4["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB5["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB6["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB7["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67busB8["solution"]["pfc"]["1"]["c_voltage"],
]

scatter(1:8, pfc_voltage, seriestype=:bar, markershape = :circle, color = :green, markersize = 5, xlabel="PFC Location", ylabel="Capacitor Voltage (pu)", title="PFC Capacitor Voltage for Different Locations", legend=false, xticks=1:8)

## N-1 contingencies in the AC and DC side
# DC side contingency: DC branch 3 outage
# No PFC case
data_no_pfc_67bus_dc_cong = _PM.parse_file("./test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data_no_pfc_67bus_dc_cong)
data_no_pfc_67bus_dc_cong["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_no_pfc_67bus_dc_cong = _PMACDC.solve_acdcopf_iv(data_no_pfc_67bus_dc_cong, _PM.IVRPowerModel, ipopt; setting = s)

# With PFC case
data_with_pfc_67bus_dc_cong_B1 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B1)
data_with_pfc_67bus_dc_cong_B1["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B1 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B1, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B2)
data_with_pfc_67bus_dc_cong_B2["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B2 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B2, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B3 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B3)
data_with_pfc_67bus_dc_cong_B3["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B3 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B3, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B4 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B4)
data_with_pfc_67bus_dc_cong_B4["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B4 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B4, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B5 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B5)
data_with_pfc_67bus_dc_cong_B5["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B5 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B5, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B6 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B6)
data_with_pfc_67bus_dc_cong_B6["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B6 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B6, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B7 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B7)
data_with_pfc_67bus_dc_cong_B7["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B7 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B7, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_dc_cong_B8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_dc_cong_B8)
data_with_pfc_67bus_dc_cong_B8["branchdc"]["3"]["status"] = 0  # Outage of DC branch 3
result_with_pfc_67bus_dc_cong_B8 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_dc_cong_B8, _PM.IVRPowerModel, ipopt; setting = s)

# Collecting results for the table
results_67bus = [
    ("No PFC                     ", result_no_pfc_67bus_dc_cong["objective"]),
    ("With PFC B1                ", result_with_pfc_67bus_dc_cong_B1["objective"]),
    ("With PFC B2                ", result_with_pfc_67bus_dc_cong_B2["objective"]),
    ("With PFC B3                ", result_with_pfc_67bus_dc_cong_B3["objective"]),
    ("With PFC B4                ", result_with_pfc_67bus_dc_cong_B4["objective"]),
    ("With PFC B5                ", result_with_pfc_67bus_dc_cong_B5["objective"]),
    ("With PFC B6                ", result_with_pfc_67bus_dc_cong_B6["objective"]),
    ("With PFC B7                ", result_with_pfc_67bus_dc_cong_B7["objective"]),
    ("With PFC B8                ", result_with_pfc_67bus_dc_cong_B8["objective"]),
]

percentage_savings = [
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B1["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B2["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B3["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B4["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B5["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B6["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B7["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
    (result_no_pfc_67bus_dc_cong["objective"] - result_with_pfc_67bus_dc_cong_B8["objective"]) / result_no_pfc_67bus_dc_cong["objective"] * 100,
]

percentage_savings = round.(percentage_savings, digits=3)

scatter(1:8, percentage_savings, seriestype=:bar, markershape = :circle, color = :green, markersize = 5, xlabel="PFC Location", ylabel="Percentage Savings (%)", title="Percentage Savings with PFC for Different Locations", legend=false, xticks=1:8)
savefig("/Users/rgallo/Desktop/figures/pfc_savings_67bus_one_time.png")


# Plot duty cycles for each PFC placement
pfc_cases = [
    result_with_pfc_67bus_dc_cong_B1["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B2["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B3["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B4["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B5["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B6["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B7["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_dc_cong_B8["solution"]["pfc"]["1"]["duty_cycle"],
]

scatter(1:8, pfc_cases, seriestype=:bar, markershape = :circle, color = :blue, markersize = 5, xlabel="PFC Location", ylabel="Duty Cycle", title="PFC Duty Cycle for Different Locations", legend=false, xticks=1:8, ylim=(0, 1))
savefig("/Users/rgallo/Desktop/figures/pfc_duty_cycle_67bus_one_time.png")

# Plot internal capacitor voltage for each PFC placement
pfc_voltage = [
    result_with_pfc_67bus_dc_cong_B1["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B2["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B3["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B4["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B5["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B6["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B7["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_dc_cong_B8["solution"]["pfc"]["1"]["c_voltage"],
]


# AC side contingency: AC branch 42 outage
# No PFC case
data_no_pfc_67bus_ac_cong = _PM.parse_file("./test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data_no_pfc_67bus_ac_cong)
data_no_pfc_67bus_ac_cong["branch"]["41"]["br_status"] = 0  # Outage of DC branch 3
result_no_pfc_67bus_ac_cong = _PMACDC.solve_acdcopf_iv(data_no_pfc_67bus_ac_cong, _PM.IVRPowerModel, ipopt; setting = s)
# With PFC case
data_with_pfc_67bus_ac_cong_B1 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B1)
data_with_pfc_67bus_ac_cong_B1["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B1 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B1, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B2)
data_with_pfc_67bus_ac_cong_B2["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B2 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B2, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B3 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B3)
data_with_pfc_67bus_ac_cong_B3["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B3 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B3, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B4 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B4)
data_with_pfc_67bus_ac_cong_B4["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B4 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B4, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B5 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B5)
data_with_pfc_67bus_ac_cong_B5["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B5 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B5, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B6 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B6)
data_with_pfc_67bus_ac_cong_B6["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B6 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B6, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B7 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B7)
data_with_pfc_67bus_ac_cong_B7["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B7 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B7, _PM.IVRPowerModel, ipopt; setting = s)

data_with_pfc_67bus_ac_cong_B8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
_PMACDC.process_additional_data!(data_with_pfc_67bus_ac_cong_B8)
data_with_pfc_67bus_ac_cong_B8["branch"]["41"]["br_status"] = 0  # Outage of AC branch 42
result_with_pfc_67bus_ac_cong_B8 = _PMACDC.solve_acdcopf_iv(data_with_pfc_67bus_ac_cong_B8, _PM.IVRPowerModel, ipopt; setting = s)

# Collecting results for the table
results_67bus = [
    ("No PFC                     ", result_no_pfc_67bus_ac_cong["objective"]),
    ("With PFC B1                ", result_with_pfc_67bus_ac_cong_B1["objective"]),
    ("With PFC B2                ", result_with_pfc_67bus_ac_cong_B2["objective"]),
    ("With PFC B3                ", result_with_pfc_67bus_ac_cong_B3["objective"]),
    ("With PFC B4                ", result_with_pfc_67bus_ac_cong_B4["objective"]),
    ("With PFC B5                ", result_with_pfc_67bus_ac_cong_B5["objective"]),
    ("With PFC B6                ", result_with_pfc_67bus_ac_cong_B6["objective"]),
    ("With PFC B7                ", result_with_pfc_67bus_ac_cong_B7["objective"]),
    ("With PFC B8                ", result_with_pfc_67bus_ac_cong_B8["objective"]),
]

percentage_savings = [
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B1["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B2["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B3["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B4["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B5["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B6["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B7["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
    (result_no_pfc_67bus_ac_cong["objective"] - result_with_pfc_67bus_ac_cong_B8["objective"]) / result_no_pfc_67bus_ac_cong["objective"] * 100,
]

percentage_savings = round.(percentage_savings, digits=3)

scatter(1:8, percentage_savings, seriestype=:bar, markershape = :circle, color = :green, markersize = 5, xlabel="PFC Location", ylabel="Percentage Savings (%)", title="Percentage Savings with PFC for Different Locations", legend=false, xticks=1:8)
savefig("/Users/rgallo/Desktop/figures/pfc_savings_67bus_one_time.png")


# Plot duty cycles for each PFC placement
pfc_cases = [
    result_with_pfc_67bus_ac_cong_B1["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B2["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B3["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B4["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B5["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B6["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B7["solution"]["pfc"]["1"]["duty_cycle"],
    result_with_pfc_67bus_ac_cong_B8["solution"]["pfc"]["1"]["duty_cycle"],
]
d_rounded = round.(pfc_cases, digits=2)
scatter(1:8, pfc_cases, seriestype=:bar, markershape = :circle, color = :blue, markersize = 5, xlabel="PFC Location", ylabel="Duty Cycle", title="PFC Duty Cycle for Different Locations", legend=false, xticks=1:8, ylim=(0, 1))
savefig("/Users/rgallo/Desktop/figures/pfc_duty_cycle_67bus_one_time.png")

# Plot internal capacitor voltage for each PFC placement
pfc_voltage = [
    result_with_pfc_67bus_ac_cong_B1["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B2["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B3["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B4["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B5["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B6["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B7["solution"]["pfc"]["1"]["c_voltage"],
    result_with_pfc_67bus_ac_cong_B8["solution"]["pfc"]["1"]["c_voltage"],
]

voltage_rounded = round.(pfc_voltage, digits=3)


### Update with a for loop that applied N-1 to all DC lines except line 11 and check whether the problem is locally solved or not TODO






# # Printing generator outputs in a table format
# println("================================")
# println("Generator Outputs")
# println("================================")
# println("Gen ID | Output (pg) NO PFC  |  Output (pg) WITH PFC")
# println("----------------------------------")
# gen_ids = sort(collect(keys(result_with_pfc_67bus["solution"]["gen"])), by=x->parse(Int, x))
# for gen_id in gen_ids
#     pg_no_pfc = result_no_pfc_67bus["solution"]["gen"][gen_id]["pg"]
#     pg_with_pfc = result_with_pfc_67bus["solution"]["gen"][gen_id]["pg"]
#     println(" $gen_id   |     $pg_no_pfc        |      $pg_with_pfc")
# end

# # Print DC Branch flows
# println("================================")
# println("DC Branch Flows")
# println("================================")
# println("Branch ID | Power From (pf) NO PFC | Power From (pf) WITH PFC")
# println("----------------------------------")
# dc_branch_ids = sort(collect(keys(result_with_pfc_67bus["solution"]["branchdc"])), by=x->parse(Int, x))
# for branchdc_id in dc_branch_ids
#     pf_no_pfc = result_no_pfc_67bus["solution"]["branchdc"][branchdc_id]["pf"]
#     pf_with_pfc = result_with_pfc_67bus["solution"]["branchdc"][branchdc_id]["pf"]
#     println("  $branchdc_id    |        $pf_no_pfc         |        $pf_with_pfc")
# end

# # Congestion in DC line no PFC
# data_no_pfc_cong_67bus = _PM.parse_file("./test/data/PFC/case67.m")
# _PMACDC.process_additional_data!(data_no_pfc_cong_67bus)
# data_no_pfc_cong_67bus["branchdc"]["7"]["rateA"] = 3  # Reduce rating of DC branch 1
# result_no_pfc_cong_67bus = _PMACDC.solve_acdcopf_iv(data_no_pfc_cong_67bus, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# println("67 Bus System without PFC with DC Congestion: $(result_no_pfc_cong_67bus["objective"])")
# check_duty_cycle(result_no_pfc_cong_67bus, data_no_pfc_cong_67bus)

# # Congestion in DC line with PFC at B8
# data_with_pfc_cong_67bus_B8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
# _PMACDC.process_additional_data!(data_with_pfc_cong_67bus_B8)
# data_with_pfc_cong_67bus_B8["branchdc"]["7"]["rateA"] = 3  # Reduce rating of DC branch 1
# result_with_pfc_cong_67bus_B8 = _PMACDC.solve_acdcopf_iv(data_with_pfc_cong_67bus_B8, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# println("67 Bus System with PFC at B8with DC Congestion: $(result_with_pfc_cong_67bus_B8["objective"])")
# check_duty_cycle(result_with_pfc_cong_67bus_B8, data_with_pfc_cong_67bus_B8)

# # Congestion in DC line with PFC at B2
# data_with_pfc_cong_67bus_B2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
# _PMACDC.process_additional_data!(data_with_pfc_cong_67bus_B2)
# data_with_pfc_cong_67bus_B2["branchdc"]["7"]["rateA"] = 3  # Reduce rating of DC branch 1
# result_with_pfc_cong_67bus_B2 = _PMACDC.solve_acdcopf_iv(data_with_pfc_cong_67bus_B2, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
# println("67 Bus System with PFC at B2 with DC Congestion: $(result_with_pfc_cong_67bus_B2["objective"])")
# check_duty_cycle(result_with_pfc_cong_67bus_B2, data_with_pfc_cong_67bus_B2)

# 24 hour simulation for 67 bus system with and without PFC

#Load profile
# load_profile = [    
#     0.85, 0.82, 0.80, 0.80, 0.82, 0.86, 0.92, 0.98,
#     1.02, 1.05, 1.06, 1.05, 1.04, 1.02, 1.01, 1.03,
#     1.08, 1.15, 1.10, 1.04, 0.98, 0.93, 0.90, 0.88]

# load_profile_scaled = [
#         1.0625, 1.0250, 1.0000, 1.0000, 1.0250, 1.0750, 1.1500, 1.2250,
#         1.2750, 1.3125, 1.3250, 1.3125, 1.3000, 1.2750, 1.2625, 1.2875,
#         1.3500, 1.4375, 1.3750, 1.3000, 1.2250, 1.1625, 1.1250, 1.1000
#     ]    

load_profile = [
    0.85, 0.83, 0.81, 0.82, 0.83, 0.88, 0.99, 1.09,
    1.12, 1.12, 1.12, 1.13, 1.12, 1.09, 1.07, 1.05,
    1.05, 1.09, 1.10, 1.08, 1.03, 0.97, 0.92, 0.86
    ]

# # Capacity factor for wind Generation

CF_ON = [
    0.72, 0.75, 0.78, 0.80, 0.82, 0.78,
    0.70, 0.60, 0.45, 0.35, 0.30, 0.28,
    0.30, 0.35, 0.40, 0.50, 0.60, 0.68,
    0.75, 0.80, 0.83, 0.85, 0.80, 0.75
]

CF_OFF = [
    0.55, 0.56, 0.58, 0.60, 0.62, 0.63,
    0.64, 0.63, 0.60, 0.58, 0.57, 0.56,
    0.57, 0.58, 0.60, 0.62, 0.65, 0.68,
    0.70, 0.72, 0.73, 0.72, 0.70, 0.65
]

# # # Plotting the load profile over 24 hours
# plot(time_steps_67bus, load_profile, xlabel="Hour", ylabel="Load Profile", title="Load Profile over 24 Hours", label="Origial Load Profile")
# plot!(time_steps_67bus, load_profile_scaled, label="Scaled Load Profile")

# Vectors to store results
time_steps_67bus = collect(1:length(load_profile))

data_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_no_pfc_67bus = Vector{Any}(undef, length(time_steps_67bus))

data_24h_with_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_with_pfc_67bus = Vector{Any}(undef, length(time_steps_67bus))

# Loading data
data_no_pfc_67bus = _PM.parse_file("./test/data/PFC/case67.m")
data_with_pfc_67bus = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")

# # Total Base load
# total_load_base_case = sum([load_data["pd"] for (load_id, load_data) in data_no_pfc_67bus["load"]])


#Processing additional data
_PMACDC.process_additional_data!(data_no_pfc_67bus)
_PMACDC.process_additional_data!(data_with_pfc_67bus)

# #Reduce all dc branches capacity by 50%
# for (branchdc_id, branchdc_data) in data_no_pfc_67bus["branchdc"]
#     if branchdc_id != "11"
#         branchdc_data["rateA"] *= 0.5
#     end
# end
# for (branchdc_id, branchdc_data) in data_with_pfc_67bus["branchdc"]
#     if branchdc_id != "11"
#         branchdc_data["rateA"] *= 0.5
#     end
# end

# # Derate AC lines that connect control areas
# for (branch_id, branch_data) in data_no_pfc_67bus["branch"]
#     if branch_data["index"] in [22,41,42,81]
#         branch_data["rate_a"] *= 0.7
#     end
# end
# for (branch_id, branch_data) in data_with_pfc_67bus["branch"]
#     if branch_data["index"] in [22,41,42,81]
#         branch_data["rate_a"] *= 0.7
#     end
# end

# Add ENS gens to both systems
# add_ens_gens!(data_no_pfc_67bus; VOLL = 100000)
# add_ens_gens!(data_with_pfc_67bus; VOLL = 100000)

#Scale the load
# scale_load!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)
scale_load!(data_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, load_profile)

# # Scale wind generation  ## Conflicting with scale load
# apply_cf_wind!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, CF_ON, CF_OFF)
# apply_cf_wind!(data_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, CF_ON, CF_OFF)

# Scale load and wind generation
# scale_load_wind!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load_wind!(data_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)

# Gen_20 = [data_24h_with_pfc_67bus[t]["gen"]["20"]["pmax"] for t in time_steps_67bus]
# Gen_2 = [data_24h_with_pfc_67bus[t]["gen"]["2"]["pmax"] for t in time_steps_67bus]
# Gen_4 = [data_24h_with_pfc_67bus[t]["gen"]["4"]["pmax"] for t in time_steps_67bus]

# Running the 24-hour simulation without PFC
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_no_pfc_67bus[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_no_pfc_67bus[t] = results_24h_no_pfc_67bus[t]["termination_status"]
end

# Running the 24-hour simulation with PFC
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_with_pfc_67bus[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_with_pfc_67bus[t] = results_24h_with_pfc_67bus[t]["termination_status"]
end

# Objective values extraction
objective_values_no_pfc_67bus = [results_24h_no_pfc_67bus[t]["objective"] for t in time_steps_67bus]
objective_values_with_pfc_67bus = [results_24h_with_pfc_67bus[t]["objective"] for t in time_steps_67bus]

diff = [objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus[t] for t in time_steps_67bus]
diff_perct = [diff[t] / objective_values_no_pfc_67bus[t] * 100 for t in time_steps_67bus]
sum_diff = sum(diff)
bar(time_steps_67bus, diff, xlabel="Hour", ylabel="Objective Function Difference [EUR]", title="Objective Difference over 24 Hours", legend=false)

# Prepare difference vector
difference_vector_67bus = Vector{Any}(undef, length(time_steps_67bus))

# Benefit calculation
benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus, difference_vector_67bus, time_steps_67bus)


# plot objective values over 24 hours side to side in bar plot
bar(time_steps_67bus .- 0.15, objective_values_no_pfc_67bus, width=0.3, label="No PFC", xlabel="Hour", ylabel="Objective Function Value", title="Objective Function over 24 Hours", legend=:topright, ylim=(0, maximum(objective_values_no_pfc_67bus) * 1.1))
bar!(time_steps_67bus .+ 0.15, objective_values_with_pfc_67bus, width=0.3, label="With PFC")

p_curt_20 = [data_24h_no_pfc_67bus[t]["gen"]["20"]["pmax"] - results_24h_with_pfc_67bus[t]["solution"]["gen"]["20"]["pg"] for t in time_steps_67bus]

p_avail_20 = [data_24h_no_pfc_67bus[t]["gen"]["20"]["pmax"] for t in time_steps_67bus]
p_disp_20 = [results_24h_with_pfc_67bus[t]["solution"]["gen"]["20"]["pg"] for t in time_steps_67bus]

# Calculate change of DC branches loading

DC_branch_loading_no_pfc = get_DC_branch_loading(results_24h_no_pfc_67bus, data_24h_no_pfc_67bus,time_steps_67bus)
DC_branch_loading_with_pfc = get_DC_branch_loading(results_24h_with_pfc_67bus, data_24h_with_pfc_67bus,time_steps_67bus)
DC_branch_loading_change_67bus = DC_branch_loading_with_pfc - DC_branch_loading_no_pfc

heatmap(DC_branch_loading_change_67bus', xlabel="Hour", ylabel="DC Branch ID", title="DC Branch Loading Change (With PFC - No PFC)", colorbar_title="Change in Loading (pu)", color=:jet, yticks=1:11)
savefig("/Users/rgallo/Desktop/figures/dc_branch_loading_change_67bus.png")

# Calculate AC and DC line congestions

# No PFC
AC_congestion_no_pfc = Vector{Any}(undef, length(time_steps_67bus))
DC_congestion_no_pfc = Vector{Any}(undef, length(time_steps_67bus))
compute_AC_branch_loading_24h(results_24h_no_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, AC_congestion_no_pfc)
compute_DC_branch_loading_24h(results_24h_no_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, DC_congestion_no_pfc)

# With PFC
AC_congestion_with_pfc = Vector{Any}(undef, length(time_steps_67bus))
DC_congestion_with_pfc = Vector{Any}(undef, length(time_steps_67bus))
compute_AC_branch_loading_24h(results_24h_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, AC_congestion_with_pfc)
compute_DC_branch_loading_24h(results_24h_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, DC_congestion_with_pfc)


# Print duty cycle values over 24 hours
duty_cycle_values_67bus = [results_24h_with_pfc_67bus[t]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps_67bus]

# plot duty cycle over 24 hours
plot(time_steps_67bus, duty_cycle_values_67bus, xlabel="Hour", ylabel="Duty Cycle", title="PFC Duty Cycle over 24 Hours", legend=false)
path = "/Users/rgallo/Desktop/"
savefig(joinpath(path, "duty_cycle_67bus_3.png"))

# Total Load per hour and daily
load_24h = Vector{Any}(undef, length(time_steps_67bus))
compute_hourly_load(data_24h_with_pfc_67bus,time_steps_67bus,load_24h)

# Collecting generator outputs into a matrix

# No PFC
gen_outputs_matrix_no_pfc_67bus = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_no_pfc_67bus, time_steps_67bus, gen_outputs_matrix_no_pfc_67bus)

# With PFC
gen_outputs_matrix_with_pfc_67bus = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_with_pfc_67bus, time_steps_67bus, gen_outputs_matrix_with_pfc_67bus)

# Compute differences in generator outputs between no PFC and with PFC
gen_output_differences_67bus = gen_outputs_matrix_with_pfc_67bus - gen_outputs_matrix_no_pfc_67bus
# Counts of increases and decreases in generation per hour
up_gen_hourly_count = vec(sum(gen_output_differences_67bus .> 0, dims=2))
down_gen_hourly_count = vec(sum(gen_output_differences_67bus .< 0, dims=2))
# Amount of change in generation per hour
up_gen_hourly = vec(sum(max.(gen_output_differences_67bus, 0.0), dims=2))
down_gen_hourly = vec(sum(min.(gen_output_differences_67bus, 0.0), dims=2))
#Total change in generation over 24 hours
up_gen_daily = sum(up_gen_hourly)
down_gen_daily = sum(down_gen_hourly)

# Amount of change in generation per Gen
up_gen = vec(sum(max.(gen_output_differences_67bus, 0.0), dims=1))
down_gen = vec(sum(min.(gen_output_differences_67bus, 0.0), dims=1))

#Plot of results
delta_P_pos = max.(gen_output_differences_67bus, 0.0)
delta_P_neg = min.(gen_output_differences_67bus, 0.0)
# Sum across generators
delta_P_pos_sum = vec(sum(delta_P_pos, dims=2))
delta_P_neg_sum = vec(sum(delta_P_neg, dims=2))

bar(time_steps_67bus, [delta_P_pos_sum delta_P_neg_sum], xlabel="Hour", ylabel="Change in Generation (pu)", title="Change in Generation over 24 Hours", label=["Increase in Generation" "Decrease in Generation"], legend=:topright, xticks=1:24)
savefig("/Users/rgallo/Desktop/figures/change_in_generation_67bus.png")

# Sum across hours for each generator
delta_P_pos_gen = vec(sum(delta_P_pos, dims=1))
delta_P_neg_gen = vec(sum(delta_P_neg, dims=1))

bar(1:20, [delta_P_pos_gen delta_P_neg_gen], xlabel="Generator ID", ylabel="Total Change in Generation (pu)", title="Total Change in Generation per Generator over 24 Hours", label=["Total Increase" "Total Decrease"], legend=:topright, xticks=1:20)
savefig("/Users/rgallo/Desktop/figures/total_change_in_generation_per_generator_67bus.png")

#Heatmap of generation differences
heatmap(gen_output_differences_67bus', xlabel="Hour", ylabel="Generator ID", title="Generation Output Differences (With PFC - No PFC)", colorbar_title="Difference (pu)",color=:jet, yticks=1:20)
savefig("/Users/rgallo/Desktop/figures/gen_output_differences_67bus.png")

# Total absolute change in generation over 24 hours
gen_output_abs = abs.(gen_output_differences_67bus)
gen_output_diff_hourly = vec(sum(gen_output_abs, dims=2))
total_gen_output_diff = sum(gen_output_diff_hourly)

# Compare hourly load with Generation
gen_24h_no_pfc = vec(sum(gen_outputs_matrix_no_pfc_67bus, dims=2))
gen_24h_with_pfc = vec(sum(gen_outputs_matrix_with_pfc_67bus, dims=2))

# Gen-Load Balance 24h
losses_24h_no_pfc = gen_24h_no_pfc - load_24h
losses_24h_with_pfc = gen_24h_with_pfc - load_24h
losses_diff = losses_24h_no_pfc - losses_24h_with_pfc

# Losses calculation
total_losses_no_pfc = sum(losses_24h_no_pfc)
total_losses_with_pfc = sum(losses_24h_with_pfc)
total_losses_diff = total_losses_no_pfc - total_losses_with_pfc

## Same calculation but for N-1 contingencies
# Critical AC lines for N-1 -> 22,41,42,81
# Critical DC lines for N-1 -> 1

data_24h_no_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_no_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_no_pfc_67bus_N1 = Vector{Any}(undef, length(time_steps_67bus))

data_24h_with_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_with_pfc_67bus_N1 = Vector{Any}(undef, length(time_steps_67bus))

# Loading data
data_no_pfc_67bus_N1 = _PM.parse_file("./test/data/PFC/case67.m")
data_with_pfc_67bus_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")

#Processing additional data
_PMACDC.process_additional_data!(data_no_pfc_67bus_N1)
_PMACDC.process_additional_data!(data_with_pfc_67bus_N1)

#Scale the load
scale_load!(data_no_pfc_67bus_N1, data_24h_no_pfc_67bus_N1, time_steps_67bus, load_profile)
scale_load!(data_with_pfc_67bus_N1, data_24h_with_pfc_67bus_N1, time_steps_67bus, load_profile)

#N-1 Contingency application
for t in time_steps_67bus
    for (branch_id, branch_data) in data_24h_no_pfc_67bus_N1[t]["branch"]
        if branch_data["index"] == 42
            branch_data["br_status"] = 0
        end
    end
    for (branch_id, branch_data) in data_24h_with_pfc_67bus_N1[t]["branch"]
        if branch_data["index"] == 42
            branch_data["br_status"] = 0
        end
    end
    # # Remove critical DC line
    # for (branchdc_id, branchdc_data) in data_24h_no_pfc_67bus_N1[t]["branchdc"]
    #     if branchdc_data["index"] == 1
    #         branchdc_data["status"] = 0
    #     end
    # end
    # for (branchdc_id, branchdc_data) in data_24h_with_pfc_67bus_N1[t]["branchdc"]
    #     if branchdc_data["index"] == 1
    #         branchdc_data["status"] = 0
    #     end
    # end
end

# Running the 24-hour simulation without PFC for N-1
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_no_pfc_67bus_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_no_pfc_67bus_N1[t] = results_24h_no_pfc_67bus_N1[t]["termination_status"]
end
# Running the 24-hour simulation with PFC for N-1
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_with_pfc_67bus_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_with_pfc_67bus_N1[t] = results_24h_with_pfc_67bus_N1[t]["termination_status"]
end

# Objective values extraction
objective_values_no_pfc_67bus_N1 = [results_24h_no_pfc_67bus_N1[t]["objective"] for t in time_steps_67bus]
objective_values_with_pfc_67bus_N1 = [results_24h_with_pfc_67bus_N1[t]["objective"] for t in time_steps_67bus]

diff = [objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_N1[t] for t in time_steps_67bus]
diff_perct = [diff[t] / objective_values_no_pfc_67bus_N1[t] * 100 for t in time_steps_67bus]
sum_diff = sum(diff)
bar(time_steps_67bus, diff, xlabel="Hour", ylabel="Objective Function Difference [EUR]", title="Objective Difference over 24 Hours", legend=false)

# Prepare difference vector
difference_vector_67bus_N1 = Vector{Any}(undef, length(time_steps_67bus))

# Benefit calculation
benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_N1, difference_vector_67bus_N1, time_steps_67bus)

#AC line congestion calculation for N-1
AC_congestion_no_pfc_N1 = Vector{Any}(undef, length(time_steps_67bus))
DC_congestion_no_pfc_N1 = Vector{Any}(undef, length(time_steps_67bus))
compute_AC_branch_loading_24h(results_24h_no_pfc_67bus_N1, data_24h_with_pfc_67bus_N1, time_steps_67bus, AC_congestion_no_pfc_N1)
compute_DC_branch_loading_24h(results_24h_no_pfc_67bus_N1, data_24h_with_pfc_67bus_N1, time_steps_67bus, DC_congestion_no_pfc_N1)

AC_congestion_with_pfc_N1 = Vector{Any}(undef, length(time_steps_67bus))
DC_congestion_with_pfc_N1 = Vector{Any}(undef, length(time_steps_67bus))
compute_AC_branch_loading_24h(results_24h_with_pfc_67bus_N1, data_24h_with_pfc_67bus_N1, time_steps_67bus, AC_congestion_with_pfc_N1)
compute_DC_branch_loading_24h(results_24h_with_pfc_67bus_N1, data_24h_with_pfc_67bus_N1, time_steps_67bus, DC_congestion_with_pfc_N1)

# Get DC loading change for N-1
DC_branch_loading_no_pfc_N1 = get_DC_branch_loading(results_24h_no_pfc_67bus_N1, data_24h_no_pfc_67bus_N1,time_steps_67bus)
DC_branch_loading_with_pfc_N1 = get_DC_branch_loading(results_24h_with_pfc_67bus_N1, data_24h_with_pfc_67bus_N1,time_steps_67bus)
DC_branch_loading_change_67bus_N1 = DC_branch_loading_with_pfc_N1 - DC_branch_loading_no_pfc_N1

heatmap(DC_branch_loading_change_67bus_N1', xlabel="Hour", ylabel="DC Branch ID", title="DC Branch Loading Change N-1 (With PFC - No PFC)", colorbar_title="Change in Loading (pu)", color=:jet, yticks=1:11)
savefig("/Users/rgallo/Desktop/figures/dc_branch_loading_change_67bus_N1.png")

# # Collecting generator outputs into a matrix for plotting

# No PFC
gen_outputs_matrix_no_pfc_67bus_N1 = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_no_pfc_67bus_N1, time_steps_67bus, gen_outputs_matrix_no_pfc_67bus_N1)

# With PFC
gen_outputs_matrix_with_pfc_67bus_N1 = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_with_pfc_67bus_N1, time_steps_67bus, gen_outputs_matrix_with_pfc_67bus_N1)


# Compute differences in generator outputs between no PFC and with PFC
gen_output_differences_67bus_N1 = gen_outputs_matrix_with_pfc_67bus_N1 - gen_outputs_matrix_no_pfc_67bus_N1
# Counts of increases and decreases in generation per hour
up_gen_hourly_count_N1 = vec(sum(gen_output_differences_67bus_N1 .> 0, dims=2))
down_gen_hourly_count_N1 = vec(sum(gen_output_differences_67bus_N1 .< 0, dims=2))
# Amount of change in generation per hour
up_gen_hourly_N1 = vec(sum(max.(gen_output_differences_67bus_N1, 0.0), dims=2))
down_gen_hourly_N1 = vec(sum(min.(gen_output_differences_67bus_N1, 0.0), dims=2))
#Total change in generation over 24 hours
up_gen_daily_N1 = sum(up_gen_hourly_N1)
down_gen_daily_N1 = sum(down_gen_hourly_N1)

# Amount of change in generation per Gen
up_gen_N1 = vec(sum(max.(gen_output_differences_67bus_N1, 0.0), dims=1))
down_gen_N1 = vec(sum(min.(gen_output_differences_67bus_N1, 0.0), dims=1))

#Plot of results
delta_P_pos_N1 = max.(gen_output_differences_67bus_N1, 0.0)
delta_P_neg_N1 = min.(gen_output_differences_67bus_N1, 0.0)
# Sum across generators
delta_P_pos_sum_N1 = vec(sum(delta_P_pos_N1, dims=2))
delta_P_neg_sum_N1 = vec(sum(delta_P_neg_N1, dims=2))

bar(time_steps_67bus, [delta_P_pos_sum_N1 delta_P_neg_sum_N1], xlabel="Hour", ylabel="Change in Generation (pu)", title="Change in Generation over 24 Hours", label=["Increase in Generation" "Decrease in Generation"], legend=:topright, xticks=1:24)
savefig("/Users/rgallo/Desktop/figures/change_in_generation_67bus_N1.png")

# Sum across hours for each generator
delta_P_pos_gen_N1 = vec(sum(delta_P_pos_N1, dims=1))
delta_P_neg_gen_N1 = vec(sum(delta_P_neg_N1, dims=1))

bar(1:20, [delta_P_pos_gen_N1 delta_P_neg_gen_N1], xlabel="Generator ID", ylabel="Total Change in Generation (pu)", title="Total Change in Generation per Generator over 24 Hours", label=["Total Increase" "Total Decrease"], legend=:topright, xticks=1:20)
savefig("/Users/rgallo/Desktop/figures/total_change_in_generation_per_generator_67bus_N1.png")

#Heatmap of generation differences
heatmap(gen_output_differences_67bus_N1', xlabel="Hour", ylabel="Generator ID", title="Generation Output Differences (With PFC - No PFC)", colorbar_title="Difference (pu)",color=:jet, yticks=1:20)
savefig("/Users/rgallo/Desktop/figures/gen_output_differences_67bus_N1.png")

# Total absolute change in generation over 24 hours
gen_output_abs_N1 = abs.(gen_output_differences_67bus_N1)
gen_output_diff_hourly_N1 = vec(sum(gen_output_abs_N1, dims=2))
total_gen_output_diff_N1 = sum(gen_output_diff_hourly_N1)

# Compare hourly load with Generation
gen_24h_no_pfc_N1 = vec(sum(gen_outputs_matrix_no_pfc_67bus_N1, dims=2))
gen_24h_with_pfc_N1 = vec(sum(gen_outputs_matrix_with_pfc_67bus_N1, dims=2))

# Gen-Load Balance 24h
losses_24h_no_pfc_N1 = gen_24h_no_pfc_N1 - load_24h
losses_24h_with_pfc_N1 = gen_24h_with_pfc_N1 - load_24h
losses_diff_N1 = losses_24h_no_pfc_N1 - losses_24h_with_pfc_N1

# Losses calculation
total_losses_no_pfc_N1 = sum(losses_24h_no_pfc_N1)
total_losses_with_pfc_N1 = sum(losses_24h_with_pfc_N1)
total_losses_diff_N1 = total_losses_no_pfc_N1 - total_losses_with_pfc_N1


## N-1 DC branch

data_24h_no_pfc_67bus_N1_DC = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_no_pfc_67bus_N1_DC = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_no_pfc_67bus_N1_DC = Vector{Any}(undef, length(time_steps_67bus))

data_24h_with_pfc_67bus_N1_DC = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_N1_DC = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_with_pfc_67bus_N1_DC = Vector{Any}(undef, length(time_steps_67bus))

# Loading data
data_no_pfc_67bus_N1_DC = _PM.parse_file("./test/data/PFC/case67.m")
data_with_pfc_67bus_N1_DC = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")

#Processing additional data
_PMACDC.process_additional_data!(data_no_pfc_67bus_N1_DC)
_PMACDC.process_additional_data!(data_with_pfc_67bus_N1_DC)

#Scale the load
scale_load!(data_no_pfc_67bus_N1_DC, data_24h_no_pfc_67bus_N1_DC, time_steps_67bus, load_profile)
scale_load!(data_with_pfc_67bus_N1_DC, data_24h_with_pfc_67bus_N1_DC, time_steps_67bus, load_profile)

#N-1 Contingency application - Remove critical DC line
for t in time_steps_67bus
    # Remove critical DC line
    for (branchdc_id, branchdc_data) in data_24h_no_pfc_67bus_N1_DC[t]["branchdc"]
        if branchdc_data["index"] == 3
            branchdc_data["status"] = 0
        end
    end
    for (branchdc_id, branchdc_data) in data_24h_with_pfc_67bus_N1_DC[t]["branchdc"]
        if branchdc_data["index"] == 3
            branchdc_data["status"] = 0
        end
    end
end

# # Running the 24-hour simulation without PFC for N-1 DC
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_no_pfc_67bus_N1_DC[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus_N1_DC[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_no_pfc_67bus_N1_DC[t] = results_24h_no_pfc_67bus_N1_DC[t]["termination_status"]
end

# # Running the 24-hour simulation with PFC for N-1 DC
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_with_pfc_67bus_N1_DC[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_N1_DC[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_with_pfc_67bus_N1_DC[t] = results_24h_with_pfc_67bus_N1_DC[t]["termination_status"]
end

# # Objective values extraction
objective_values_no_pfc_67bus_N1_DC = [results_24h_no_pfc_67bus_N1_DC[t]["objective"] for t in time_steps_67bus]
objective_values_with_pfc_67bus_N1_DC = [results_24h_with_pfc_67bus_N1_DC[t]["objective"] for t in time_steps_67bus]

diff = [objective_values_no_pfc_67bus_N1_DC[t] - objective_values_with_pfc_67bus_N1_DC[t] for t in time_steps_67bus]
diff_perct = [diff[t] / objective_values_no_pfc_67bus_N1_DC[t] * 100 for t in time_steps_67bus]
sum_diff = sum(diff)
bar(time_steps_67bus, diff, xlabel="Hour", ylabel="Objective Function Difference [EUR]", title="Objective Difference over 24 Hours", legend=false)

# # Prepare difference vector
difference_vector_67bus_N1_DC = Vector{Any}(undef, length(time_steps_67bus))
# # Benefit calculation
benefit_calculation(objective_values_no_pfc_67bus_N1_DC, objective_values_with_pfc_67bus_N1_DC, difference_vector_67bus_N1_DC, time_steps_67bus)

#DC branches loading
DC_branch_loading_no_pfc_N1_DC = get_DC_branch_loading(results_24h_no_pfc_67bus_N1_DC, data_24h_no_pfc_67bus_N1_DC,time_steps_67bus)
DC_branch_loading_with_pfc_N1_DC = get_DC_branch_loading(results_24h_with_pfc_67bus_N1_DC, data_24h_with_pfc_67bus_N1_DC,time_steps_67bus)
DC_branch_loading_change_67bus_N1_DC = DC_branch_loading_with_pfc_N1_DC - DC_branch_loading_no_pfc_N1_DC

heatmap(DC_branch_loading_change_67bus_N1_DC', xlabel="Hour", ylabel="DC Branch ID", title="DC Branch Loading Change N-1 DC (With PFC - No PFC)", colorbar_title="Change in Loading (pu)", color=:jet, yticks=1:11)
savefig("/Users/rgallo/Desktop/figures/dc_branch_loading_change_67bus_N1_DC.png")

#Generation matrix for N-1 DC
gen_outputs_matrix_no_pfc_67bus_N1_DC = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_no_pfc_67bus_N1_DC, time_steps_67bus, gen_outputs_matrix_no_pfc_67bus_N1_DC)
gen_outputs_matrix_with_pfc_67bus_N1_DC = zeros(Float64, length(time_steps_67bus), 20)
compute_generation_matrix!(results_24h_with_pfc_67bus_N1_DC, time_steps_67bus, gen_outputs_matrix_with_pfc_67bus_N1_DC)

# # Compute differences in generator outputs between no PFC and with PFC
gen_output_differences_67bus_N1_DC = gen_outputs_matrix_with_pfc_67bus_N1_DC - gen_outputs_matrix_no_pfc_67bus_N1_DC
# # Counts of increases and decreases in generation per hour
up_gen_hourly_count_N1_DC = vec(sum(gen_output_differences_67bus_N1_DC .> 0, dims=2))
down_gen_hourly_count_N1_DC = vec(sum(gen_output_differences_67bus_N1_DC .< 0, dims=2))
# # Amount of change in generation per hour
up_gen_hourly_N1_DC = vec(sum(max.(gen_output_differences_67bus_N1_DC, 0.0), dims=2))
down_gen_hourly_N1_DC = vec(sum(min.(gen_output_differences_67bus_N1_DC, 0.0), dims=2))
# #Total change in generation over 24 hours
up_gen_daily_N1_DC = sum(up_gen_hourly_N1_DC)
down_gen_daily_N1_DC = sum(down_gen_hourly_N1_DC)

# # Amount of change in generation per Gen
up_gen_N1_DC = vec(sum(max.(gen_output_differences_67bus_N1_DC, 0.0), dims=1))
down_gen_N1_DC = vec(sum(min.(gen_output_differences_67bus_N1_DC, 0.0), dims=1))

#Plot results
delta_P_pos_N1_DC = max.(gen_output_differences_67bus_N1_DC, 0.0)
delta_P_neg_N1_DC = min.(gen_output_differences_67bus_N1_DC, 0.0)

# # Sum across generators
delta_P_pos_sum_N1_DC = vec(sum(delta_P_pos_N1_DC, dims=2))
delta_P_neg_sum_N1_DC = vec(sum(delta_P_neg_N1_DC, dims=2))

bar(time_steps_67bus, [delta_P_pos_sum_N1_DC delta_P_neg_sum_N1_DC], xlabel="Hour", ylabel="Change in Generation (pu)", title="Change in Generation over 24 Hours", label=["Increase in Generation" "Decrease in Generation"], legend=:topright, xticks=1:24)
savefig("/Users/rgallo/Desktop/figures/change_in_generation_67bus_N1_DC.png")

# # Sum across hours for each generator
delta_P_pos_gen_N1_DC = vec(sum(delta_P_pos_N1_DC, dims=1))
delta_P_neg_gen_N1_DC = vec(sum(delta_P_neg_N1_DC, dims=1))

bar(1:20, [delta_P_pos_gen_N1_DC delta_P_neg_gen_N1_DC], xlabel="Generator ID", ylabel="Total Change in Generation (pu)", title="Total Change in Generation per Generator over 24 Hours", label=["Total Increase" "Total Decrease"], legend=:topright, xticks=1:20)
savefig("/Users/rgallo/Desktop/figures/total_change_in_generation_per_generator_67bus_N1_DC.png")

#Heatmap of generation differences
heatmap(gen_output_differences_67bus_N1_DC', xlabel="Hour", ylabel="Generator ID", title="Generation Output Differences (With PFC - No PFC)", colorbar_title="Difference (pu)",color=:jet, yticks=1:20)
savefig("/Users/rgallo/Desktop/figures/gen_output_differences_67bus_N1_DC.png")

# #Plot difference in gen-load balance over 24 hours
# plot(time_steps_67bus, diff, xlabel="Hour", ylabel="Gen-Load Balance Difference (pu)", title="Generation-Load Balance Difference over 24 Hours", legend=false)



# #plot gen 1 - 15 output over 24 hours

# plot(time_steps_67bus, gen1_outputs_67bus, label="Gen 1", xlabel="Hour", ylabel="Active Power Generation (pu)", title="Generator Outputs over 24 Hours")
# plot!(time_steps_67bus, gen2_outputs_67bus, label="Gen 2")
# plot!(time_steps_67bus, gen3_outputs_67bus, label="Gen 3")
# plot!(time_steps_67bus, gen4_outputs_67bus, label="Gen 4")
# plot!(time_steps_67bus, gen5_outputs_67bus, label="Gen 5")
# plot!(time_steps_67bus, gen6_outputs_67bus, label="Gen 6")
# plot!(time_steps_67bus, gen7_outputs_67bus, label="Gen 7")
# plot!(time_steps_67bus, gen8_outputs_67bus, label="Gen 8")
# plot!(time_steps_67bus, gen9_outputs_67bus, label="Gen 9")
# plot!(time_steps_67bus, gen10_outputs_67bus, label="Gen 10")
# plot!(time_steps_67bus, gen11_outputs_67bus, label="Gen 11")
# plot!(time_steps_67bus, gen12_outputs_67bus, label="Gen 12")
# plot!(time_steps_67bus, gen13_outputs_67bus, label="Gen 13")
# plot!(time_steps_67bus, gen14_outputs_67bus, label="Gen 14")
# plot!(time_steps_67bus, gen15_outputs_67bus, label="Gen 15")

# savefig(joinpath(path, "gen_outputs_67bus.png"))

# # Collecting ENS outputs into a matrix
# ens_outputs_matrix_67bus = zeros(Float64, length(time_steps_67bus), 6)
# ens1_outputs_67bus = ens_outputs_matrix_67bus[:, 1] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["21"]["pg"] for t in time_steps_67bus]
# ens2_outputs_67bus = ens_outputs_matrix_67bus[:, 2] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["22"]["pg"] for t in time_steps_67bus]
# ens_outputs_matrix_67bus[:, 3] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["23"]["pg"] for t in time_steps_67bus]
# ens_outputs_matrix_67bus[:, 4] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["24"]["pg"] for t in time_steps_67bus]
# ens_outputs_matrix_67bus[:, 5] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["25"]["pg"] for t in time_steps_67bus]
# ens_outputs_matrix_67bus[:, 6] =  [results_24h_with_pfc_67bus[t]["solution"]["gen"]["26"]["pg"] for t in time_steps_67bus]

# #Plot ENS outputs over 24 hours
# plot(time_steps_67bus, ens1_outputs_67bus, label="ENS 1", xlabel="Hour", ylabel="ENS Generation (pu)", title="Emergency Not Supply (ENS) Outputs over 24 Hours")
# plot!(time_steps_67bus, ens2_outputs_67bus, label="ENS 2")
# plot!(time_steps_67bus, ens3_outputs_67bus, label="ENS 3")
# plot!(time_steps_67bus, ens4_outputs_67bus, label="ENS 4")
# plot!(time_steps_67bus, ens5_outputs_67bus, label="ENS 5")
# plot!(time_steps_67bus, ens6_outputs_67bus, label="ENS 6")

# ## Debugging Iteration limit cases with derate to 70% for time steps 8 and 21
# load_profile[8] #Load multiplier 0.98
# load_profile[21]

# #New data
# data_no_pfc = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
# _PMACDC.process_additional_data!(data_no_pfc)

# for (load_id,load) in data_no_pfc["load"]
#     # load["pd"] *= 0.98
#     # load["qd"] *= 0.98
#     load["pd"] *= 1.08
#     load["qd"] *= 1.08
#     # load["flex"] = 1
# end

# result = _PMACDC.solve_acdcopf_iv(data_no_pfc, _PM.IVRPowerModel, ipopt; setting = s)
# result_no_pfc_67bus_t8 = results_24h_no_pfc_67bus[8]

# ### Plotting Gen outputs vs cost
# t = 17
# gens = data_24h_no_pfc_67bus[t]["gen"]
# solution = results_24h_with_pfc_67bus[t]["solution"]

# Pg = [solution["gen"][gen_id]["pg"] for gen_id in sort(collect(keys(gens)), by=x->parse(Int, x))]
# c1 = [gens[gen_id]["cost"][2] for gen_id in sort(collect(keys(gens)), by=x->parse(Int, x))] # Linear cost
# c2 = [gens[gen_id]["cost"][1] for gen_id in sort(collect(keys(gens)), by=x->parse(Int, x))] # Quadratic cost

# gen_cost = [c2[i]*Pg[i]^2 + c1[i]*Pg[i] for i in 1:length(Pg)]
# gen_cost_linear = [c1[i]*Pg[i] for i in 1:length(Pg)]

# gen_ids = sort(collect(keys(gens)), by=x->parse(Int, x))

# scatter(Pg, gen_cost, xlabel="Generator Output Pg (pu)", ylabel="Generator Cost (EUR)", title="Generator Output vs Cost at Hour $t", legend=false)
# for i in 1:length(Pg)
#     annotate!(Pg[i], gen_cost[i], text("Gen $(gen_ids[i])", 8, :black))
# end

# scatter!(Pg, gen_cost_linear, label="Linear Cost", color=:red)

# ## Checking Q balance
# load_t7 = sum([data_24h_with_pfc_67bus[7]["load"][load_id]["qd"] for load_id in keys(data_24h_with_pfc_67bus[7]["load"])])
# gen_pfc_q_t7 = sum([results_24h_with_pfc_67bus[7]["solution"]["gen"][gen_id]["qg"] for gen_id in sort(collect(keys(results_24h_with_pfc_67bus[7]["solution"]["gen"])), by=x->parse(Int, x))])

# solution_with_pfc_t7 = results_24h_with_pfc_67bus[7]["solution"]
# # check ac voltage limits
# for (bus_id, bus_data) in data_24h_with_pfc_67bus[7]["bus"]
#     vr = solution_with_pfc_t7["bus"][bus_id]["vr"]
#     vi = solution_with_pfc_t7["bus"][bus_id]["vi"]
#     vm = sqrt(vr^2 + vi^2)
#     vmin = bus_data["vmin"]
#     vmax = bus_data["vmax"]
#     if vm < vmin || vm > vmax
#         println("Bus $bus_id voltage violation: Vm = $vm, Limits = ($vmin, $vmax)")
#     end
#     if vm < 0.95
#         println("Bus $bus_id voltage out of normal range: Vm = $vm")
#     end
# end

# # Print Gen qg
# for (gen_id, gen_data) in data_24h_with_pfc_67bus[7]["gen"]
#     qg = solution_with_pfc_t7["gen"][gen_id]["qg"]
#     qmin = gen_data["qmin"]
#     qmax = gen_data["qmax"]
#     if qg < qmin || qg > qmax
#         println("Gen $gen_id reactive power violation: Qg = $qg, Limits = ($qmin, $qmax)")
#     end
# end



# ## Debugging t= 9,14,23 with reduced DC line capacity to 35%
# result_no_pfc_67bus_t9 = results_24h_no_pfc_67bus[9]
# result_with_pfc_67bus_t9 = results_24h_with_pfc_67bus[9]

# solution_no_pfc_t9 = result_no_pfc_67bus_t9["solution"]
# solution_with_pfc_t9 = result_with_pfc_67bus_t9["solution"]

# # Gen-Load balance
# load_t9 = sum([data_24h_no_pfc_67bus[9]["load"][load_id]["pd"] for load_id in keys(data_24h_no_pfc_67bus[9]["load"])])
# gen_no_pfc_t9 = sum([solution_no_pfc_t9["gen"][gen_id]["pg"] for gen_id in sort(collect(keys(solution_no_pfc_t9["gen"])), by=x->parse(Int, x))])

# load_q_t9 = sum([data_24h_no_pfc_67bus[9]["load"][load_id]["qd"] for load_id in keys(data_24h_no_pfc_67bus[9]["load"])])
# gen_no_pfc_q_t9 = sum([solution_no_pfc_t9["gen"][gen_id]["qg"] for gen_id in sort(collect(keys(solution_no_pfc_t9["gen"])), by=x->parse(Int, x))])

# # AC buses limit check
# for (bus_id, bus_data) in data_24h_no_pfc_67bus[9]["bus"]
#     vr = solution_no_pfc_t9["bus"][bus_id]["vr"]
#     vi = solution_no_pfc_t9["bus"][bus_id]["vi"]
#     vm = sqrt(vr^2 + vi^2)
#     vmin = bus_data["vmin"]
#     vmax = bus_data["vmax"]
#     if vm < vmin || vm > vmax
#         println("Bus $bus_id voltage violation: Vm = $vm, Limits = ($vmin, $vmax)")
#     end
# end

# # DC buses
# for (dc_bus_id, dc_bus_data) in data_24h_no_pfc_67bus[9]["busdc"]
#     vm = solution_no_pfc_t9["busdc"][dc_bus_id]["vm"]
#     vdc_min = dc_bus_data["Vdcmin"]
#     vdc_max = dc_bus_data["Vdcmax"]
#     if vm < vdc_min || vm > vdc_max
#         println("DC Bus $dc_bus_id voltage violation: Vdc = $vdc, Limits = ($vdc_min, $vdc_max)")
#     end
# end

# # AC branch limit check
# for (branch_id,branch) in data_24h_no_pfc_67bus[9]["branch"]
#     pf = solution_no_pfc_t9["branch"][branch_id]["pf"]
#     pt = solution_no_pfc_t9["branch"][branch_id]["pt"]
#     rateA = branch["rate_a"]
#     loading = max(abs(pf), abs(pt)) / rateA * 100
#     if loading > 95
#         println("Branch $branch_id near loading violation: Loading = $loading %, RateA = $rateA")
#     end
# end

# # DC branch limit check
# for (branchdc_id, branchdc) in data_24h_no_pfc_67bus[9]["branchdc"]
#     pf = solution_no_pfc_t9["branchdc"][branchdc_id]["pf"]
#     pt = solution_no_pfc_t9["branchdc"][branchdc_id]["pt"]
#     rateA = branchdc["rateA"]
#     loading = max(abs(pf),abs(pt)) / rateA * 100
#     if loading > 95
#         println("DC Branch $branchdc_id near loading violation: Loading = $loading %, RateA = $rateA")
#     end
# end

# # HVDC converter limits
# for (convdc_id,convdc) in data_24h_no_pfc[9]["convdc"]
#     i_conv = solution_no_pfc_t9["convdc"][convdc_id]["i_conv"]
# end

# # Check KCL in DC buses

# # Bus 1
# pconv = solution_no_pfc_t9["convdc"]["1"]["pdc"]
# pdc1 = solution_no_pfc_t9["branchdc"]["1"]["pf"]
# pdc5 = solution_no_pfc_t9["branchdc"]["5"]["pf"]

# #Print Branchdc flows
# println("DC Branch Flows at Hour 9:")
# for (branchdc_id, branchdc_data) in data_24h_no_pfc_67bus[9]["branchdc"]
#     pf = solution__pfc_t9["branchdc"][branchdc_id]["pf"]
#     println("Branch DC $branchdc_id: Flow = $pf")
# end
# #Print Convdc pdc
# println("DC Converter Flows at Hour 9:")
# for (convdc_id, convdc_data) in data_24h_no_pfc_67bus[9]["convdc"]
#     pdc = solution_with_pfc_t9["convdc"][convdc_id]["pdc"]
#     println("Converter DC $convdc_id: Pdc = $pdc")
# end






# ## Debug time step 17 with reduced DC line capacity to 35%
# result_no_pfc_67bus_t17 = results_24h_no_pfc_67bus[17]
# result_with_pfc_67bus_t17 = results_24h_with_pfc_67bus[17]

# # Plot the DC line loading for both cases at time step 17
# dc_branch_ids = sort(collect(keys(data_no_pfc_67bus["branchdc"])), by=x->parse(Int, x)) 
# dc_loading_no_pfc_t17 = [abs(result_no_pfc_67bus_t17["solution"]["branchdc"][branchdc_id]["pf"]) / data_no_pfc_67bus["branchdc"][branchdc_id]["rateA"] * 100 for branchdc_id in dc_branch_ids]
# dc_loading_with_pfc_t17 = [abs(result_with_pfc_67bus_t17["solution"]["branchdc"][branchdc_id]["pf"]) / data_with_pfc_67bus["branchdc"][branchdc_id]["rateA"] * 100 for branchdc_id in dc_branch_ids]

# bar(dc_branch_ids .- 0.15, dc_loading_no_pfc_t17, width=0.3, label="No PFC", xlabel="DC Branch ID", ylabel="DC Line Loading (%)", title="DC Line Loading at Hour 17", legend=:topright, ylim=(0, 120))

# delta_loading = [dc_loading_no_pfc_t17[i] - dc_loading_with_pfc_t17[i] for i in 1:length(dc_branch_ids)]

# ## Print all "pg_cost" from result solution gen
# println("================================")
# println("Generator Cost Functions Side by Side:")
# println("================================")
# println("Generator ID | Cost Function Value (No PFC) | Cost Function Value (With PFC) | Difference")
# solution_no_pfc_t17 = result_no_pfc_67bus_t17["solution"]
# solution_with_pfc_t17 = result_with_pfc_67bus_t17["solution"]

# gen_ids_no_pfc = sort(collect(keys(solution_no_pfc_t17["gen"])), by=x->parse(Int, x))
# gen_ids_with_pfc = sort(collect(keys(solution_with_pfc_t17["gen"])), by=x->parse(Int, x))

# for gen_id in unique(vcat(gen_ids_no_pfc, gen_ids_with_pfc))
#     pg_cost_no_pfc = get(solution_no_pfc_t17["gen"], string(gen_id), Dict())["pg_cost"]
#     pg_cost_with_pfc = get(solution_with_pfc_t17["gen"], string(gen_id), Dict())["pg_cost"]
#     difference = pg_cost_with_pfc - pg_cost_no_pfc
#     println("Gen ID: $gen_id | Cost: $pg_cost_no_pfc | Cost: $pg_cost_with_pfc | Difference: $difference")
# end

# # Sum all pg for both cases at time step 17
# total_pg_no_pfc_t17 = sum([solution_no_pfc_t17["gen"][gen_id]["pg"] for gen_id in gen_ids_no_pfc])
# total_pg_with_pfc_t17 = sum([solution_with_pfc_t17["gen"][gen_id]["pg"] for gen_id in gen_ids_with_pfc])

# # Sum all load for both cases at time step 17
# total_load_t17 = sum([data_24h_no_pfc_67bus[17]["load"][load_id]["pd"] for load_id in keys(data_24h_no_pfc_67bus[17]["load"])])
# println("================================")
# println("Power Balance at Hour 17:")
# println("================================")
# println("Total Generation No PFC: $total_pg_no_pfc_t17")
# println("Total Generation With PFC: $total_pg_with_pfc_t17")
# println("Total Load: $total_load_t17")



# Funtion to scale the load
function scale_load!(data, data_24h, time_steps, p_mult)
    for t in time_steps
        data_copy = deepcopy(data)
        for (load_id, load_data) in data_copy["load"]
            load_data["pd"] *= p_mult[t]
            # load_data["qd"] *= p_mult[t]
        end
        data_24h[t] = data_copy
    end
end

function apply_cf_wind!(data, data_24h, time_steps, cf_on, cf_off)
    offshore_wind_ids = ["20"]
    onshore_wind_ids = ["2","4"]
    for t in time_steps
        data_copy = deepcopy(data)
        for wind_id in offshore_wind_ids
            data_copy["gen"][wind_id]["pmax"] *= cf_off[t]
        end
        for wind_id in onshore_wind_ids
            data_copy["gen"][wind_id]["pmax"] *= cf_on[t]
        end
        data_24h[t] = data_copy
    end
end

function scale_load_wind!(data, data_24h, time_steps, p_mult, cf_on, cf_off)
    offshore_wind_ids = ["20"]
    onshore_wind_ids = ["2","4"]
    for t in time_steps
        data_copy = deepcopy(data)
        for (load_id, load_data) in data_copy["load"]
            load_data["pd"] *= p_mult[t]
        end
        for wind_id in offshore_wind_ids
            data_copy["gen"][wind_id]["pmax"] *= cf_off[t]
        end
        for wind_id in onshore_wind_ids
            data_copy["gen"][wind_id]["pmax"] *= cf_on[t]
        end
        data_24h[t] = data_copy
    end
end

# function compute_losses(result_24h, data_24h, time_steps)
#     for t in time_steps
#         total_gen_t = sum([result_24h[t]["solution"]["gen"][gen_id]["pg"] for gen_id in keys(result_24h[t]["solution"]["gen"])])
#         total_load_t = sum([data_24h[t]["load"][load_id]["pd"] for load_id in keys(data_24h[t]["load"])])
#         losses_t = total_gen_t - total_load_t
#     end
#     total_gen = sum(total_gen_t for t in time_steps)
#     total_load = sum(total_load_t for t in time_steps)
#     total_losses = total_gen - total_load
# end

function benefit_calculation(objective_no_pfc, objective_with_pfc, difference_vector, time_steps)
    total_no_pfc = 0
    total_with_pfc = 0
    for t in time_steps
        total_no_pfc += objective_no_pfc[t]
        total_with_pfc += objective_with_pfc[t]
        diff = objective_no_pfc[t] - objective_with_pfc[t]
        diff_percent = (diff / objective_no_pfc[t]) * 100
        difference_vector[t] = [diff, diff_percent]
    end
    total_diff = total_no_pfc - total_with_pfc
    total_diff_percent = (total_diff / total_no_pfc) * 100
    println("================================")
    println("Total Benefit over 24 hours:")
    println("Total Objective No PFC: $total_no_pfc")
    println("Total Objective With PFC: $total_with_pfc")
    println("Total Difference: $total_diff")
    println("Total Percentage Difference: $total_diff_percent %")
    println("================================")
end

function check_pfc_var(result,data)
    println("================================")
    println("PFC Variables:")
    println("================================")

    solution = result["solution"]
    pfc = solution["pfc"]
    branchdc = solution["branchdc"]

    for (pfc_id, pfc_data) in pfc
        vm_e = pfc_data["c_voltage"]
        d = pfc_data["duty_cycle"]
        DE = d*vm_e
        D1E = (1 - d)*vm_e
        println("PFC $pfc_id: DC Voltage setpoint = $vm_e pu\n")
        println("PFC $pfc_id: Duty Cycle = $d \n")
        println("PFC $pfc_id: DE = $DE pu\n")
        println("PFC $pfc_id: 1-DE = $D1E pu\n")
        # println("--------------------------------------------------")
        # I2 = branchdc["2"]["if"]
        # I3 = branchdc["1"]["if"]
        # d_calc = I3/(I2 + I3)
        # println("PFC $pfc_id: Branch Currents I2 = $I2 pu, I3 = $I3 pu\n")
        # println("PFC $pfc_id: Calculated Duty Cycle from branch currents = $d_calc \n")
    end
end

function check_duty_cycle(result,data)
    println("================================")
    println("PFC Duty Cycle Check:")
    println("================================")
    solution = result["solution"]
    branchdc = solution["branchdc"]
    I2 = abs(branchdc["2"]["if"])
    I3 = abs(branchdc["1"]["if"])
    d_calc = I3/(I2 + I3)
    println("Branch Currents I2 = $I2 pu, I3 = $I3 pu\n")
    println("Calculated Duty Cycle from branch currents = $d_calc \n")
end

function check_power_flows(result, data)

    println("================================")
    println("Power Flows in the system:")
    println("================================")

    solution = result["solution"]
    if haskey(solution,"branch")
        branch = solution["branch"]
        for(branch_id, branch_data) in branch
            from_bus = data["branch"][branch_id]["f_bus"]
            to_bus = data["branch"][branch_id]["t_bus"]
            pf = branch_data["pf"]
            pt = branch_data["pt"]
    
            println("AC Branch $branch_id: From Bus $from_bus to Bus $to_bus")
            println("  Power Flow From (pf): $pf pu")
            println("  Power Flow To (pt): $pt pu\n")
        end
    end
    branchdc = solution["branchdc"]
    convdc = solution["convdc"]
    busdc = solution["busdc"]
    gen = solution["gen"]
    load = data["load"]
    bus = solution["bus"]
    if haskey(solution,"pfc")
        pfc = solution["pfc"]
        for (pfc_id, pfc_data) in pfc
            vm_e = pfc_data["c_voltage"]
            d = pfc_data["duty_cycle"]
            println("PFC $pfc_id: DC Voltage setpoint = $vm_e pu\n")
            println("PFC $pfc_id: Duty Cycle = $d \n")
        end
    end

    total_gen = 0.0
    total_ens = 0.0
    for (gen_id, gen_data) in gen
        bus = data["gen"][gen_id]["gen_bus"]
        pg = gen_data["pg"]
        total_gen += pg
        if (gen_id == "3" || gen_id == "4" || gen_id == "5" || gen_id == "6") #Gen 3 to 6 are ENS virtual gens
            total_ens += pg
        end
        println("Generator $gen_id at Bus $bus: Generation = $pg pu\n")
    end
    println("Total Generation in the system: $total_gen pu\n")
    println("Total ENS Generation in the system: $total_ens pu\n")

    total_load = 0.0
    for (load_id, load_data) in load
        bus = data["load"][load_id]["load_bus"]
        pd = load_data["pd"]
        total_load += pd
        println("Load $load_id at Bus $bus: Demand = $pd pu\n")
    end
    println("Total Load in the system: $total_load pu\n")
    
    p_loss = total_gen - total_load
    println("Total Power Loss in the system: $p_loss pu\n")

    for(convdc_id, convdc_data) in convdc
        dcbus = data["convdc"][convdc_id]["busdc_i"]
        acbus = data["convdc"][convdc_id]["busac_i"]
        pdc = convdc_data["pdc"]
        pconv = convdc_data["pconv"]

        println("Converter DC $convdc_id: From AC Bus $acbus to DC Bus $dcbus")
        println("  Power Flow to/from AC Grid (pconv): $pconv pu")
        println("  Power Flow to/from DC Grid (pdc): $pdc pu\n")
    end

    for (branchdc_id, branchdc_data) in branchdc
        from_bus = data["branchdc"][branchdc_id]["fbusdc"]
        to_bus = data["branchdc"][branchdc_id]["tbusdc"]
        pf = branchdc_data["pf"]
        pt = branchdc_data["pt"]
        ifrom = branchdc_data["if"]

        println("DC Branch $branchdc_id: From Bus $from_bus to Bus $to_bus")
        println("  Power Flow From (pf): $pf pu")
        println("  Power Flow To (pt): $pt pu\n")
        println("  Current Flow From (if): $ifrom pu\n")
    end

    for (busdc_id, busdc_data) in busdc
        vdc = busdc_data["vm"]
        println("DC Bus $busdc_id: Voltage = $vdc pu\n")
    end

    # for (bus_id, bus_data) in bus
    #     vr = bus_data["vr"]
    #     vi = bus_data["vi"]
    #     vm = sqrt(vr^2 + vi^2)
    #     println("AC Bus $bus_id: Voltage Magnitude = $vm pu\n")
    # end

end

function add_ens_gens!(data; VOLL = 100000)
    max_gen_id = maximum(parse.(Int, keys(data["gen"])))
    ens_gen_id = 1
    for (bus_id, bus) in data["bus"]
        # Check if the load exists for the bus
        if haskey(data["load"], bus_id)
            ens_gen_key = max_gen_id + ens_gen_id
            data["gen"][string(ens_gen_key)] = Dict(
                "gen_bus" => parse(Int,bus_id),
                "pg" => 0.0,
                "qg" => 0.0,
                "qmax" => 100.0,
                "qmin" => -100.0,
                "vg" => bus["vm"],
                "mbase" => 100.0,
                "gen_status" => 1,
                "pmax" => data["load"][bus_id]["pd"],  # Use load value from data["load"]
                "pmin" => 0.0,
                "cost" => [VOLL , 0],
                "ncost" => 3,
                "model" => 2,
                "shutdown" => 0,
                "startup" => 0,
                "source_id" => Any["gen", ens_gen_key],
                "index" => ens_gen_key
            )
            ens_gen_id += 1
        end
    end
end

function compute_AC_branch_loading_24h(results_24h, data_24h, time_steps, AC_branch_loading; threshold=90) 
    for t in time_steps
        congested_branches = Dict{Any, Any}()
        result = results_24h[t]
        data = data_24h[t]
        for (branch_id, branch_data) in result["solution"]["branch"]
            flow = abs(max(branch_data["pf"], branch_data["pt"]))
            capacity = data["branch"][branch_id]["rate_a"]
            loading_percent = flow / capacity * 100
            if loading_percent >= threshold
                congested_branches[branch_id] = loading_percent
            end
        end
        AC_branch_loading[t] = congested_branches
    end
end

function compute_DC_branch_loading_24h(results_24h, data_24h, time_steps, DC_branch_loading; threshold=90) 
    for t in time_steps
        congested_branches = Dict{Any, Any}()
        result = results_24h[t]
        data = data_24h[t]
        for (branchdc_id, branchdc_data) in result["solution"]["branchdc"]
            flow = abs(max(branchdc_data["pf"], branchdc_data["pt"]))
            capacity = data["branchdc"][branchdc_id]["rateA"]
            loading_percent = flow / capacity * 100
            if loading_percent >= threshold
                congested_branches[branchdc_id] = loading_percent
            end
        end
        DC_branch_loading[t] = congested_branches
    end
end

function get_DC_branch_loading_single_time_step(result, data, DC_branch_loading; threshold=90)
    # loading_percentages = zeros(Float64, 11)
    congested_branches = Dict{Any, Any}()
    for (branchdc_id, branchdc_data) in result["solution"]["branchdc"]
        flow = abs(max(branchdc_data["pf"], branchdc_data["pt"]))
        capacity = data["branchdc"][branchdc_id]["rateA"]
        loading_percent = flow / capacity * 100
        # loading_percentages[data["branchdc"][branchdc_id]["index"]] = loading_percent
        if loading_percent >= threshold
            congested_branches[branchdc_id] = loading_percent
        end
    end
    DC_branch_loading = congested_branches
    # return loading_percentages
end

function get_AC_branch_loading_single_time_step(result, data, AC_branch_loading; threshold=90)
    # loading_percentages = zeros(Float64, length(data["branch"]))
    congested_branches = Dict{Any, Any}()
    for (branch_id, branch_data) in result["solution"]["branch"]
        flow = abs(max(branch_data["pf"], branch_data["pt"]))
        capacity = data["branch"][branch_id]["rate_a"]
        loading_percent = flow / capacity * 100
        # loading_percentages[data["branch"][branch_id]["index"]] = loading_percent
        if loading_percent >= threshold
            congested_branches[branch_id] = loading_percent
        end
    end
    AC_branch_loading = congested_branches
    # return loading_percentages
end

function compute_hourly_load(data_24h,time_steps, load_24h)
    for t in time_steps
        l = 0
        for (load_id,load) in data_24h[t]["load"]
            l += load["pd"]
        end
        load_24h[t] = l
    end
end

function compute_generation_matrix!(results_24h, time_steps, gen_outputs_matrix)
    for t in time_steps
        for (gen_id, gen_data) in results_24h[t]["solution"]["gen"]
            gen_index = parse(Int, gen_id)
            gen_outputs_matrix[t, gen_index] = gen_data["pg"]
        end
    end
end

function get_DC_branch_loading(results_24h, data_24h, time_steps)
    loading_percentages = zeros(Float64, length(time_steps), 11)
    for t in time_steps
        result = results_24h[t]
        data = data_24h[t]
        for (branchdc_id, branchdc_data) in result["solution"]["branchdc"]
            flow = abs(max(branchdc_data["pf"], branchdc_data["pt"]))
            capacity = data["branchdc"][branchdc_id]["rateA"]
            loading_percent = flow / capacity * 100
            loading_percentages[t,data["branchdc"][branchdc_id]["index"]] = loading_percent
        end
    end
    return loading_percentages
end

