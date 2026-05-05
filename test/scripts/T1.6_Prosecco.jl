using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots
import HSL_jll


ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 0, "linear_solver" => "ma57") # Changed tolerance to 1e-8 from 1e-6
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)


## Data loading

# No PFC
data_no_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test.m")
_PMACDC.process_additional_data!(data_no_pfc)
# data_no_pfc["branchdc"]["3"]["rateA"] = 4.0
add_ens_gens!(data_no_pfc)
# SC4
data_sc4 = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_SC4.m")
_PMACDC.process_additional_data!(data_sc4)
# data_sc4["branchdc"]["3"]["rateA"] = 4.0
add_ens_gens!(data_sc4)
# SC5
data_sc5 = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_SC5.m")
_PMACDC.process_additional_data!(data_sc5)
add_ens_gens!(data_sc5)
# SC6
data_sc6 = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_SC6.m")
_PMACDC.process_additional_data!(data_sc6)
add_ens_gens!(data_sc6)
# SC7
data_sc7 = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_SC7.m")
_PMACDC.process_additional_data!(data_sc7)
add_ens_gens!(data_sc7)

for data in [data_no_pfc, data_sc4, data_sc5, data_sc6, data_sc7]
    for (branchdc_id, branchdc) in data["branchdc"]
        branchdc["rateA"] = 5.0
    end
end


# Contingencies
ac_branches = ["1"]
dc_branches = ["1","2","3","4","5","6","7"]
n_cont = length(ac_branches) + length(dc_branches) + 1 # +1 for base case

# Results and Data
results_no_pfc = Vector{Dict{String,Any}}(undef, n_cont)
results_pfc_sc4 = Vector{Dict{String,Any}}(undef, n_cont)
results_pfc_sc5 = Vector{Dict{String,Any}}(undef, n_cont)
results_pfc_sc6 = Vector{Dict{String,Any}}(undef, n_cont)
results_pfc_sc7 = Vector{Dict{String,Any}}(undef, n_cont)

#Base
results_no_pfc[1]  = _PMACDC.solve_acdcopf_iv(data_no_pfc, _PM.IVRPowerModel, ipopt,; setting = s)
results_pfc_sc4[1] = _PMACDC.solve_acdcopf_iv(data_sc4, _PM.IVRPowerModel, ipopt,; setting = s)
results_pfc_sc5[1] = _PMACDC.solve_acdcopf_iv(data_sc5, _PM.IVRPowerModel, ipopt,; setting = s)
results_pfc_sc6[1] = _PMACDC.solve_acdcopf_iv(data_sc6, _PM.IVRPowerModel, ipopt,; setting = s)
results_pfc_sc7[1] = _PMACDC.solve_acdcopf_iv(data_sc7, _PM.IVRPowerModel, ipopt,; setting = s)

