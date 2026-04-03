using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no")


load_profile = [
    0.80, 0.82, 0.84, 0.86, 0.88, 0.90, 0.92, 0.94,
    0.96, 0.98, 1.00, 1.02, 1.04, 1.06, 1.08, 1.10,
    1.12, 1.14
]

# Vectors to store results
time_steps_67bus = collect(1:length(load_profile))

data_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
solution_status_no_pfc_67bus = Vector{Any}(undef, length(time_steps_67bus))


### No PFC data
# Loading data
data_no_pfc_67bus = _PM.parse_file("./test/data/PFC/case67.m")
#Processing additional data
_PMACDC.process_additional_data!(data_no_pfc_67bus)
add_ens_gens!(data_no_pfc_67bus)

result = _PMACDC.solve_acdcopf_iv(data_no_pfc_67bus, _PM.IVRPowerModel, ipopt ; setting = s)
#print ENS output
for (gen_id, gen_data) in result["solution"]["gen"]
    if data_no_pfc_67bus["gen"]["$gen_id"]["index"] > 20
        println("ENS Gen ID: $gen_id, Output: $(gen_data["pg"]) pu")
    end
end

# Scale load and wind generation
# scale_load_wind!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)
scale_load_ens!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)

# Running the 24-hour simulation without PFC
for t in time_steps_67bus
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
    results_24h_no_pfc_67bus[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus[t], _PM.IVRPowerModel, ipopt; setting = s)
    solution_status_no_pfc_67bus[t] = results_24h_no_pfc_67bus[t]["termination_status"]
end

#Check ENS Gens
ens_outputs = zeros(Float64, length(load_profile), 37)
compute_ens_gen_matrix!(data_24h_no_pfc_67bus, results_24h_no_pfc_67bus, time_steps_67bus, ens_outputs)


# #### loads and ENS gen addition

# data_test = _PM.parse_file("./test/data/PFC/case67.m")

# data_test["load"]
# data_test["gen"]["1"]

# data = deepcopy(data_test)
# _PMACDC.process_additional_data!(data)
# add_ens_gens!(data)

# scale_load_ens!(data,data_24h_no_pfc_67bus,time_steps_67bus,load_profile)

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

function compute_ens_gen_matrix!(data_24h, results_24h, time_steps, ens_outputs)
    for t in time_steps
        for (gen_id, gen) in results_24h[t]["solution"]["gen"]
            if data_24h[t]["gen"]["$gen_id"]["index"] > 20
                ens_outputs[t, data_24h[t]["gen"]["$gen_id"]["index"] - 20] = max.(gen["pg"],0)
            end
        end
    end
end

function print_dc_branch_currents(results_24h_no_pfc, time_steps)
    for t in time_steps
        println("DC Branch Currents at time step $t:")
        for (branchdc_id, branchdc) in results_24h_no_pfc[t]["solution"]["branchdc"]
            current = branchdc["if"]
            direction = 0
            if branchdc["if"] > 0
                direction = 1
            else                
                direction = -1
            end
            println("Branch ID: $branchdc_id, Current: $current A, Direction: $direction")
        end
    end
end

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

function scale_load_ens!(data, data_24h, time_steps, p_mult)
    for t in time_steps
        data_copy = deepcopy(data)
        for (load_id, load_data) in data_copy["load"]
            load_data["pd"] *= p_mult[t]
            # load_data["qd"] *= p_mult[t]
        end
        for (gen_id, gen) in data_copy["gen"]
            if gen["index"] > 20
                gen["pmax"] *= p_mult[t]
            end
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

    return total_diff_percent
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

function compute_DC_branch_loading_24h(results_24h, data_24h, time_steps, DC_branch_loading ; threshold=90) 
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
            # gen_index = parse(Int, gen_id)
            gen_outputs_matrix[t, gen_data["index"]] = gen_data["pg"]
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