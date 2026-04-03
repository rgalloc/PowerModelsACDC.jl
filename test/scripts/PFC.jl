using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots
using DataFrames

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0) # Changed tolerance to 1e-8 from 1e-6
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

#### Test case for 67 bus using several scenarios to work with congestion

# Scenarions without PFC

# Scenario 0: Base case
data0_0 = _PM.parse_file("test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data0_0)

# Scenario 1-11: Derate DC branches by 50%
dc_branch_ids = keys(data0_0["branchdc"])
data_s1_0 = Dict{Any,Dict{String,Any}}()
for branch_id in dc_branch_ids
    data1_0 = _PM.parse_file("test/data/PFC/case67.m")
    _PMACDC.process_additional_data!(data1_0)
    derate_branchdc!(data1_0, branch_id, 0.5)
    data_s1_0[branch_id] = data1_0
end

# Scenario 12-22: Outage DC branches
data_s2_0 = Dict{Any,Dict{String,Any}}()
for branch_id in dc_branch_ids
    data2_0 = _PM.parse_file("test/data/PFC/case67.m")
    _PMACDC.process_additional_data!(data2_0)
    outage_branchdc!(data2_0, branch_id)
    data_s2_0[branch_id] = data2_0
end

# Scenario 23: Increase load by 10%
data_s3_0 = _PM.parse_file("test/data/PFC/case67.m")
_PMACDC.process_additional_data!(data_s3_0)
increase_load!(data_s3_0, 1.15)

# Scenario 24-33: Outage HVDC converters
data_s4_0 = Dict{Any,Dict{String,Any}}()
for converter_id in keys(data0_0["convdc"])
    data4_0 = _PM.parse_file("test/data/PFC/case67.m")
    _PMACDC.process_additional_data!(data4_0)
    outage_hvdc_converter!(data4_0, converter_id)
    data_s4_0[converter_id] = data4_0
end

# Run the scenarios
results_0 = Dict{String,Any}()
termination_status_0 = Dict{String,Any}()
OF_0 = Dict{String,Any}()
dc_congestion_0 = Dict{String,Any}()

results_0["base_case"] = _PMACDC.solve_acdcopf_iv(data0_0, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
termination_status_0["base_case"] = results_0["base_case"]["termination_status"]
OF_0["base_case"] = results_0["base_case"]["objective"]
dc_congestion_0["base_case"] = calculate_dc_branch_congestion(results_0["base_case"], data0_0)

for (branch_id, data1_0) in data_s1_0
    results_0["derate_branchdc_$(branch_id)"] = _PMACDC.solve_acdcopf_iv(data1_0, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_0["derate_branchdc_$(branch_id)"] = results_0["derate_branchdc_$(branch_id)"]["termination_status"]
    OF_0["derate_branchdc_$(branch_id)"] = results_0["derate_branchdc_$(branch_id)"]["objective"]
    dc_congestion_0["derate_branchdc_$(branch_id)"] = calculate_dc_branch_congestion(results_0["derate_branchdc_$(branch_id)"], data1_0)
end

for (branch_id, data2_0) in data_s2_0
    results_0["outage_branchdc_$(branch_id)"] = _PMACDC.solve_acdcopf_iv(data2_0, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_0["outage_branchdc_$(branch_id)"] = results_0["outage_branchdc_$(branch_id)"]["termination_status"]
    OF_0["outage_branchdc_$(branch_id)"] = results_0["outage_branchdc_$(branch_id)"]["objective"]
    dc_congestion_0["outage_branchdc_$(branch_id)"] = calculate_dc_branch_congestion(results_0["outage_branchdc_$(branch_id)"], data2_0)
end

for (converter_id, data4_0) in data_s4_0
    results_0["outage_hvdc_converter_$(converter_id)"] = _PMACDC.solve_acdcopf_iv(data4_0, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_0["outage_hvdc_converter_$(converter_id)"] = results_0["outage_hvdc_converter_$(converter_id)"]["termination_status"]
    OF_0["outage_hvdc_converter_$(converter_id)"] = results_0["outage_hvdc_converter_$(converter_id)"]["objective"]
    dc_congestion_0["outage_hvdc_converter_$(converter_id)"] = calculate_dc_branch_congestion(results_0["outage_hvdc_converter_$(converter_id)"], data4_0)
end

results_0["increase_load_10pct"] = _PMACDC.solve_acdcopf_iv(data_s3_0, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
termination_status_0["increase_load_10pct"] = results_0["increase_load_10pct"]["termination_status"]
OF_0["increase_load_10pct"] = results_0["increase_load_10pct"]["objective"]
dc_congestion_0["increase_load_10pct"] = calculate_dc_branch_congestion(results_0["increase_load_10pct"], data_s3_0)


###### With PFC
## Same scenarios but with PFC in DC Bus 1

test_case_file = "test/data/PFC/case67_PFC_B8.m"

#Scenario 0: Base case with PFC
data0_1 = _PM.parse_file(test_case_file)
_PMACDC.process_additional_data!(data0_1)

# Scenario 1-11: Derate DC branches by 50%
data_s1_1 = Dict{Any,Dict{String,Any}}()
for branch_id in dc_branch_ids
    data1_1 = _PM.parse_file(test_case_file)
    _PMACDC.process_additional_data!(data1_1)
    derate_branchdc!(data1_1, branch_id, 0.5)
    data_s1_1[branch_id] = data1_1
end

# Scenario 12-22: Outage DC branches
data_s2_1 = Dict{Any,Dict{String,Any}}()
for branch_id in dc_branch_ids
    data2_1 = _PM.parse_file(test_case_file)
    _PMACDC.process_additional_data!(data2_1)
    outage_branchdc!(data2_1, branch_id)
    data_s2_1[branch_id] = data2_1
end

# Scenario 23: Increase load by 10%
data_s3_1 = _PM.parse_file(test_case_file)
_PMACDC.process_additional_data!(data_s3_1)
increase_load!(data_s3_1, 1.15)

#Scenario 24-33: Outage HVDC converters
data_s4_1 = Dict{Any,Dict{String,Any}}()
for converter_id in keys(data0_1["convdc"])
    data4_1 = _PM.parse_file(test_case_file)
    _PMACDC.process_additional_data!(data4_1)
    outage_hvdc_converter!(data4_1, converter_id)
    data_s4_1[converter_id] = data4_1
end

# Run the scenarios with PFC
results_1 = Dict{String,Any}()
termination_status_1 = Dict{String,Any}()
OF_1 = Dict{String,Any}()
dc_congestion_1 = Dict{String,Any}()
ac_congestion_1 = Dict{String,Any}()

results_1["base_case"] = _PMACDC.solve_acdcopf_iv(data0_1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
termination_status_1["base_case"] = results_1["base_case"]["termination_status"]
OF_1["base_case"] = results_1["base_case"]["objective"]
dc_congestion_1["base_case"] = calculate_dc_branch_congestion(results_1["base_case"], data0_1)

for (branch_id, data1_1) in data_s1_1
    results_1["derate_branchdc_$(branch_id)"] = _PMACDC.solve_acdcopf_iv(data1_1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_1["derate_branchdc_$(branch_id)"] = results_1["derate_branchdc_$(branch_id)"]["termination_status"]
    OF_1["derate_branchdc_$(branch_id)"] = results_1["derate_branchdc_$(branch_id)"]["objective"]
    dc_congestion_1["derate_branchdc_$(branch_id)"] = calculate_dc_branch_congestion(results_1["derate_branchdc_$(branch_id)"], data1_1)
end

for (branch_id, data2_1) in data_s2_1
    results_1["outage_branchdc_$(branch_id)"] = _PMACDC.solve_acdcopf_iv(data2_1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_1["outage_branchdc_$(branch_id)"] = results_1["outage_branchdc_$(branch_id)"]["termination_status"]
    OF_1["outage_branchdc_$(branch_id)"] = results_1["outage_branchdc_$(branch_id)"]["objective"]
    dc_congestion_1["outage_branchdc_$(branch_id)"] = calculate_dc_branch_congestion(results_1["outage_branchdc_$(branch_id)"], data2_1)
end

for (converter_id, data4_1) in data_s4_1
    results_1["outage_hvdc_converter_$(converter_id)"] = _PMACDC.solve_acdcopf_iv(data4_1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
    termination_status_1["outage_hvdc_converter_$(converter_id)"] = results_1["outage_hvdc_converter_$(converter_id)"]["termination_status"]
    OF_1["outage_hvdc_converter_$(converter_id)"] = results_1["outage_hvdc_converter_$(converter_id)"]["objective"]
    dc_congestion_1["outage_hvdc_converter_$(converter_id)"] = calculate_dc_branch_congestion(results_1["outage_hvdc_converter_$(converter_id)"], data4_1)
end

results_1["increase_load_10pct"] = _PMACDC.solve_acdcopf_iv(data_s3_1, _PM.IVRPowerModel, Ipopt.Optimizer; setting = s)
termination_status_1["increase_load_10pct"] = results_1["increase_load_10pct"]["termination_status"]
OF_1["increase_load_10pct"] = results_1["increase_load_10pct"]["objective"]
dc_congestion_1["increase_load_10pct"] = calculate_dc_branch_congestion(results_1["increase_load_10pct"], data_s3_1)
ac_congestion_1["increase_load_10pct"] = calculate_ac_branch_congestion(results_1["increase_load_10pct"], data_s3_1)

# Saving results
# # B1 
# results_B1 = Dict{String,Any}()
# termination_status_B1 = Dict{String,Any}()
# OF_B1 = Dict{String,Any}()
# dc_congestion_B1 = Dict{String,Any}()

# results_B1 = results_1
# termination_status_B1 = termination_status_1
# OF_B1 = OF_1
# dc_congestion_B1 = dc_congestion_1

# #B2
# results_B2 = Dict{String,Any}()
# termination_status_B2 = Dict{String,Any}()
# OF_B2 = Dict{String,Any}()
# dc_congestion_B2 = Dict{String,Any}()

# results_B2 = results_1
# termination_status_B2 = termination_status_1
# OF_B2 = OF_1
# dc_congestion_B2 = dc_congestion_1

# # B3
# results_B3 = Dict{String,Any}()
# termination_status_B3 = Dict{String,Any}()
# OF_B3 = Dict{String,Any}()
# dc_congestion_B3 = Dict{String,Any}()
# results_B3 = results_1
# termination_status_B3 = termination_status_1
# OF_B3 = OF_1
# dc_congestion_B3 = dc_congestion_1

# # B4
# results_B4 = Dict{String,Any}()
# termination_status_B4 = Dict{String,Any}()
# OF_B4 = Dict{String,Any}()
# dc_congestion_B4 = Dict{String,Any}()
# results_B4 = results_1
# termination_status_B4 = termination_status_1
# OF_B4 = OF_1
# dc_congestion_B4 = dc_congestion_1

# # B5
# results_B5 = Dict{String,Any}()
# termination_status_B5 = Dict{String,Any}()
# OF_B5 = Dict{String,Any}()
# dc_congestion_B5 = Dict{String,Any}()
# results_B5 = results_1
# termination_status_B5 = termination_status_1
# OF_B5 = OF_1
# dc_congestion_B5 = dc_congestion_1

# # B6
# results_B6 = Dict{String,Any}()
# termination_status_B6 = Dict{String,Any}()
# OF_B6 = Dict{String,Any}()
# dc_congestion_B6 = Dict{String,Any}()
# results_B6 = results_1
# termination_status_B6 = termination_status_1
# OF_B6 = OF_1
# dc_congestion_B6 = dc_congestion_1

# # B7
# results_B7 = Dict{String,Any}()
# termination_status_B7 = Dict{String,Any}()
# OF_B7 = Dict{String,Any}()
# dc_congestion_B7 = Dict{String,Any}()
# results_B7 = results_1
# termination_status_B7 = termination_status_1
# OF_B7 = OF_1
# dc_congestion_B7 = dc_congestion_1

# B8
results_B8 = Dict{String,Any}()
termination_status_B8 = Dict{String,Any}()
OF_B8 = Dict{String,Any}()
dc_congestion_B8 = Dict{String,Any}()
results_B8 = results_1
termination_status_B8 = termination_status_1
OF_B8 = OF_1
dc_congestion_B8 = dc_congestion_1


# ## Plotting results
# scenarios = collect(keys(OF_0))

# values_0 = [OF_0[scenario] for scenario in scenarios]
# values_b1 = [OF_1[scenario] for scenario in scenarios]

# values_base_diff = zeros(length(scenarios))
# values_b1_diff = values_b1 .- values_0

# check_data = hcat(values_0, values_b1)
# plot_data = hcat(values_base_diff,
#                  values_b1_diff)
#                 #  values_b2_diff, 
#                 #  values_b3_diff, 
#                 #  values_b4_diff, 
#                 #  values_b5_diff, 
#                 #  values_b6_diff, 
#                 #  values_b7_diff, 
#                 #  values_b8_diff)

# heatmap(
#     plot_data,
#     xlabel = "PFC location",
#     ylabel = "Scenarios",
#     title = "PFC Location vs Scenario Impact",
#     xticks = (1:2, ["No PFC", "With PFC"]),
#     yticks = (1:length(scenarios), scenarios),
#     color = :jet,
#     clims = (-1,1)
# )

# heatmap(
#     plot_data,
#     xlabel = "PFC location",
#     ylabel = "Scenarios",
#     title = "PFC Location vs Scenario Impact",
#     xticks = (1:9, ["No PFC", "Bus 1", "Bus 2", "Bus 3", "Bus 4", "Bus 5", "Bus 6", "Bus 7", "Bus 8"]),
#     yticks = (1:length(scenarios), scenarios),
#     color = :jet,
#     #clims = (-1,1)
# )













# Compute the economic benefits
economic_benefits_B1 = calculate_economic_benefits(OF_0, OF_B1)
total_benefit_B1 = total_economic_benefit(economic_benefits_B1)

economic_benefits_B2 = calculate_economic_benefits(OF_0, OF_B2)
total_benefit_B2 = total_economic_benefit(economic_benefits_B2)

economic_benefits_B3 = calculate_economic_benefits(OF_0, OF_B3)
total_benefit_B3 = total_economic_benefit(economic_benefits_B3)

economic_benefits_B4 = calculate_economic_benefits(OF_0, OF_B4)
total_benefit_B4 = total_economic_benefit(economic_benefits_B4)

economic_benefits_B5 = calculate_economic_benefits(OF_0, OF_B5)
total_benefit_B5 = total_economic_benefit(economic_benefits_B5)

economic_benefits_B6 = calculate_economic_benefits(OF_0, OF_B6)
total_benefit_B6 = total_economic_benefit(economic_benefits_B6)

economic_benefits_B7 = calculate_economic_benefits(OF_0, OF_B7)
total_benefit_B7 = total_economic_benefit(economic_benefits_B7)

economic_benefits_B8 = calculate_economic_benefits(OF_0, OF_B8)
total_benefit_B8 = total_economic_benefit(economic_benefits_B8)

# Extract duty cycle values for all scenarios
pfc_vars_1 = Dict{String,Any}()
d_1 = Dict{String,Any}()
e_1 = Dict{String,Any}()
for (scenario, result) in results_B2
    pfc_vars_1[scenario] = result["solution"]["pfc"]
    d_1[scenario] = pfc_vars_1[scenario]["1"]["duty_cycle"]
    e_1[scenario] = pfc_vars_1[scenario]["1"]["c_voltage"]
end

### Scenario selection
sel = ["base_case", "derate_branchdc_1", "outage_branchdc_10", "increase_load_10pct", "outage_hvdc_converter_1"]

print_dc_branches_flow(results_0[sel[1]],data0_0)
print_dc_branches_flow(results_1[sel[1]],data0_1)

print_dc_branches_flow(results_0[sel[2]],data_s1_0["1"])
print_dc_branches_flow(results_1[sel[2]],data_s1_1["1"])
d_1[sel[2]]

print_dc_branches_flow(results_0[sel[3]],data_s2_0["10"])
print_dc_branches_flow(results_1[sel[3]],data_s2_1["10"])
d_1[sel[3]]





## Helper functions

# Derate branch DC capacity
function derate_branchdc!(data,branch_id,derate_factor)
    data["branchdc"][branch_id]["rateA"] *= derate_factor
    data["branchdc"][branch_id]["rateB"] *= derate_factor
    data["branchdc"][branch_id]["rateC"] *= derate_factor
end

# Outage of branch DC
function outage_branchdc!(data,branch_id)
    data["branchdc"][branch_id]["status"] = 0
end

#Outage of HVDC converter
function outage_hvdc_converter!(data,converter_id)
    data["convdc"][converter_id]["status"] = 0
end

# Increase system load by a factor
function increase_load!(data,load_factor)
    for (load_id, load) in data["load"]
        load["pd"] *= load_factor
        load["qd"] *= load_factor
    end
end

# Derate HVDC converters
function derate_hvdc_converter!(data,converter_id,derate_factor)
    data["hvdc_converter"][converter_id]["pmax"] *= derate_factor
    data["hvdc_converter"][converter_id]["pmin"] *= derate_factor
end

# Congestion calculation functions

# Congestion DC branches
function calculate_dc_branch_congestion(results,data; tol=1e-3, near=0.9)
    congested_branches = Dict{Any, Any}()
    for (branchdc_id, branchdc) in results["solution"]["branchdc"]
        flow = abs(max(branchdc["pf"], branchdc["pt"]))
        capacity = data["branchdc"][branchdc_id]["rateA"]
        utilization = flow / capacity
        if utilization >= near## && (flow - capacity) > tol
            congested_branches[branchdc_id] = Dict("flow" => flow, "capacity" => capacity, "utilization" => utilization)
        end
    end
    return congested_branches
end

# Congestion AC branches
function calculate_ac_branch_congestion(results,data; tol=1e-3, near=0.9)
    congested_branches = Dict{Any, Any}()
    for (branch_id, branch) in results["solution"]["branch"]
        flow = abs(max(branch["pf"], branch["pt"]))
        capacity = data["branch"][branch_id]["rate_a"]
        utilization = flow / capacity
        if utilization >= near## && (flow - capacity) > tol
            congested_branches[branch_id] = Dict("flow" => flow, "capacity" => capacity, "utilization" => utilization)
        end
    end
    return congested_branches
end

# Congestion HVDC converters # TODO
# function calculate_hvdc_converter_congestion(results; tol=1e-3, near=0.9)
#     congested_converters = Dict{Int, Float64}()
#     for (converter_id, converter) in results["hvdc_converter"]
#         flow = abs(converter["p"])
#         capacity = converter["pmax"]
#         utilization = flow / capacity
#         if utilization >= near## && (flow - capacity) > tol
#             congested_converters[converter_id] = Dict("flow" => flow, "capacity" => capacity, "utilization" => utilization)
#         end
#     end
#     return congested_converters
# end

# Calculate economic benefits
function calculate_economic_benefits(OF_no_pfc, OF_with_pfc)
    benefits = Dict{String, Any}()
    for (scenario, of_no_pfc) in OF_no_pfc
        if haskey(OF_with_pfc, scenario)
            of_with_pfc = OF_with_pfc[scenario]
            benefit = of_no_pfc - of_with_pfc
            benefit_percent = (benefit / of_no_pfc) * 100
            benefits[scenario] = Dict("benefit" => benefit, "benefit_percent" => benefit_percent)
        end
    end
    return benefits
end

function total_economic_benefit(economic_benefits)
    total_benefit = 0.0
    for (scenario, benefit_info) in economic_benefits
        total_benefit += benefit_info["benefit"]
    end
    return total_benefit
end

function print_dc_branches_flow(results, data)
    branchdc = results["solution"]["branchdc"]
    println("DC Branch Flows:")
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
end


function add_ens_gens!(data; VOLL = 100000)
    max_gen_id = maximum(parse.(Int, keys(data["gen"])))
    ens_gen_id = 1
    for (bus_id, bus) in data["bus"]
        # Check if the load exists for the bus
        if haskey(data["load"], bus_id)
            ens_gen_key = string(max_gen_id + ens_gen_id)
            data["gen"][ens_gen_key] = Dict(
                "gen_bus" => bus_id,
                "pg" => 0.0,
                "qg" => 0.0,
                "qmax" => 100.0,
                "qmin" => -100.0,
                "vg" => bus["vm"],
                "mbase" => 100.0,
                "gen_status" => 1,
                "pmax" => data["load"][bus_id]["pd"],  # Use load value from data["load"]
                "pmin" => 0.0,
                "cost" => [VOLL , 0],  # Quadratic cost function with high marginal cost
                "ncost" => 3,
                "model" => 2,
                "shutdown" => 0,
                "startup" => 0,
                "source_id" => Any["gen", ens_gen_id],
                "index" => ens_gen_id
            )
            ens_gen_id += 1
        end
    end
end