#DC N-1
for (i,dc) in enumerate(dc_branches)
    c = i + 1
    #No PFC
    data_run = deepcopy(data_no_pfc)
    data_run["branchdc"][dc]["status"] = 0
    results_no_pfc[c]  = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    # SC4
    data_run = deepcopy(data_sc4)
    data_run["branchdc"][dc]["status"] = 0
    results_pfc_sc4[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC5
    data_run = deepcopy(data_sc5)
    data_run["branchdc"][dc]["status"] = 0
    results_pfc_sc5[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC6
    data_run = deepcopy(data_sc6)
    data_run["branchdc"][dc]["status"] = 0
    results_pfc_sc6[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC7
    data_run = deepcopy(data_sc7)
    data_run["branchdc"][dc]["status"] = 0
    results_pfc_sc7[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
end

#AC N-1
for (i,ac) in enumerate(ac_branches)
    c = i + 1 + length(dc_branches)
    #No PFC
    data_run = deepcopy(data_no_pfc)
    data_run["branch"][ac]["br_status"] = 0
    results_no_pfc[c]  = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    # SC4
    data_run = deepcopy(data_sc4)
    data_run["branch"][ac]["br_status"] = 0
    results_pfc_sc4[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC5
    data_run = deepcopy(data_sc5)
    data_run["branch"][ac]["br_status"] = 0
    results_pfc_sc5[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC6
    data_run = deepcopy(data_sc6)
    data_run["branch"][ac]["br_status"] = 0
    results_pfc_sc6[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
    #SC7
    data_run = deepcopy(data_sc7)
    data_run["branch"][ac]["br_status"] = 0
    results_pfc_sc7[c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt,; setting = s)
end

# Check termination_status
status_no_pfc = check_termination_status(results_no_pfc)
status_sc4 = check_termination_status(results_pfc_sc4)
status_sc5 = check_termination_status(results_pfc_sc5)
status_sc6 = check_termination_status(results_pfc_sc6)
status_sc7 = check_termination_status(results_pfc_sc7)


# Extract results

objective_no_pfc = [results_no_pfc[c]["objective"] for c in 1:n_cont]
objective_sc4 = [results_pfc_sc4[c]["objective"] for c in 1:n_cont]
objective_sc5 = [results_pfc_sc5[c]["objective"] for c in 1:n_cont]
objective_sc6 = [results_pfc_sc6[c]["objective"] for c in 1:n_cont]
objective_sc7 = [results_pfc_sc7[c]["objective"] for c in 1:n_cont]

# Computation time
time_no_pfc = [results_no_pfc[c]["solve_time"] for c in 1:n_cont]
time_sc4 = [results_pfc_sc4[c]["solve_time"] for c in 1:n_cont]
time_sc5 = [results_pfc_sc5[c]["solve_time"] for c in 1:n_cont]
time_sc6 = [results_pfc_sc6[c]["solve_time"] for c in 1:n_cont]
time_sc7 = [results_pfc_sc7[c]["solve_time"] for c in 1:n_cont]

# Curtailment check
# Base Wind generation
wind_1_no_pfc = [results_no_pfc[1]["solution"]["gen"]["3"]["pg"]]
wind_2_no_pfc = [results_no_pfc[1]["solution"]["gen"]["4"]["pg"]]

# Wind generation in each scenario
wind_1_no_pfc_base = [results_no_pfc[c]["solution"]["gen"]["3"]["pg"] for c in 2:n_cont]
wind_1_sc4 = [results_pfc_sc4[c]["solution"]["gen"]["3"]["pg"] for c in 2:n_cont]
wind_1_sc5 = [results_pfc_sc5[c]["solution"]["gen"]["3"]["pg"] for c in 2:n_cont]
wind_1_sc6 = [results_pfc_sc6[c]["solution"]["gen"]["3"]["pg"] for c in 2:n_cont]
wind_1_sc7 = [results_pfc_sc7[c]["solution"]["gen"]["3"]["pg"] for c in 2:n_cont]

wind_2_no_pfc_base = [results_no_pfc[c]["solution"]["gen"]["4"]["pg"] for c in 2:n_cont]
wind_2_sc4 = [results_pfc_sc4[c]["solution"]["gen"]["4"]["pg"] for c in 2:n_cont]
wind_2_sc5 = [results_pfc_sc5[c]["solution"]["gen"]["4"]["pg"] for c in 2:n_cont]
wind_2_sc6 = [results_pfc_sc6[c]["solution"]["gen"]["4"]["pg"] for c in 2:n_cont]
wind_2_sc7 = [results_pfc_sc7[c]["solution"]["gen"]["4"]["pg"] for c in 2:n_cont]

# Delta wind
delta_wind_1_no_pfc = wind_1_no_pfc_base .- wind_1_no_pfc
delta_wind_2_no_pfc = wind_2_no_pfc_base .- wind_2_no_pfc
delta_wind_no_pfc = delta_wind_1_no_pfc .+ delta_wind_2_no_pfc

delta_wind_1_sc4 = wind_1_sc4 .- wind_1_no_pfc
delta_wind_2_sc4 = wind_2_sc4 .- wind_2_no_pfc
delta_wind_sc4 = delta_wind_1_sc4 .+ delta_wind_2_sc4

delta_wind_1_sc5 = wind_1_sc5 .- wind_1_no_pfc
delta_wind_2_sc5 = wind_2_sc5 .- wind_2_no_pfc
delta_wind_sc5 = delta_wind_1_sc5 .+ delta_wind_2_sc5

delta_wind_1_sc6 = wind_1_sc6 .- wind_1_no_pfc
delta_wind_2_sc6 = wind_2_sc6 .- wind_2_no_pfc
delta_wind_sc6 = delta_wind_1_sc6 .+ delta_wind_2_sc6

delta_wind_1_sc7 = wind_1_sc7 .- wind_1_no_pfc
delta_wind_2_sc7 = wind_2_sc7 .- wind_2_no_pfc
delta_wind_sc7 = delta_wind_1_sc7 .+ delta_wind_2_sc7

# Check HVDC loading > 90% for any scenario
hvdc_loading_no_pfc = [hvdc_loading(data_no_pfc, results_no_pfc[c]) for c in 1:n_cont]
hvdc_loading_sc4 = [hvdc_loading(data_sc4, results_pfc_sc4[c]) for c in 1:n_cont]
hvdc_loading_sc5 = [hvdc_loading(data_sc5, results_pfc_sc5[c]) for c in 1:n_cont]
hvdc_loading_sc6 = [hvdc_loading(data_sc6, results_pfc_sc6[c]) for c in 1:n_cont]
hvdc_loading_sc7 = [hvdc_loading(data_sc7, results_pfc_sc7[c]) for c in 1:n_cont]

# Check branch DC loading > 90% for any scenario
branchdc_loading_no_pfc = [branch_dc_loading(data_no_pfc, results_no_pfc[c]) for c in 1:n_cont]
branchdc_loading_sc4 = [branch_dc_loading(data_sc4, results_pfc_sc4[c]) for c in 1:n_cont]
branchdc_loading_sc5 = [branch_dc_loading(data_sc5, results_pfc_sc5[c]) for c in 1:n_cont]
branchdc_loading_sc6 = [branch_dc_loading(data_sc6, results_pfc_sc6[c]) for c in 1:n_cont]
branchdc_loading_sc7 = [branch_dc_loading(data_sc7, results_pfc_sc7[c]) for c in 1:n_cont]

# System losses Generation - Load
# Maybe consider removing the ENS to avoid double counting of losses in the case of load shedding
losses_no_pfc = [total_losses(data_no_pfc, results_no_pfc[c]) for c in 1:n_cont]
losses_sc4 = [total_losses(data_sc4, results_pfc_sc4[c]) for c in 1:n_cont]
losses_sc5 = [total_losses(data_sc5, results_pfc_sc5[c]) for c in 1:n_cont]
losses_sc6 = [total_losses(data_sc6, results_pfc_sc6[c]) for c in 1:n_cont]
losses_sc7 = [total_losses(data_sc7, results_pfc_sc7[c]) for c in 1:n_cont] 

# Generation change
gen_1_no_pfc = [results_no_pfc[1]["solution"]["gen"]["1"]["pg"]]
gen_2_no_pfc = [results_no_pfc[1]["solution"]["gen"]["2"]["pg"]]

# No pfc
gen_1_no_pfc_base = [results_no_pfc[c]["solution"]["gen"]["1"]["pg"] for c in 2:n_cont]
gen_2_no_pfc_base = [results_no_pfc[c]["solution"]["gen"]["2"]["pg"] for c in 2:n_cont]
# With PFC
gen_1_sc4 = [results_pfc_sc4[c]["solution"]["gen"]["1"]["pg"] for c in 2:n_cont]
gen_2_sc4 = [results_pfc_sc4[c]["solution"]["gen"]["2"]["pg"] for c in 2:n_cont]
gen_1_sc5 = [results_pfc_sc5[c]["solution"]["gen"]["1"]["pg"] for c in 2:n_cont]
gen_2_sc5 = [results_pfc_sc5[c]["solution"]["gen"]["2"]["pg"] for c in 2:n_cont]
gen_1_sc6 = [results_pfc_sc6[c]["solution"]["gen"]["1"]["pg"] for c in 2:n_cont]
gen_2_sc6 = [results_pfc_sc6[c]["solution"]["gen"]["2"]["pg"] for c in 2:n_cont]
gen_1_sc7 = [results_pfc_sc7[c]["solution"]["gen"]["1"]["pg"] for c in 2:n_cont]
gen_2_sc7 = [results_pfc_sc7[c]["solution"]["gen"]["2"]["pg"] for c in 2:n_cont]

# Delta gen
delta_gen_1_no_pfc = gen_1_no_pfc_base .- gen_1_no_pfc
delta_gen_2_no_pfc = gen_2_no_pfc_base .- gen_2_no_pfc
delta_gen_no_pfc = delta_gen_1_no_pfc .+ delta_gen_2_no_pfc

delta_gen_1_sc4 = gen_1_sc4 .- gen_1_no_pfc
delta_gen_2_sc4 = gen_2_sc4 .- gen_2_no_pfc
delta_gen_sc4 = delta_gen_1_sc4 .+ delta_gen_2_sc4

delta_gen_1_sc5 = gen_1_sc5 .- gen_1_no_pfc
delta_gen_2_sc5 = gen_2_sc5 .- gen_2_no_pfc
delta_gen_sc5 = delta_gen_1_sc5 .+ delta_gen_2_sc5

delta_gen_1_sc6 = gen_1_sc6 .- gen_1_no_pfc
delta_gen_2_sc6 = gen_2_sc6 .- gen_2_no_pfc
delta_gen_sc6 = delta_gen_1_sc6 .+ delta_gen_2_sc6

delta_gen_1_sc7 = gen_1_sc7 .- gen_1_no_pfc
delta_gen_2_sc7 = gen_2_sc7 .- gen_2_no_pfc
delta_gen_sc7 = delta_gen_1_sc7 .+ delta_gen_2_sc7

# DC voltage magnitude margin

dc_bus_margin_no_pfc = [dc_bus_margin(data_no_pfc, results_no_pfc[c]) for c in 1:n_cont]
dc_bus_margin_sc4 = [dc_bus_margin(data_sc4, results_pfc_sc4[c]) for c in 1:n_cont]
dc_bus_margin_sc5 = [dc_bus_margin(data_sc5, results_pfc_sc5[c]) for c in 1:n_cont]
dc_bus_margin_sc6 = [dc_bus_margin(data_sc6, results_pfc_sc6[c]) for c in 1:n_cont]
dc_bus_margin_sc7 = [dc_bus_margin(data_sc7, results_pfc_sc7[c]) for c in 1:n_cont]


# savings
savings_sc4 = (objective_no_pfc .- objective_sc4)./objective_no_pfc * 100
savings_sc5 = (objective_no_pfc .- objective_sc5)./objective_no_pfc * 100
savings_sc6 = (objective_no_pfc .- objective_sc6)./objective_no_pfc * 100
savings_sc7 = (objective_no_pfc .- objective_sc7)./objective_no_pfc * 100

savings_sc4[abs.(savings_sc4) .< 1e-4] .= 0
savings_sc5[abs.(savings_sc5) .< 1e-4] .= 0
savings_sc6[abs.(savings_sc6) .< 1e-4] .= 0
savings_sc7[abs.(savings_sc7) .< 1e-4] .= 0

# Duty cycle
duty_cycle_sc4 = [results_pfc_sc4[c]["solution"]["pfc"]["1"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc5_1 = [results_pfc_sc5[c]["solution"]["pfc"]["1"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc5_2 = [results_pfc_sc5[c]["solution"]["pfc"]["2"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc6_1 = [results_pfc_sc6[c]["solution"]["pfc"]["1"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc6_2 = [results_pfc_sc6[c]["solution"]["pfc"]["2"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc7_1 = [results_pfc_sc7[c]["solution"]["pfc"]["1"]["duty_cycle"] for c in 1:n_cont]
duty_cycle_sc7_2 = [results_pfc_sc7[c]["solution"]["pfc"]["2"]["duty_cycle"] for c in 1:n_cont]

# E Voltage
voltage_sc4 = [results_pfc_sc4[c]["solution"]["pfc"]["1"]["c_voltage"] for c in 1:n_cont]
voltage_sc5_1 = [results_pfc_sc5[c]["solution"]["pfc"]["1"]["c_voltage"] for c in 1:n_cont]
voltage_sc5_2 = [results_pfc_sc5[c]["solution"]["pfc"]["2"]["c_voltage"] for c in 1:n_cont]
voltage_sc6_1 = [results_pfc_sc6[c]["solution"]["pfc"]["1"]["c_voltage"] for c in 1:n_cont]
voltage_sc6_2 = [results_pfc_sc6[c]["solution"]["pfc"]["2"]["c_voltage"] for c in 1:n_cont]
voltage_sc7_1 = [results_pfc_sc7[c]["solution"]["pfc"]["1"]["c_voltage"] for c in 1:n_cont]
voltage_sc7_2 = [results_pfc_sc7[c]["solution"]["pfc"]["2"]["c_voltage"] for c in 1:n_cont]












## Data without PFC
data = _PM.parse_file("test/data/PFC/cigre_B4_test.m")
_PMACDC.process_additional_data!(data)

## Data with PFC
# data_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_B5.m")
# data_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_2.m")
data_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_SC4.m")
_PMACDC.process_additional_data!(data_pfc)

# data_derate["branchdc"]["3"]["rateA"] = 3
# data_derate_pfc["branchdc"]["3"]["rateA"] = 3

## Running base case (No congestion)

result_no_pfc_base = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt,; setting = s)
result_with_pfc_base = _PMACDC.solve_acdcopf_iv(data_pfc, _PM.IVRPowerModel, ipopt,; setting = s)

## Loading data with congestion

data_derate = deepcopy(data)

data_derate_pfc = deepcopy(data_pfc)


# Derating of DC lines
## DC line 3 by 50%
data_derate["branchdc"]["3"]["rateA"] = 4
data_derate_pfc["branchdc"]["3"]["rateA"] = 4


# # Wind Capacity Factor
# CF = 0.4
# data["gen"]["3"]["pmax"] = 7 #data["gen"]["3"]["pmax"] * CF

# Solve for the congested case

result_derate = _PMACDC.solve_acdcopf_iv(data_derate, _PM.IVRPowerModel, ipopt,; setting = s)
result_derate_pfc = _PMACDC.solve_acdcopf_iv(data_derate_pfc, _PM.IVRPowerModel, ipopt,; setting = s)

saving = (result_derate["objective"] - result_derate_pfc["objective"])/result_derate["objective"] * 100
## N-1 contingencies
# DC line 7 outage
#without PFC
data_contingency = deepcopy(data)
data_contingency["branchdc"]["7"]["status"] = 0

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5) 
result_contingency = _PMACDC.solve_acdcopf_iv(data_contingency, _PM.IVRPowerModel, ipopt,; setting = s)

#with PFC
data_pfc_contingency = deepcopy(data_pfc)
data_pfc_contingency["branchdc"]["7"]["status"] = 0

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5)
result_pfc_contingency = _PMACDC.solve_acdcopf_iv(data_pfc_contingency, _PM.IVRPowerModel, ipopt,; setting = s)

saving = (result_contingency["objective"] - result_pfc_contingency["objective"])/result_contingency["objective"] * 100

# DC line 5 outage
#without PFC
data_contingency_5 = deepcopy(data)
data_contingency_5["branchdc"]["5"]["status"] = 0

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5)
result_contingency_5 = _PMACDC.solve_acdcopf_iv(data_contingency_5, _PM.IVRPowerModel, ipopt,; setting = s)

#with PFC
data_pfc_contingency_5 = deepcopy(data_pfc)
data_pfc_contingency_5["branchdc"]["5"]["status"] = 0

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5)
result_pfc_contingency_5 = _PMACDC.solve_acdcopf_iv(data_pfc_contingency_5, _PM.IVRPowerModel, ipopt,; setting = s)

saving = (result_contingency_5["objective"] - result_pfc_contingency_5["objective"])/result_contingency_5["objective"] * 100

## Higher load
#Without PFC
data_high_load = deepcopy(data)
for (load_id, load_data) in data_high_load["load"]
    load_data["pd"] *= 1.15
end
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5)
result_high_load = _PMACDC.solve_acdcopf_iv(data_high_load, _PM.IVRPowerModel, ipopt,; setting = s)

#With PFC
data_pfc_high_load = deepcopy(data_pfc)
for (load_id, load_data) in data_pfc_high_load["load"]
    load_data["pd"] *= 1.15
end
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-8, "print_level" => 5)
result_pfc_high_load = _PMACDC.solve_acdcopf_iv(data_pfc_high_load, _PM.IVRPowerModel, ipopt,; setting = s)


### Print results
#No congestion
objective_no_pfc_base = result_no_pfc_base["objective"]
objective_with_pfc_base = result_with_pfc_base["objective"]
#DC Line 3 derating
objective_no_pfc_derate = result_derate["objective"]
objective_with_pfc_derate = result_derate_pfc["objective"]
# DC Line 7 outage contingency
objective_no_pfc_contingency = result_contingency["objective"]
objective_with_pfc_contingency = result_pfc_contingency["objective"]
# DC Line 5 outage contingency
objective_no_pfc_contingency_5 = result_contingency_5["objective"]
objective_with_pfc_contingency_5 = result_pfc_contingency_5["objective"]
# Higher load
objective_no_pfc_high_load = result_high_load["objective"]
objective_with_pfc_high_load = result_pfc_high_load["objective"]

### Generation for each case
gen_no_pfc_base = gen_matrix(result_no_pfc_base["solution"]["gen"])
gen_with_pfc_base = gen_matrix(result_with_pfc_base["solution"]["gen"])
gen_no_pfc_derate = gen_matrix(result_derate["solution"]["gen"])
gen_with_pfc_derate = gen_matrix(result_derate_pfc["solution"]["gen"])
gen_no_pfc_contingency = gen_matrix(result_contingency["solution"]["gen"])
gen_with_pfc_contingency = gen_matrix(result_pfc_contingency["solution"]["gen"])
gen_no_pfc_contingency_5 = gen_matrix(result_contingency_5["solution"]["gen"])
gen_with_pfc_contingency_5 = gen_matrix(result_pfc_contingency_5["solution"]["gen"])
gen_no_pfc_high_load = gen_matrix(result_high_load["solution"]["gen"])
gen_with_pfc_high_load = gen_matrix(result_pfc_high_load["solution"]["gen"])

function sum_gen_by_keys(gen_dict)
    total = 0.0
    for (key, value) in gen_dict
        if key == "1" || key == "2"
            total += value[1]  # Summing the first part of the tuple
        end
    end
    return total
end

function sum_res_by_keys(gen_dict)
    total = 0.0
    for (key, value) in gen_dict
        if key == "3" || key == "4"
            total += value[1]  # Summing the first part of the tuple
        end
    end
    return total
end

# Sum of conventional generation for each case
total_gen_no_pfc = sum_gen_by_keys(gen_no_pfc_base)
total_gen_with_pfc = sum_gen_by_keys(gen_with_pfc_base)
total_gen_no_pfc_derate = sum_gen_by_keys(gen_no_pfc_derate)
total_gen_with_pfc_derate = sum_gen_by_keys(gen_with_pfc_derate)
total_gen_no_pfc_contingency = sum_gen_by_keys(gen_no_pfc_contingency)
total_gen_with_pfc_contingency = sum_gen_by_keys(gen_with_pfc_contingency)
total_gen_no_pfc_contingency_5 = sum_gen_by_keys(gen_no_pfc_contingency_5)
total_gen_with_pfc_contingency_5 = sum_gen_by_keys(gen_with_pfc_contingency_5)
total_gen_no_pfc_high_load = sum_gen_by_keys(gen_no_pfc_high_load)
total_gen_with_pfc_high_load = sum_gen_by_keys(gen_with_pfc_high_load)

# Sum of res generation for each case
total_res_no_pfc = sum_res_by_keys(gen_no_pfc_base)
total_res_with_pfc = sum_res_by_keys(gen_with_pfc_base)
total_res_no_pfc_derate = sum_res_by_keys(gen_no_pfc_derate)
total_res_with_pfc_derate = sum_res_by_keys(gen_with_pfc_derate)
total_res_no_pfc_contingency = sum_res_by_keys(gen_no_pfc_contingency)
total_res_with_pfc_contingency = sum_res_by_keys(gen_with_pfc_contingency)
total_res_no_pfc_contingency_5 = sum_res_by_keys(gen_no_pfc_contingency_5)
total_res_with_pfc_contingency_5 = sum_res_by_keys(gen_with_pfc_contingency_5)
total_res_no_pfc_high_load = sum_res_by_keys(gen_no_pfc_high_load)
total_res_with_pfc_high_load = sum_res_by_keys(gen_with_pfc_high_load)

# Total redispatching of conventional generation
resdispatch_no_pfc_derate = total_gen_no_pfc_derate - total_gen_no_pfc
resdispatch_with_pfc_derate = total_gen_with_pfc_derate - total_gen_with_pfc
resdispatch_no_pfc_contingency = total_gen_no_pfc_contingency - total_gen_no_pfc
resdispatch_with_pfc_contingency = total_gen_with_pfc_contingency - total_gen_with_pfc
resdispatch_no_pfc_contingency_5 = total_gen_no_pfc_contingency_5 - total_gen_no_pfc
resdispatch_with_pfc_contingency_5 = total_gen_with_pfc_contingency_5 - total_gen_with_pfc
resdispatch_no_pfc_high_load = total_gen_no_pfc_high_load - total_gen_no_pfc
resdispatch_with_pfc_high_load = total_gen_with_pfc_high_load - total_gen_with_pfc

# Total res curtailement
curtailment_no_pfc_derate = total_res_no_pfc_derate - total_res_no_pfc
curtailment_with_pfc_derate = total_res_with_pfc_derate - total_res_with_pfc
curtailment_no_pfc_contingency = total_res_no_pfc_contingency - total_res_no_pfc
curtailment_with_pfc_contingency = total_res_with_pfc_contingency - total_res_with_pfc
curtailment_no_pfc_contingency_5 = total_res_no_pfc_contingency_5 - total_res_no_pfc
curtailment_with_pfc_contingency_5 = total_res_with_pfc_contingency_5 - total_res_with_pfc
curtailment_no_pfc_high_load = total_res_no_pfc_high_load - total_res_no_pfc
curtailment_with_pfc_high_load = total_res_with_pfc_high_load - total_res_with_pfc

## Computation time per case
time_no_pfc_base = result_no_pfc_base["solve_time"]
time_with_pfc_base = result_with_pfc_base["solve_time"]
time_no_pfc_derate = result_derate["solve_time"]
time_with_pfc_derate = result_derate_pfc["solve_time"]
time_no_pfc_contingency = result_contingency["solve_time"]
time_with_pfc_contingency = result_pfc_contingency["solve_time"]
time_no_pfc_contingency_5 = result_contingency_5["solve_time"]
time_with_pfc_contingency_5 = result_pfc_contingency_5["solve_time"]
time_no_pfc_high_load = result_high_load["solve_time"]
time_with_pfc_high_load = result_pfc_high_load["solve_time"]

#Computation of total losses as percentage of total generation for each case
total_load_no_pfc_derate = total_losses(data_derate,result_derate)
total_load_with_pfc_derate = total_losses(data_derate_pfc,result_derate_pfc)
total_load_no_pfc_contingency = total_losses(data_contingency,result_contingency)
total_load_with_pfc_contingency = total_losses(data_pfc_contingency,result_pfc_contingency)
total_load_no_pfc_contingency_5 = total_losses(data_contingency_5,result_contingency_5)
total_load_with_pfc_contingency_5 = total_losses(data_pfc_contingency_5,result_pfc_contingency_5)
total_load_no_pfc_high_load = total_losses(data_high_load,result_high_load)
total_load_with_pfc_high_load = total_losses(data_pfc_high_load,result_pfc_high_load)

function energy_not_served(generation_data,res_data)
    total_load = 20
    total_generation = generation_data + res_data
    return max(0.0, total_load - total_generation)
end

# Calculate energy not served for each case
ens_no_pfc_base = energy_not_served(total_gen_no_pfc, total_res_no_pfc)
ens_with_pfc_base = energy_not_served(total_gen_with_pfc, total_res_with_pfc)
ens_no_pfc_derate = energy_not_served(total_gen_no_pfc_derate, total_res_no_pfc_derate)
ens_with_pfc_derate = energy_not_served(total_gen_with_pfc_derate, total_res_with_pfc_derate)
ens_no_pfc_contingency = energy_not_served(total_gen_no_pfc_contingency, total_res_no_pfc_contingency)
ens_with_pfc_contingency = energy_not_served(total_gen_with_pfc_contingency, total_res_with_pfc_contingency)
ens_no_pfc_contingency_5 = energy_not_served(total_gen_no_pfc_contingency_5, total_res_no_pfc_contingency_5)
ens_with_pfc_contingency_5 = energy_not_served(total_gen_with_pfc_contingency_5, total_res_with_pfc_contingency_5)
ens_no_pfc_high_load = energy_not_served(total_gen_no_pfc_high_load, total_res_no_pfc_high_load)
ens_with_pfc_high_load = energy_not_served(total_gen_with_pfc_high_load, total_res_with_pfc_high_load)




















println("------------------------------") 
println("Print of results")
println("-------------------------------")
println("Operation cost [EUR/h]")
println("Objective value without PFC (DC line 3 derating): ", objective_no_pfc_derate)
println("Objective value with PFC (DC line 3 derating): ", objective_with_pfc_derate)
println("Objective value without PFC (DC line 7 outage contingency): ", objective_no_pfc_contingency)
println("Objective value with PFC (DC line 7 outage contingency): ", objective_with_pfc_contingency)
println("Objective value without PFC (DC line 5 outage contingency): ", objective_no_pfc_contingency_5)
println("Objective value with PFC (DC line 5 outage contingency): ", objective_with_pfc_contingency_5)
println("Objective value without PFC (Higher load): ", objective_no_pfc_high_load)
println("Objective value with PFC (Higher load): ", objective_with_pfc_high_load)
println("------------------------------") 
println("Total Redispatch")
println("Redispatch of conventional generation without PFC (DC line 3 derating): ", resdispatch_no_pfc_derate)
println("Redispatch of conventional generation with PFC (DC line 3 derating): ", resdispatch_with_pfc_derate)
println("Redispatch of conventional generation without PFC (DC line 7 outage contingency): ", resdispatch_no_pfc_contingency)
println("Redispatch of conventional generation with PFC (DC line 7 outage contingency): ", resdispatch_with_pfc_contingency)
println("Redispatch of conventional generation without PFC (DC line 5 outage contingency): ", resdispatch_no_pfc_contingency_5)
println("Redispatch of conventional generation with PFC (DC line 5 outage contingency): ", resdispatch_with_pfc_contingency_5)
println("Redispatch of conventional generation without PFC (Higher load): ", resdispatch_no_pfc_high_load)
println("Redispatch of conventional generation with PFC (Higher load): ", resdispatch_with_pfc_high_load)
println("------------------------------")
println("Total Curtailment")
println("Curtailment of RES without PFC (DC line 3 derating): ", curtailment_no_pfc_derate)
println("Curtailment of RES with PFC (DC line 3 derating): ", curtailment_with_pfc_derate)
println("Curtailment of RES without PFC (DC line 7 outage contingency): ", curtailment_no_pfc_contingency)
println("Curtailment of RES with PFC (DC line 7 outage contingency): ", curtailment_with_pfc_contingency)
println("Curtailment of RES without PFC (DC line 5 outage contingency): ", curtailment_no_pfc_contingency_5)
println("Curtailment of RES with PFC (DC line 5 outage contingency): ", curtailment_with_pfc_contingency_5)
println("Curtailment of RES without PFC (Higher load): ", curtailment_no_pfc_high_load)
println("Curtailment of RES with PFC (Higher load): ", curtailment_with_pfc_high_load)
println("------------------------------")
println("Computation Time")
println("Computation time without PFC (DC line 3 derating): ", time_no_pfc_derate, " seconds")
println("Computation time with PFC (DC line 3 derating): ", time_with_pfc_derate, " seconds")
println("Computation time without PFC (DC line 7 outage contingency): ", time_no_pfc_contingency, " seconds")
println("Computation time with PFC (DC line 7 outage contingency): ", time_with_pfc_contingency, " seconds")
println("Computation time without PFC (DC line 5 outage contingency): ", time_no_pfc_contingency_5, " seconds")
println("Computation time with PFC (DC line 5 outage contingency): ", time_with_pfc_contingency_5, " seconds")
println("Computation time without PFC (Higher load): ", time_no_pfc_high_load, " seconds")
println("Computation time with PFC (Higher load): ", time_with_pfc_high_load, " seconds")
println("------------------------------")
println("Total losses as percentage of total generation")
println("Total losses without PFC (DC line 3 derating): ", total_load_no_pfc_derate, " %")
println("Total losses with PFC (DC line 3 derating): ", total_load_with_pfc_derate, " %")
println("Total losses without PFC (DC line 7 outage contingency): ", total_load_no_pfc_contingency, " %")
println("Total losses with PFC (DC line 7 outage contingency): ", total_load_with_pfc_contingency, " %")
println("Total losses without PFC (DC line 5 outage contingency): ", total_load_no_pfc_contingency_5, " %")
println("Total losses with PFC (DC line 5 outage contingency): ", total_load_with_pfc_contingency_5, " %")
println("Total losses without PFC (Higher load): ", total_load_no_pfc_high_load, " %")
println("Total losses with PFC (Higher load): ", total_load_with_pfc_high_load, " %")
println("------------------------------")
println("Energy Not Served [MW]")
println("Energy not served without PFC (DC line 3 derating): ", ens_no_pfc_derate, " MW")
println("Energy not served with PFC (DC line 3 derating): ", ens_with_pfc_derate, " MW")
println("Energy not served without PFC (DC line 7 outage contingency): ", ens_no_pfc_contingency, " MW")
println("Energy not served with PFC (DC line 7 outage contingency): ", ens_with_pfc_contingency, " MW")
println("Energy not served without PFC (DC line 5 outage contingency): ", ens_no_pfc_contingency_5, " MW")
println("Energy not served with PFC (DC line 5 outage contingency): ", ens_with_pfc_contingency_5, " MW")
println("Energy not served without PFC (Higher load): ", ens_no_pfc_high_load, " MW")
println("Energy not served with PFC (Higher load): ", ens_with_pfc_high_load, " MW")


### Testing of Redispatch OPF

data = _PM.parse_file("test/data/PFC/cigre_B4_test.m")
_PMACDC.process_additional_data!(data)

result = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt,; setting = s)

# Addition of N-1 contingency - DC line 7 outage
data_contingency = deepcopy(data)
data_contingency["branchdc"]["7"]["status"] = 0

rd_cost_factor = 2
# data_RD = _PMACDC.prepare_redispatch_opf_data(result,data_contingency)

grid_data_rd = deepcopy(data_contingency)
reference_solution = result["solution"]

for (g, gen) in grid_data_rd["gen"]
    if haskey(reference_solution["gen"], g)
        gen["pg"] = reference_solution["gen"][g]["pg"]
        if gen["pg"] == 0.0
            gen["dispatch_status"] = 0
        else
            gen["dispatch_status"] = 1
        end 
    else
        gen["dispatch_status"] = 0
    end
    
    # gen["rdcost_up"] = gen["cost"][1] * rd_cost_factor
    # gen["rdcost_down"] = gen["cost"][1] * rd_cost_factor * 0
    if g == "1" || g == "2"
        gen["rdcost_up"] = 100
        gen["rdcost_down"] = 70
    else
        gen["rdcost_up"] = 1000
        gen["rdcost_down"] = 1000
    end
end

for (l, load) in grid_data_rd["load"]
    if haskey(reference_solution["load"], l)
        load["pd"] = reference_solution["load"][l]["pflex"]
    end
end

for (c, conv) in grid_data_rd["convdc"]
    conv["P_g"] = -reference_solution["convdc"][c]["ptf_to"]
end

result_rd = _PMACDC.solve_rdopf(grid_data_rd, DCPPowerModel, ipopt,; setting = s)

gen_total_rd = sum(gen["pg"] for (g, gen) in result_rd["solution"]["gen"])
gen_total = sum(gen["pg"] for (g, gen) in result["solution"]["gen"])

load_total_rd = sum(load["pflex"] for (l, load) in result_rd["solution"]["load"])
load_total = sum(load["pflex"] for (l, load) in result["solution"]["load"])

grid_data_rd["branch"]
grid_data_rd["branchdc"]

## DC branch loading

loadingDC_rd = dc_loading(result_rd["solution"]["branchdc"], grid_data_rd)
loadingDC = dc_loading(result["solution"]["branchdc"], data)

gen_base = gen_matrix(result["solution"]["gen"])
ac_flow_base = ac_p_flow(result["solution"]["branch"])
dc_flow_base = dc_p_flow(result["solution"]["branchdc"])
conv_flow_base = conv_p_flow(result["solution"]["convdc"])

# ## base case in general power formulation
# data2 = _PM.parse_file("test/data/PFC/cigre_B4_test.m")
# _PMACDC.process_additional_data!(data2)
# result2 = _PMACDC.solve_acdcopf(data2, ACPPowerModel, ipopt,; setting = s)

# gen_2 = gen_matrix(result2["solution"]["gen"])
# ac_2 = ac_p_flow(result2["solution"]["branch"])
# dc_flow2 = dc_p_flow(result2["solution"]["branchdc"])
# conv_flow2 = conv_p_flow(result2["solution"]["convdc"])

# #KCL check
# # Node 1
# KCL_1 = result2["solution"]["branch"]["2"]["pt"] + result2["solution"]["convdc"]["1"]["pgrid"] + result2["solution"]["branch"]["1"]["pf"] + result2["solution"]["load"]["1"]["pflex"]
# KCL_2 = result2["solution"]["branch"]["1"]["pt"] + result2["solution"]["convdc"]["2"]["pgrid"] + result2["solution"]["branch"]["3"]["pt"] + result2["solution"]["load"]["2"]["pflex"]
# KLC_3 = result2["solution"]["gen"]["3"]["pg"] - result2["solution"]["convdc"]["3"]["pgrid"]
# KCL_4 = result2["solution"]["gen"]["4"]["pg"] - result2["solution"]["convdc"]["4"]["pgrid"]

## How to calculate pgrid in the IVR formulation?



gen = result["solution"]["gen"]

diff = result["objective"] - result_pfc["objective"]
diff_perct = diff / result["objective"] * 100 ## 3.7 percent improvement in objective value with PFC

#Total losses
total_loss_no_pfc = total_losses(data,result)
total_loss_pfc = total_losses(data_pfc,result_pfc)
diff_percent = (total_loss_pfc - total_loss_no_pfc) / total_loss_no_pfc * 100

#Gen matrix or vector
gen_no_pfc

diff_contingency = result_contingency["objective"] - result_pfc_contingency["objective"]
diff_contingency_perct = diff_contingency / result_contingency["objective"] * 100 ## 2.67 percent improvement in objective value with PFC under DC line 7 outage contingency

#Losses
total_loss_no_pfc = total_losses(data_contingency,result_contingency)
total_loss_pfc = total_losses(data_pfc_contingency,result_pfc_contingency)
diff_percent = (total_loss_pfc - total_loss_no_pfc) / total_loss_no_pfc * 100
# higher losses with PFC -> Makes sense as more RES is produced.


diff_contingency_5 = result_contingency_5["objective"] - result_pfc_contingency_5["objective"]
diff_contingency_5_perct = diff_contingency_5 / result_contingency_5["objective"] * 100 ## 2.89 percent improvement in objective value with PFC under DC line 5 outage contingency

#Total losses
total_loss_no_pfc_5 = total_losses(data_contingency_5,result_contingency_5)
total_loss_pfc_5 = total_losses(data_pfc_contingency_5,result_pfc_contingency_5)
diff_percent_5 = (total_loss_pfc_5 - total_loss_no_pfc_5) / total_loss_no_pfc_5 * 100








#Plot the results
# Plot generation
gen = result_no_pfc_base["solution"]["gen"]
gen = result_with_pfc_base["solution"]["gen"]





# load = result["solution"]["load"]
# load_d = data["load"]

branch_dc = result["solution"]["branchdc"]
converter = result["solution"]["convdc"]

ac_voltage = result["solution"]["bus"]

dc_voltage = result["solution"]["busdc"]

branch_ac = result["solution"]["branch"]

loadingDC = dc_loading(branch_dc,data)
loadingAC = ac_loading(branch_ac,data)

ac_voltages = voltage_ac(ac_voltage)
gen_output = gen_matrix(gen)





diff = result["objective"] - result_pfc["objective"]
diff_perct = diff / result["objective"] * 100

gen_pfc = result_pfc["solution"]["gen"]
branch_dc_pfc = result_pfc["solution"]["branchdc"]
converter_pfc = result_pfc["solution"]["convdc"]
ac_voltage_pfc = result_pfc["solution"]["bus"]
dc_voltage_pfc = result_pfc["solution"]["busdc"]
branch_ac_pfc= result_pfc["solution"]["branch"]

loadingDC_pfc = dc_loading(branch_dc_pfc,data_pfc)
loadingAC_pfc = ac_loading(branch_ac_pfc,data_pfc)
ac_voltages_pfc = voltage_ac(ac_voltage_pfc)
gen_output_pfc = gen_matrix(gen_pfc)


#### New CIGRE DC TEST Case
data_cigre = _PM.parse_file("test/data/PFC/cigre_B4_dc_grid.json")
data_cigre2 = _PM.parse_file("test/data/PFC/cigre_B4_dc_grid.m")

# data_cigre["bus"]
# data_cigre["busdc"]
# data_cigre["gen"]
# data_cigre["branch"]
# data_cigre["branchdc"]
# data_cigre["convdc"]["1"]
# data_cigre["load"]

_PMACDC.process_additional_data!(data_cigre)
_PMACDC.process_additional_data!(data_cigre2)

data_cigre["branchdc"]["5"]["status"] = 0

result_cigre = _PMACDC.solve_acdcopf(data_cigre, ACPPowerModel, ipopt,; setting = s)
result_cigre2 = _PMACDC.solve_acdcopf(data_cigre2, ACPPowerModel, ipopt,; setting = s)

dc_loading_cigre = dc_loading(result_cigre["solution"]["branchdc"], data_cigre)
ac_loading_cigre = ac_loading(result_cigre["solution"]["branch"], data_cigre)
gen_matrix_cigre = gen_matrix(result_cigre["solution"]["gen"])

#Print gen cost data
println("Generator cost data [JSON]:")
for (g, gen) in data_cigre["gen"]
    println("Generator ", g, ": Cost coefficients = ", gen["cost"])
end
println("Generator cost data [MATPOWER]:")
for (g, gen) in data_cigre2["gen"]
    println("Generator ", g, ": Cost coefficients = ", gen["cost"])
end


#### 24 hour simulation ####

load_profile = [
    0.85, 0.83, 0.81, 0.82, 0.83, 0.88, 0.99, 1.09,
    1.12, 1.12, 1.12, 1.13, 1.12, 1.09, 1.07, 1.05,
    1.05, 1.09, 1.10, 1.08, 1.03, 0.97, 0.92, 0.86
    ]

# Vectors to store results
time_steps = collect(1:length(load_profile))

data_24h_no_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
results_24h_no_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
solution_status_no_pfc = Vector{Any}(undef, length(time_steps))

data_24h_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
results_24h_pfc = Vector{Dict{String,Any}}(undef, length(time_steps))
solution_status_pfc = Vector{Any}(undef, length(time_steps))

data_no_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test.m")
_PMACDC.process_additional_data!(data_no_pfc)

data_pfc = _PM.parse_file("test/data/PFC/cigre_B4_test_PFC_B5.m")
_PMACDC.process_additional_data!(data_pfc)

scale_load!(data_no_pfc, data_24h_no_pfc, time_steps, load_profile)
scale_load!(data_pfc, data_24h_pfc, time_steps, load_profile)

# Running the 24-hour simulation without PFC
for t in time_steps
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_no_pfc[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_no_pfc[t] = results_24h_no_pfc[t]["termination_status"]
end

for t in time_steps
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_pfc[t] = _PMACDC.solve_acdcopf_iv(data_24h_pfc[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_pfc[t] = results_24h_pfc[t]["termination_status"]
end

# Objective values extraction
objective_values_no_pfc = [results_24h_no_pfc[t]["objective"] for t in time_steps]
objective_values_pfc = [results_24h_pfc[t]["objective"] for t in time_steps]

diff = [objective_values_no_pfc[t] - objective_values_pfc[t] for t in time_steps]
diff_perct = [diff[t] / objective_values_no_pfc[t] * 100 for t in time_steps]
sum_diff = sum(diff)

function hvdc_loading(data,result;threshold = 90)
    loaded = 0
    for (convdc_id,convdc) in result["solution"]["convdc"]
        ic_r = convdc["ic_r"]
        ic_i = convdc["ic_i"]
        imax = data["convdc"][convdc_id]["Imax"]
        loading = sqrt(ic_r^2 + ic_i^2) / imax * 100
        if loading > threshold
            loaded += 1
        end
    end
end

function branch_dc_loading(data,result;threshold = 90)
    loaded = 0
    for (branchdc_id, branchdc) in result["solution"]["branchdc"]
        pf = branchdc["pf"]
        pt = branchdc["pt"]
        rateA = data["branchdc"][branchdc_id]["rateA"]
        loading = max(abs(pf),abs(pt)) / rateA * 100
        if loading > threshold
            loaded += 1
        end
    end
end

function dc_bus_margin(data,result; threshold = 20)
    margin = 0
    for (busdc_id, busdc) in result["solution"]["busdc"]
        vm = busdc["vm"]
        vmin = data["busdc"][busdc_id]["Vdcmin"]
        vmax = data["busdc"][busdc_id]["Vdcmax"]
        margin_low = (vm - vmin) / vmin * 100
        margin_high = (vmax - vm) / vmax * 100
        if margin_low < threshold || margin_high < threshold
            margin += 1
        end
    end
    return margin
end

function dc_loading(branch_dc,data)
    loading = Dict()
    for (branchdc_id, branchdc_data) in branch_dc
        from_bus = data["branchdc"][branchdc_id]["fbusdc"]
        to_bus = data["branchdc"][branchdc_id]["tbusdc"]
        pf = branchdc_data["pf"] # Active power flow from 'from_bus' to 'to_bus'
        pt = branchdc_data["pt"] # Active power flow from 'to_bus' to 'from_bus'
        rateA = data["branchdc"][branchdc_id]["rateA"] # Thermal limit of the DC branch
        loading[branchdc_id] = max(abs(pf),abs(pt)) / rateA * 100 # Calculate loading percentage
    end
    return loading
end

function dc_p_flow(branch_dc)
    flow = Dict()
    for (branchdc_id,branchdc_data) in branch_dc
        from = branchdc_data["pf"]
        to = branchdc_data["pt"]
        flow[branchdc_id] = (from, to)
    end
    return flow
end

function ac_loading(branch_ac,data)
    loading = Dict()
    for (branch_id, branch_data) in branch_ac
        from_bus = data["branch"][branch_id]["f_bus"] # From bus ID
        to_bus = data["branch"][branch_id]["t_bus"] # To bus ID
        pf = branch_data["pf"] # Active power flow from 'from_bus' to 'to_bus'
        pt = branch_data["pt"] # Active power flow from 'to_bus' to 'from_bus'
        rate_a = data["branch"][branch_id]["rate_a"] # Thermal limit of the AC branch
        loading[branch_id] = max(abs(pf),abs(pt)) / rate_a * 100 # Calculate loading percentage
    end
    return loading
end

function ac_p_flow(branch_ac)
    flow = Dict()
    for (branch_id,branch_data) in branch_ac
        from = branch_data["pf"]
        to = branch_data["pt"]
        flow[branch_id] = (from, to)
    end
    return flow
end

function voltage_ac(ac_voltage)
    voltage = Dict()
    for (bus_id, bus_data) in ac_voltage
        vr = bus_data["vr"] # Real part of voltage
        vi = bus_data["vi"] # Imaginary part of voltage
        voltage[bus_id] = sqrt(vr^2 + vi^2) # Calculate voltage magnitude
        # voltage[bus_id]["va"] = atan(vi, vr) * (180 / pi) # Calculate voltage angle in degrees
    end
    return voltage
end

function gen_matrix(gen)
    gen_matrix = Dict()
    for (gen_id, gen_data) in gen
        gen_matrix[gen_id] = (gen_data["pg"], gen_data["qg"]) # Active and reactive power generation
    end
    return gen_matrix
end

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

function total_losses(data,result)
    total_gen = sum(gen_data["pg"] for (gen_id, gen_data) in result["solution"]["gen"])
    total_load = sum(load_data["pd"] for (load_id, load_data) in data["load"])
    total_loss = (total_gen - total_load) / total_gen * 100
    return total_loss
end

function conv_p_flow(convdc)
    flow = Dict()
    for (conv_id, convdc) in convdc
        pdc = convdc["pdc"] # Active power flow through the converter
        pconv = convdc["pconv"] # Active power flow on the AC side of the converter
        flow[conv_id] = (pdc, pconv)
    end
    return flow
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
                "qmax" => 0,
                "qmin" => 0,
                "vg" => bus["vm"],
                "mbase" => 100.0,
                "gen_status" => 1,
                "pmax" => data["load"][bus_id]["pd"],  # Use load value from data["load"]
                "pmin" => 0.0,
                "cost" => [VOLL , 0],  # Quadratic cost function with high marginal cost
                "ncost" => 2,
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

function check_ens_activation(data_24h, results_24h, time_steps)
    ENS_activity = Dict{Int, Dict{Int, Float64}}()
    for t in time_steps
        activated = Dict{Int, Float64}()
        for (gen_id,gen) in results_24h[t]["solution"]["gen"]
            gen_index = data_24h[t]["gen"]["$gen_id"]["index"]
                if gen_index > 20 && gen["pg"] > 0
                    activated[gen_index] = gen["pg"]
                end
        end
        ENS_activity[t] = activated
    end
   return ENS_activity
end

function check_ens_activation_matrix(data_24h, results_24h, time_steps)
    ENS_activity = Dict{Int, Dict{Int, Dict{Int,Float64}}}()
    for t in time_steps
        ENS_activity[t] = Dict{Int, Dict{Int,Float64}}()
        for c in axes(results_24h,2)
            activated = Dict{Int, Float64}()
            for (gen_id,gen) in results_24h[t,c]["solution"]["gen"]
                gen_index = data_24h[t]["gen"]["$gen_id"]["index"]
                    if gen_index > 20 && gen["pg"] > 0
                        activated[gen_index] = gen["pg"]
                    end
            end
            ENS_activity[t][c] = activated
        end
    end
   return ENS_activity
end

function check_ENS(data_24h,results_24h;tol=1e-6)
    T,C = size(results_24h)

    ENS_bool = falses(T,C)
    ENS_total = zeros(T,C)

    for t in 1:T
        for c in 1:C
            total_ens = 0.0

            for (gen_id,gen) in results_24h[t,c]["solution"]["gen"]
                gen_index = data_24h[t]["gen"]["$gen_id"]["index"]
                    if gen_index > 20 && gen["pg"] > tol
                        total_ens += gen["pg"]
                    end
            end
            ENS_total[t,c] = total_ens
            ENS_bool[t,c] = total_ens > 0
        end
    end
    return ENS_bool, ENS_total
end

function check_termination_status(results)
    C = length(results)
    termination_status = []
    for c in 1:C
        status = string(results[c]["termination_status"])
        if status != "LOCALLY_SOLVED"
            push!(termination_status, (t,c,status))
        end
    end
    return termination_status
end