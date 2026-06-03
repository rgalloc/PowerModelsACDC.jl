using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt
using Plots
import HSL_jll

# data = _PM.parse_file("./test/data/PFC/case67.m")
# AC_branch = ["4","5","13","22","26","34","41","42","46","81"]

# for b in AC_branch
#     br = data["branch"][b]
#     println("branch $b: f_bus=$(br["f_bus"]) t_bus=$(br["t_bus"])")
# end

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
lsolver = "ma57"
warm = "no"
level = 0 #Print level for ipopt

## Simulations to run 67 bus system for 24 and 8760 hour horizon with and without PFCs

t = @elapsed begin

load_profile = [
    0.85, 0.83, 0.81, 0.82, 0.83, 0.88, 0.99, 1.09,
    1.12, 1.12, 1.12, 1.13, 1.12, 1.09, 1.07, 1.05,
    1.05, 1.09, 1.10, 1.08, 1.03, 0.97, 0.92, 0.86
    ]


# load_profile = [
#     0.80, 0.82, 0.84, 0.86, 0.88, 0.90, 0.92, 0.94,
#     0.96, 0.98, 1.00, 1.02, 1.04, 1.06, 1.08, 1.10,
#     1.12, 1.14
# ]

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

# Vectors to store results
time_steps_67bus = collect(1:length(load_profile))

## AC Contingency index
ac_branches = ["4","5","13","22","26","34","41","42","46","81"]
dc_branches = ["1","2","3","4","5","6","7","8","9","10"]
n_cont = length(ac_branches) + length(dc_branches) + 1 # +1 for base case

##### PFC Run for 24-h horizon ##########

# No PFC
data_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_no_pfc_67bus = Matrix{Dict{String,Any}}(undef, length(time_steps_67bus), n_cont)

# PFC Bus 2
data_24h_with_pfc_67bus_B2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_B2 = Matrix{Dict{String,Any}}(undef, length(time_steps_67bus), n_cont)

# PFC Bus 3
data_24h_with_pfc_67bus_B3 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_B3 = Matrix{Dict{String,Any}}(undef, length(time_steps_67bus), n_cont)
# PFC Bus 4
data_24h_with_pfc_67bus_B4 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_B4 = Matrix{Dict{String,Any}}(undef, length(time_steps_67bus), n_cont)
# PFC bus 8
data_24h_with_pfc_67bus_B8 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
results_24h_with_pfc_67bus_B8 = Matrix{Dict{String,Any}}(undef, length(time_steps_67bus), n_cont)

#### Loading data

# No PFC
data_no_pfc_67bus = _PM.parse_file("./test/data/PFC/case67.m")
#Processing additional data
_PMACDC.process_additional_data!(data_no_pfc_67bus)
add_ens_gens!(data_no_pfc_67bus; VOLL = 20000)

# PFC Bus 2
data_with_pfc_67bus_B2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
#Processing additional data
_PMACDC.process_additional_data!(data_with_pfc_67bus_B2)
add_ens_gens!(data_with_pfc_67bus_B2; VOLL = 20000)

# PFC Bus 3
data_with_pfc_67bus_B3 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
#Processing additional data
_PMACDC.process_additional_data!(data_with_pfc_67bus_B3)
add_ens_gens!(data_with_pfc_67bus_B3; VOLL = 20000)

# PFC Bus 4
data_with_pfc_67bus_B4 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
#Processing additional data
_PMACDC.process_additional_data!(data_with_pfc_67bus_B4)
add_ens_gens!(data_with_pfc_67bus_B4; VOLL = 20000)

# PFC bus 8
data_with_pfc_67bus_B8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
#Processing additional data
_PMACDC.process_additional_data!(data_with_pfc_67bus_B8)
add_ens_gens!(data_with_pfc_67bus_B8; VOLL = 20000)

## Scaling the data with load profile and ENS generators

scale_load_ens!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)
scale_load_ens!(data_with_pfc_67bus_B2, data_24h_with_pfc_67bus_B2, time_steps_67bus, load_profile)
scale_load_ens!(data_with_pfc_67bus_B3, data_24h_with_pfc_67bus_B3, time_steps_67bus, load_profile)
scale_load_ens!(data_with_pfc_67bus_B4, data_24h_with_pfc_67bus_B4, time_steps_67bus, load_profile)
scale_load_ens!(data_with_pfc_67bus_B8, data_24h_with_pfc_67bus_B8, time_steps_67bus, load_profile)

# scale_load_ens_wind!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load_ens_wind!(data_with_pfc_67bus_B2, data_24h_with_pfc_67bus_B2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load_ens_wind!(data_with_pfc_67bus_B3, data_24h_with_pfc_67bus_B3, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load_ens_wind!(data_with_pfc_67bus_B4, data_24h_with_pfc_67bus_B4, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# scale_load_ens_wind!(data_with_pfc_67bus_B8, data_24h_with_pfc_67bus_B8, time_steps_67bus, load_profile, CF_ON, CF_OFF)

## Base case results

for t in time_steps_67bus
    #NO PFC
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
    results_24h_no_pfc_67bus[t, 1] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus[t], _PM.IVRPowerModel, ipopt; setting = s)
    # PFC Bus 2
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
    results_24h_with_pfc_67bus_B2[t, 1] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B2[t], _PM.IVRPowerModel, ipopt; setting = s)
    # PFC Bus 3
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
    results_24h_with_pfc_67bus_B3[t, 1] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B3[t], _PM.IVRPowerModel, ipopt; setting = s)
    # PFC Bus 4
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
    results_24h_with_pfc_67bus_B4[t, 1] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B4[t], _PM.IVRPowerModel, ipopt; setting = s)
    # PFC Bus 8
    ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
    results_24h_with_pfc_67bus_B8[t, 1] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B8[t], _PM.IVRPowerModel, ipopt; setting = s)
end

# DC contingencies

for t in time_steps_67bus
    for (i,dc) in enumerate(dc_branches)
        c = 1 + i
        # No PFC
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
        data_run = deepcopy(data_24h_no_pfc_67bus[t])
        data_run["branchdc"][dc]["status"] = 0
        results_24h_no_pfc_67bus[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 2
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B2[t])
        data_run["branchdc"][dc]["status"] = 0
        results_24h_with_pfc_67bus_B2[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 3
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B3[t])
        data_run["branchdc"][dc]["status"] = 0
        results_24h_with_pfc_67bus_B3[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 4
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B4[t])
        data_run["branchdc"][dc]["status"] = 0
        results_24h_with_pfc_67bus_B4[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 8
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B8[t])
        data_run["branchdc"][dc]["status"] = 0
        results_24h_with_pfc_67bus_B8[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
    end
end

## AC contingencies

for t in time_steps_67bus
    for (i,ac) in enumerate(ac_branches)
        c = 1 + length(dc_branches) + i
        # No PFC
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver) 
        data_run = deepcopy(data_24h_no_pfc_67bus[t])
        data_run["branch"][ac]["br_status"] = 0
        results_24h_no_pfc_67bus[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 2
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B2[t])
        data_run["branch"][ac]["br_status"] = 0
        results_24h_with_pfc_67bus_B2[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 3
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B3[t])
        data_run["branch"][ac]["br_status"] = 0
        results_24h_with_pfc_67bus_B3[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 4
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B4[t])
        data_run["branch"][ac]["br_status"] = 0
        results_24h_with_pfc_67bus_B4[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
        # PFC Bus 8
        ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => level,"warm_start_init_point" => warm, "linear_solver" => lsolver)
        data_run = deepcopy(data_24h_with_pfc_67bus_B8[t])
        data_run["branch"][ac]["br_status"] = 0
        results_24h_with_pfc_67bus_B8[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
    end
end

end
println("Total simulation time: ", t, " seconds")
println("Average time per simulation: ", t / (length(time_steps_67bus) * n_cont), " seconds")
println("Total simulation in minutes: ", t / 60, " minutes")


# Check solution status for all cases
status_no_pfc = check_termination_status(results_24h_no_pfc_67bus)
status_B2 = check_termination_status(results_24h_with_pfc_67bus_B2)
status_B3 = check_termination_status(results_24h_with_pfc_67bus_B3) 
status_B4 = check_termination_status(results_24h_with_pfc_67bus_B4)
status_B8 = check_termination_status(results_24h_with_pfc_67bus_B8)

# # Rerun the cases that did not solve to optimality
# #B2
# times_B2 = [(16,17),(17,17)]
# ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => warm, "linear_solver" => "ma97")
# which_contingency(times_B2,dc_branches,ac_branches)
# for (t,c) in times_B2
#     data_run = deepcopy(data_24h_with_pfc_67bus_B2[t])
#     if c == 1
#         # Base case, no changes needed
#     elseif c <= length(dc_branches) + 1
#         # DC branch contingency
#         dc = dc_branches[c-1]
#         data_run["branchdc"][dc]["status"] = 0
#     else
#         # AC branch contingency
#         ac = ac_branches[c - length(dc_branches) - 1]
#         data_run["branch"][ac]["br_status"] = 0
#     end
#     results_24h_with_pfc_67bus_B2[t,c] = _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
# end

## Check ENS

ENS_flag_no_pfc,ENS_total_no_pfc = check_ENS(data_24h_no_pfc_67bus, results_24h_no_pfc_67bus)
ENS_flag_B2,ENS_total_B2 = check_ENS(data_24h_with_pfc_67bus_B2, results_24h_with_pfc_67bus_B2)
ENS_flag_B3,ENS_total_B3 = check_ENS(data_24h_with_pfc_67bus_B3, results_24h_with_pfc_67bus_B3)
ENS_flag_B4,ENS_total_B4 = check_ENS(data_24h_with_pfc_67bus_B4, results_24h_with_pfc_67bus_B4)
ENS_flag_B8,ENS_total_B8 = check_ENS(data_24h_with_pfc_67bus_B8, results_24h_with_pfc_67bus_B8)

any(ENS_flag_no_pfc)
any(ENS_flag_B2)
any(ENS_flag_B3)
any(ENS_flag_B4)
any(ENS_flag_B8)

sum(ENS_total_B8)
maximum(ENS_total_B8)
findall(ENS_flag_B8)


# Extract results

#Objective values for all cases
objective_values_no_pfc_67bus      = [results_24h_no_pfc_67bus[t, c]["objective"] for t in time_steps_67bus, c in 1:n_cont]
objective_values_with_pfc_67bus_B2 = [results_24h_with_pfc_67bus_B2[t, c]["objective"] for t in time_steps_67bus, c in 1:n_cont]
objective_values_with_pfc_67bus_B3 = [results_24h_with_pfc_67bus_B3[t, c]["objective"] for t in time_steps_67bus, c in 1:n_cont]
objective_values_with_pfc_67bus_B4 = [results_24h_with_pfc_67bus_B4[t, c]["objective"] for t in time_steps_67bus, c in 1:n_cont]
objective_values_with_pfc_67bus_B8 = [results_24h_with_pfc_67bus_B8[t, c]["objective"] for t in time_steps_67bus, c in 1:n_cont]

# Duty cycles for PFCs
duty_cycles_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps_67bus, c in 1:n_cont]
duty_cycles_B3 = [results_24h_with_pfc_67bus_B3[t, c]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps_67bus, c in 1:n_cont]
duty_cycles_B4 = [results_24h_with_pfc_67bus_B4[t, c]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps_67bus, c in 1:n_cont]
duty_cycles_B8 = [results_24h_with_pfc_67bus_B8[t, c]["solution"]["pfc"]["1"]["duty_cycle"] for t in time_steps_67bus, c in 1:n_cont]

# PFC Cpaacitor voltage for PFC cases
e_voltage_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["pfc"]["1"]["c_voltage"] for t in time_steps_67bus, c in 1:n_cont]
e_voltage_B3 = [results_24h_with_pfc_67bus_B3[t, c]["solution"]["pfc"]["1"]["c_voltage"] for t in time_steps_67bus, c in 1:n_cont]
e_voltage_B4 = [results_24h_with_pfc_67bus_B4[t, c]["solution"]["pfc"]["1"]["c_voltage"] for t in time_steps_67bus, c in 1:n_cont]
e_voltage_B8 = [results_24h_with_pfc_67bus_B8[t, c]["solution"]["pfc"]["1"]["c_voltage"] for t in time_steps_67bus, c in 1:n_cont]

# Savings per location
savings_B2 = objective_values_no_pfc_67bus - objective_values_with_pfc_67bus_B2
savings_B3 = objective_values_no_pfc_67bus - objective_values_with_pfc_67bus_B3
savings_B4 = objective_values_no_pfc_67bus - objective_values_with_pfc_67bus_B4
savings_B8 = objective_values_no_pfc_67bus - objective_values_with_pfc_67bus_B8

# Savings in percentage
savings_per_B2 = savings_B2 ./ objective_values_no_pfc_67bus * 100
savings_per_B3 = savings_B3 ./ objective_values_no_pfc_67bus * 100
savings_per_B4 = savings_B4 ./ objective_values_no_pfc_67bus * 100
savings_per_B8 = savings_B8 ./ objective_values_no_pfc_67bus * 100

# Concatanate savings data for boxplot
saving_vec_B2 = vcat(vec(savings_per_B2[:, 1]),vec(savings_per_B2[:, 2:11]),vec(savings_per_B2[:, 12:21]))
saving_vec_B3 = vcat(vec(savings_per_B3[:, 1]),vec(savings_per_B3[:, 2:11]),vec(savings_per_B3[:, 12:21]))
saving_vec_B4 = vcat(vec(savings_per_B4[:, 1]),vec(savings_per_B4[:, 2:11]),vec(savings_per_B4[:, 12:21]))
saving_vec_B8 = vcat(vec(savings_per_B8[:, 1]),vec(savings_per_B8[:, 2:11]),vec(savings_per_B8[:, 12:21]))

# Concatenate capacitor voltage data for boxplot
e_voltage_B2_vec = vcat(vec(e_voltage_B2[:, 1]),vec(e_voltage_B2[:, 2:11]),vec(e_voltage_B2[:, 12:21]))
e_voltage_B3_vec = vcat(vec(e_voltage_B3[:, 1]),vec(e_voltage_B3[:, 2:11]),vec(e_voltage_B3[:, 12:21]))
e_voltage_B4_vec = vcat(vec(e_voltage_B4[:, 1]),vec(e_voltage_B4[:, 2:11]),vec(e_voltage_B4[:, 12:21]))
e_voltage_B8_vec = vcat(vec(e_voltage_B8[:, 1]),vec(e_voltage_B8[:, 2:11]),vec(e_voltage_B8[:, 12:21]))

# voltage in kV
e_voltage_B2_vec_kv = e_voltage_B2_vec .* 500
e_voltage_B3_vec_kv = e_voltage_B3_vec .* 500
e_voltage_B4_vec_kv = e_voltage_B4_vec .* 500
e_voltage_B8_vec_kv = e_voltage_B8_vec .* 500


using StatsPlots
# using DataFrames

# Create a boxplot for the savings
locations = ["Bus 2", "Bus 3", "Bus 4", "Bus 8"]


# boxplot([saving_vec_B2,saving_vec_B3,saving_vec_B4,saving_vec_B8], title="Savings from PFCs", ylabel="Savings (%)", xlabel="PFC Location", legend=:topright)

boxplot(
    [saving_vec_B2, saving_vec_B3, saving_vec_B4, saving_vec_B4],
    xticks = (1:4, locations),
    fontfamily=plot_fontfamily,
    yticks = 0:2:20,
    ylim = (-0.5, 20),
    title = "Savings from PFCs at Different Locations",
    xlabel = "PFC Location",
    ylabel = "Savings (%)",
    legend = false
)

savefig("/Users/rgallo/Desktop/Figures/savings_boxplot_20.4_new_font.png")

boxplot(
    [e_voltage_B2_vec, e_voltage_B3_vec, e_voltage_B4_vec, e_voltage_B8_vec],
    xticks = (1:4, locations),
    fontfamily=plot_fontfamily,
    ylim = (-0.01, 0.01),
    yticks = -0.01:0.002:0.01,
    title = "PFC Capacitor Voltage at Different Locations",
    xlabel = "PFC Location",
    ylabel = "Capacitor Voltage (p.u.)",
    legend = false
)

savefig("/Users/rgallo/Desktop/Figures/c_voltage_boxplot_new_font.png")

boxplot(
    [e_voltage_B2_vec_kv, e_voltage_B3_vec_kv, e_voltage_B4_vec_kv, e_voltage_B8_vec_kv],
    xticks = (1:4, locations),
    fontfamily=plot_fontfamily,
    ylim = (-5, 5),
    yticks = -5:1:5,
    title = "PFC Capacitor Voltage at Different Locations",
    xlabel = "PFC Location",
    ylabel = "Capacitor Voltage (kV)",
    legend = false
)

savefig("/Users/rgallo/Desktop/Figures/c_voltage_boxplot_kv_new_font.png")

## PFC activation

delta = 1e-4

activation_B2 = [abs.(e_voltage_B2[t, c]) .> delta for t in time_steps_67bus, c in 1:n_cont]
activation_B3 = [abs.(e_voltage_B3[t, c]) .> delta for t in time_steps_67bus, c in 1:n_cont]
activation_B4 = [abs.(e_voltage_B4[t, c]) .> delta for t in time_steps_67bus, c in 1:n_cont]
activation_B8 = [abs.(e_voltage_B8[t, c]) .> delta for t in time_steps_67bus, c in 1:n_cont]

#Hourly data for plotting
c = 7

plot_B2 = activation_B2[:, c]
plot_B3 = activation_B3[:, c]
plot_B4 = activation_B4[:, c]
plot_B8 = activation_B8[:, c]

hours = 1:24
locations = repeat(["B2", "B3", "B4", "B8"], inner = 24)


# scatter(
#     hours,
#     plot_B2,
#     markershape = :circle,
#     label = "Bus 2",
# )

# scatter!(
#     hours,
#     plot_B3,
#     markershape = :square,
#     label = "Bus 3",
# )

# # Create a new figure for the binary values
# scatter!(
#     hours,
#     plot_B4,
#     markershape = :diamond,
#     label = "Bus 4",
# )

# scatter!(
#     hours,
#     plot_B8,
#     markershape = :star5,
#     label = "Bus 8",
# )

using Statistics

# Calculate the percentage of hours with PFC activation for each location
activation_percentage_B2 = mean(activation_B2) * 100
activation_percentage_B3 = mean(activation_B3) * 100  
activation_percentage_B4 = mean(activation_B4) * 100
activation_percentage_B8 = mean(activation_B8) * 100

# Mean savings
mean_savings_B2 = mean(savings_B2)
mean_savings_B3 = mean(savings_B3)
mean_savings_B4 = mean(savings_B4)
mean_savings_B8 = mean(savings_B8)

## Duty cycle

duty_cycle_B2 = duty_cycles_B2 .* activation_B2
duty_cycle_B3 = duty_cycles_B3 .* activation_B3
duty_cycle_B4 = duty_cycles_B4 .* activation_B4
duty_cycle_B8 = duty_cycles_B8 .* activation_B8

# Duty cycle for plotting
c = 15

plot_duty_B2 = duty_cycle_B2[:, c]
plot_duty_B3 = duty_cycle_B3[:, c]
plot_duty_B4 = duty_cycle_B4[:, c]
plot_duty_B8 = duty_cycle_B8[:, c]

## Capacitor voltage

e_voltage_B2_plot = e_voltage_B2 .* activation_B2
cases = ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"]

plot(
    hours,
    e_voltage_B2_plot[:,1],
    fontfamily=plot_fontfamily,
    markershape = :circle,
    legend = :outerright,
    label = "Base",
    title = "PFC Capacitor Voltage over 24 Hours",
    xticks = 1:24,
    ylim = (-0.007,0.002),
    xlabel = "Hour",
    ylabel = "Capacitor Voltage (pu)"
)

plot!(
    hours,
    e_voltage_B2_plot[:,2:11],
    markershape = :square,
    label = "DC N-1"
)

plot!(
    hours,
    e_voltage_B2[:,12:21],
    markershape = :star,
    label = "AC N-1"
)

savefig("/Users/rgallo/Desktop/Figures/c_voltage_plot_new_font.png")

plot(
    hours,
    plot_duty_B2,
    markershape = :circle,
    label = "Bus 2",
    legend = :outerright,
    title = "PFC Duty Cycle Over 24 Hours",
    xticks = 1:24,
    xlabel = "Hour",
    ylabel = "Duty Cycle",
)
plot!(
    hours,
    plot_duty_B3,
    markershape = :square,
    label = "Bus 3",
)
plot!(
    hours,
    plot_duty_B4,
    markershape = :diamond,
    label = "Bus 4",
)
plot!(
    hours,
    plot_duty_B8,
    markershape = :star5,
    label = "Bus 8",
)

savefig("/Users/rgallo/Desktop/Figures/duty_cycle_plot.png")

# Load profile for plotting
plot!(
    hours,
    load_profile,
    label = "Load profile",
    ylabel = "Load scaling",
    yaxis = yticks_right,
    color = :blue
)

plot!(hours,load_profile, label = "Load Profile", linestyle = :dash, color = :black)

### Plot activation
## Generator on status, heatmap style
plot_markersize = 3
plot_fontfamily = "Computer Modern"
plot_titlefontsize = 20
plot_guidefontsize = 16
plot_tickfontsize = 12
plot_legendfontsize = 12
plot_size = (720,480)
plot_gen_on = scatter()

activation_B2_mat = [activation_B2[t, c] for t in time_steps_67bus, c in 1:n_cont]
 
# gen_on_mat = [results_robust["gen_on"][g][t] for g in genconv_ids, t=1:n_time_steps]
# gen_on_mat = [results_classical["gen_on"][g][t] for g in genconv_ids, t=1:n_time_steps]
plot_gen_on = heatmap(activation_B2_mat;
                        cbar = false,
                        framestyle = :box,
                        # color=palette(cs_grays, 2),
                        color = palette(:greys, 2),
                        clim=(0,1))
m, n = size(activation_B2_mat)
plot!(plot_gen_on,
        legend = false,
        fontfamily=plot_fontfamily,
        # background_color=:transparent,
        foreground_color=:black,
        titlefontsize = plot_titlefontsize,
        guidefontsize = plot_guidefontsize,
        tickfontsize = plot_tickfontsize,
        legendfontsize = plot_legendfontsize,
        size = plot_size,xrotation=45,
        bottom_margin = (10,:mm),
        left_margin = (4,:mm),
        right_margin = (2,:mm)
        )
vline!(1.5:(n+1), c=:black,linewidth=0.2)
hline!(0.5:4:(m+1), c=:black,linewidth=0.2)
title!("PFC activation status")
# xticks!([6:6:n_time_steps;], string.([6:6:n_time_steps;]))
start_time = DateTime("2022-02-16T18:00:00");
end_time = DateTime("2022-02-17T17:45:00");
time_step_interval = 19
t_date = start_time:Minute(time_step_interval*15):end_time
time_ticks = Dates.format.(t_date,"dd/mm HH:MM")
xticks!([1:time_step_interval:n_time_steps;],time_ticks)
# yticks!([1:1:length(genconv_ids);], genconv_ids)
yticks!(1:n_cont, ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"])
# yticks!([1:1:length(gen_ids);], gen_ids)
xlims!(0.5,n_time_steps+0.5)
ylims!(0.5,length(n_cont)+0.5)
xlabel!("Time")
ylabel!("Scenario")
# annotate!(102, 4, text("Colors", 10, "Computer Modern"))
# annotate!(1.5, range(0,1,4+1)[1:4] .+ 0.5/4, text("On", 7, "Computer Modern"))
##
Plots.svg(joinpath(results_folder,"svg","plot_gen_on_$suffix_results_name.svg"))
savefig(joinpath(results_folder,"png","plot_gen_on_$suffix_results_name.png"))
 
## Change for activation plot
plot_markersize = 3
plot_fontfamily = "Computer Modern"
plot_titlefontsize = 20
plot_guidefontsize = 16
plot_tickfontsize = 12
plot_legendfontsize = 12
plot_size = (720,520)
plot_device_on = scatter()

hours = 1:24
scenarios = 1:n_cont
scenario_label = ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"]

activation_plot_mat = activation_B2'

on_color = RGB(0.2, 0.6, 0.2)
color = [:white, on_color]

plot_device_on = heatmap(
    activation_plot_mat;
    cbar = false,
    framestyle = :box,
    color = color,
    clim = (0, 1)
)


plot!(
    plot_device_on,
    legend = false,
    fontfamily = plot_fontfamily,
    foreground_color = :black,
    titlefontsize = plot_titlefontsize,
    guidefontsize = plot_guidefontsize,
    tickfontsize = plot_tickfontsize,
    size = plot_size,
    bottom_margin = (8, :mm),
    left_margin = (8, :mm)
)


vline!(0.5:1:24.5, c = :black, linewidth = 0.2)
hline!(0.5:1:21.5, c = :black, linewidth = 0.2)


title!("PFC activation status at Bus 2")
xlabel!("Hour")
ylabel!("Scenario")


xticks!(1:24, string.(1:24))
yticks!(1:n_cont, scenario_label)

xlims!(0.5, 24.5)
ylims!(0.5, length(scenario_label) + 0.5)

savefig("/Users/rgallo/Desktop/Figures/B2_activation_plot.png")
savefig("/Users/rgallo/Desktop/Figures/B2_activation_plot.svg")

hline!([11.5], linewidth = 2.0, color = :black)
hline!([1.5], linewidth = 2.0, color = :black)

scatter!(
    plot_device_on,
    [NaN], [NaN],
    marker = (:square, 8),
    color = :white,
    label = "OFF"
)

scatter!(
    plot_device_on,
    [NaN], [NaN],
    marker = (:square, 8),
    color = :green,
    label = "ON"
)

plot!(
    plot_device_on,
    legend = :outerright,
    legendtitle = "Device",
    legendfontsize = 10
)

# annotate!(25, 5, text("OFF", 10))
# annotate!(25, 15, text("ON", 10))


#Extract dc branch flows for all branches and the no pfc and pfc at B2 cases

# DC Branch 1
# dc1_flow_no_pfc = [ haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "1") ? results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["1"]["pf"] : NaN for t in time_steps_67bus, c in 1:n_cont]
dc1_flow_no_pfc = [ results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["1"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "1")]
dc1_flow_B2 = [ results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["1"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "1")]
delta_dc1 = abs.(dc1_flow_B2) - abs.(dc1_flow_no_pfc)

# DC Branch 2
dc2_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["2"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "2")]
dc2_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["2"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "2")]
delta_dc2 = abs.(dc2_flow_B2) - abs.(dc2_flow_no_pfc)

# DC Branch 3
dc3_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["3"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "3")]
dc3_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["3"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "3")]
delta_dc3 = abs.(dc3_flow_B2) - abs.(dc3_flow_no_pfc)

# DC Branch 4
dc4_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["4"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "4")]
dc4_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["4"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "4")]
delta_dc4 = abs.(dc4_flow_B2) - abs.(dc4_flow_no_pfc)

# DC Branch 5
dc5_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["5"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "5")]
dc5_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["5"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "5")]
delta_dc5 = abs.(dc5_flow_B2) - abs.(dc5_flow_no_pfc)

# DC Branch 6
dc6_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["6"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "6")]
dc6_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["6"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "6")]
delta_dc6 = abs.(dc6_flow_B2) - abs.(dc6_flow_no_pfc)

# DC Branch 7
dc7_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["7"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "7")]
dc7_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["7"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "7")]
delta_dc7 = abs.(dc7_flow_B2) - abs.(dc7_flow_no_pfc)

# DC Branch 8
dc8_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["8"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "8")]
dc8_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["8"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "8")]
delta_dc8 = abs.(dc8_flow_B2) - abs.(dc8_flow_no_pfc)

# DC Branch 9
dc9_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["9"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "9")]
dc9_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["9"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "9")]
delta_dc9 = abs.(dc9_flow_B2) - abs.(dc9_flow_no_pfc)

# DC Branch 10
dc10_flow_no_pfc = [results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["10"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "10")]
dc10_flow_B2 = [results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["10"]["pf"] for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "10")]
delta_dc10 = abs.(dc10_flow_B2) - abs.(dc10_flow_no_pfc)

# boxplot

branches = ["DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10"]

boxplot(
    [delta_dc1, delta_dc2, delta_dc3, delta_dc4, delta_dc5, delta_dc6, delta_dc7, delta_dc8, delta_dc9, delta_dc10],
    xticks = (1:10, branches),
    fontfamily=plot_fontfamily,
    yticks = -6:2:8,
    ylim = (-6, 8),
    title = "Change in DC Branch Flows Due to PFC at Bus 2",
    xlabel = "DC Branches",
    ylabel = "Change in Active Power Flow (p.u.)",
    legend = false
)
savefig("/Users/rgallo/Desktop/Figures/dc_flow_change_boxplot_new_font.png")

violin(
    [delta_dc1, delta_dc2, delta_dc3, delta_dc4, delta_dc5, delta_dc6, delta_dc7, delta_dc8, delta_dc9, delta_dc10],
    xticks = (1:10, branches),
    fontfamily=plot_fontfamily,
    title = "Change in DC Branch Flows Due to PFC at Bus 2",
    xlabel = "DC Branches",
    yticks = -6:2:8,
    ylim = (-6, 8),
    ylabel = "Change in Active Power Flow (p.u.)",
    legend = false
)

savefig("/Users/rgallo/Desktop/Figures/dc_flow_change_violin_new_font.png")

# Heatmap of DC 5 flow change across all contingencies

dc5_no_pfc = [ haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "5") ? results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["5"]["pf"] : NaN for t in time_steps_67bus, c in 1:n_cont]
dc5_with_pfc = [ haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "5") ? results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["5"]["pf"] : NaN for t in time_steps_67bus, c in 1:n_cont]
delta_dc5_plot = abs.(dc5_with_pfc) - abs.(dc5_no_pfc)

heatmap(
    delta_dc5_plot',
    xticks = (1:24, string.(time_steps_67bus)),
    fontfamily=plot_fontfamily,
    yticks = (1:n_cont, ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"]),
    title = "Change in DC Branch 5 Flow Due to PFC at Bus 2",
    xlabel = "Time Steps",
    ylabel = "Contingencies",
    clim = (-7, 7),
    color = :balance,
    colorbar_title = "Change in Flow (p.u.)"
)

dc9_no_pfc = [ haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "9") ? results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"]["9"]["pf"] : NaN for t in time_steps_67bus, c in 1:n_cont]
dc9_with_pfc = [ haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "9") ? results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"]["9"]["pf"] : NaN for t in time_steps_67bus, c in 1:n_cont]
delta_dc9_plot = abs.(dc9_with_pfc) - abs.(dc9_no_pfc)

heatmap(
    delta_dc9_plot',
    xticks = (1:24, string.(time_steps_67bus)),
    fontfamily=plot_fontfamily,
    yticks = (1:n_cont, ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"]),
    clim = (-7, 7),
    title = "Change in DC Branch 9 Flow Due to PFC at Bus 2",
    xlabel = "Time Steps",
    ylabel = "Contingencies",
    color = :balance,
    colorbar_title = "Change in Flow (p.u.)"
)

## With loading percentage

function dc_loading(results,t,c,branch_id,pmax)
    if haskey(results[t, c]["solution"]["branchdc"], branch_id)
        pf = results[t, c]["solution"]["branchdc"][branch_id]["pf"]
        pt = results[t, c]["solution"]["branchdc"][branch_id]["pt"]
        return max(abs(pf), abs(pt)) / pmax
    else
        return NaN
    end
end

dc1_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "1", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "1")]
dc1_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "1", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "1")]
delta_dc1_loading = (dc1_loading_with_pfc .- dc1_loading_no_pfc) .* 100

dc_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "2", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "2")]
dc2_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "2", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "2")]
delta_dc2_loading = (dc2_loading_with_pfc .- dc_loading_no_pfc) .* 100

dc3_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "3", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "3")]
dc3_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "3", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "3")]
delta_dc3_loading = (dc3_loading_with_pfc .- dc3_loading_no_pfc) .* 100

dc4_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "4", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "4")]
dc4_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "4", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "4")]
delta_dc4_loading = (dc4_loading_with_pfc .- dc4_loading_no_pfc) .* 100

dc5_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "5", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "5")]
dc5_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "5", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "5")]
delta_dc5_loading = (dc5_loading_with_pfc .- dc5_loading_no_pfc) .* 100

dc6_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "6", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "6")]
dc6_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "6", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "6")]
delta_dc6_loading = (dc6_loading_with_pfc .- dc6_loading_no_pfc) .* 100

dc7_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "7", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "7")]
dc7_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "7", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "7")]
delta_dc7_loading = (dc7_loading_with_pfc .- dc7_loading_no_pfc) .* 100

dc8_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "8", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "8")]
dc8_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "8", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "8")]
delta_dc8_loading = (dc8_loading_with_pfc .- dc8_loading_no_pfc) .* 100

dc9_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "9", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "9")]
dc9_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "9", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "9")]
delta_dc9_loading = (dc9_loading_with_pfc .- dc9_loading_no_pfc) .* 100

dc10_loading_no_pfc = [dc_loading(results_24h_no_pfc_67bus, t, c, "10", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_no_pfc_67bus[t, c]["solution"]["branchdc"], "10")]
dc10_loading_with_pfc = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "10", 15.75) for t in time_steps_67bus, c in 1:n_cont if haskey(results_24h_with_pfc_67bus_B2[t, c]["solution"]["branchdc"], "10")]
delta_dc10_loading = (dc10_loading_with_pfc .- dc10_loading_no_pfc) .* 100

# Boxplot with percentage

branches = ["DC1*", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9*", "DC10"]
boxplot(
    [delta_dc1_loading, delta_dc2_loading, delta_dc3_loading, delta_dc4_loading, delta_dc5_loading, delta_dc6_loading, delta_dc7_loading, delta_dc8_loading, delta_dc9_loading, delta_dc10_loading],
    xticks = (1:10, branches),
    fontfamily=plot_fontfamily,
    yticks = -50:10:50,
    ylim = (-50, 50),
    title = "Change in DC Branch Loading Due to PFC at Bus 2",
    xlabel = "DC Branches",
    ylabel = "Change in Loading (%)",
    legend = false
)
savefig("/Users/rgallo/Desktop/Figures/dc_loading_change_boxplot_new_font.png")

# Heatmap of DC 5 and 9 loading change across all contingencies
dc5_loading_no_pfc_plot = [dc_loading(results_24h_no_pfc_67bus, t, c, "5", 15.75) for t in time_steps_67bus, c in 1:n_cont]
dc5_loading_with_pfc_plot = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "5", 15.75) for t in time_steps_67bus, c in 1:n_cont]
delta_dc5_loading_plot = (dc5_loading_with_pfc_plot .- dc5_loading_no_pfc_plot) .* 100

dc9_loading_no_pfc_plot = [dc_loading(results_24h_no_pfc_67bus, t, c, "9", 15.75) for t in time_steps_67bus, c in 1:n_cont]
dc9_loading_with_pfc_plot = [dc_loading(results_24h_with_pfc_67bus_B2, t, c, "9", 15.75) for t in time_steps_67bus, c in 1:n_cont]
delta_dc9_loading_plot = (dc9_loading_with_pfc_plot .- dc9_loading_no_pfc_plot) .* 100

cases = ["Base", "DC1", "DC2", "DC3", "DC4", "DC5", "DC6", "DC7", "DC8", "DC9", "DC10", "AC4", "AC5", "AC13", "AC22", "AC26", "AC34", "AC41", "AC42", "AC46", "AC81"]

heatmap_dc5 = heatmap(
    delta_dc5_loading_plot',
    # xticks = (1:24, string.(time_steps_67bus)),
    # yticks = (1:n_cont, cases),
    fontfamily=plot_fontfamily,
    # title = "Change in DC Branch 5 Loading Due to PFC at Bus 2",
    # xlabel = "Time Steps",
    # ylabel = "Contingencies",
    clim = (-50, 50),
    framestyle = :box,
    color = :balance,
    colorbar_title = "Change in Loading (%)"
)

plot!(
    heatmap_dc5,
    legend = false,
    fontfamily = plot_fontfamily,
    foreground_color = :black,
    titlefontsize = plot_titlefontsize,
    guidefontsize = plot_guidefontsize,
    tickfontsize = 10,
    colorbar_titlefontsize = 14,
    size = plot_size,
    bottom_margin = (8, :mm),
    right_margin = (8, :mm),
    left_margin = (4, :mm)
)

vline!(0.5:1:24.5, c = :black, linewidth = 0.2)
hline!(0.5:1:21.5, c = :black, linewidth = 0.2)

title!("DC Branch 5 Loading Change at Bus 2")
xlabel!("Hour")
ylabel!("Scenario")

xticks!(1:24, string.(1:24))
yticks!(1:n_cont, scenario_label)

xlims!(0.5, 24.5)
ylims!(0.5, length(scenario_label) + 0.5)

savefig("/Users/rgallo/Desktop/Figures/dc5_loading_change_heatmap_2.png")

heatmap_dc9 =  heatmap(
    delta_dc9_loading_plot',
    # xticks = (1:24, string.(time_steps_67bus)),
    # yticks = (1:n_cont, cases),
    fontfamily=plot_fontfamily,
    # title = "Change in DC Branch 9 Loading Due to PFC at Bus 2",
    # xlabel = "Time Steps",
    # ylabel = "Contingencies",
    clim = (-50, 50),
    color = :balance,
    framestyle = :box,
    colorbar_title = "Change in Loading (%)"
)

plot!(
    heatmap_dc9,
    legend = false,
    fontfamily = plot_fontfamily,
    foreground_color = :black,
    titlefontsize = plot_titlefontsize,
    guidefontsize = plot_guidefontsize,
    tickfontsize = 10,
    colorbar_titlefontsize = 14,
    size = plot_size,
    bottom_margin = (8, :mm),
    right_margin = (8, :mm),
    left_margin = (4, :mm)
)

vline!(0.5:1:24.5, c = :black, linewidth = 0.2)
hline!(0.5:1:21.5, c = :black, linewidth = 0.2)

title!("DC Branch 9 Loading Change at Bus 2")
xlabel!("Hour")
ylabel!("Scenario")

xticks!(1:24, string.(1:24))
yticks!(1:n_cont, scenario_label)

xlims!(0.5, 24.5)
ylims!(0.5, length(scenario_label) + 0.5)

savefig("/Users/rgallo/Desktop/Figures/dc9_loading_change_heatmap_2.png")

# data_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_no_pfc_67bus = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_no_pfc_67bus = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B3 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B3 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B3 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B4 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B4 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B4 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B5 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B5 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B5 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B6 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B6 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B6 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B7 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B7 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B7 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B8 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B8 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B8 = Vector{Any}(undef, length(time_steps_67bus))


# ### No PFC data
# # Loading data
# data_no_pfc_67bus = _PM.parse_file("./test/data/PFC/case67.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_no_pfc_67bus)
# add_ens_gens!(data_no_pfc_67bus; VOLL = 20000)

# #Reduce all dc branches capacity by 50%
# # for (branchdc_id, branchdc_data) in data_no_pfc_67bus["branchdc"]
# #     if branchdc_id != "11"
# #         branchdc_data["rateA"] *= 0.5
# #     end
# #     # if branchdc_data["index"] == 3
# #     #     branchdc_data["status"] = 0
# #     # end
# # end

# # Scale load and wind generation
# # scale_load_wind!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)
# scale_load_ens!(data_no_pfc_67bus, data_24h_no_pfc_67bus, time_steps_67bus, load_profile)

# # Running the 24-hour simulation without PFC
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_no_pfc_67bus[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_no_pfc_67bus[t] = results_24h_no_pfc_67bus[t]["termination_status"]
# end

# #Check ENS Gens
# # ens_outputs = zeros(Float64, length(load_profile), 29)
# # compute_ens_gen_matrix!(data_24h_no_pfc_67bus, results_24h_no_pfc_67bus, time_steps_67bus, ens_outputs)
# ens_check = check_ens_activation(data_24h_no_pfc_67bus, results_24h_no_pfc_67bus, time_steps_67bus)

# ### PFC data
# #Loading data
# data_with_pfc_67bus_B1 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B1)
# add_ens_gens!(data_with_pfc_67bus_B1; VOLL = 20000)

# #Loading data
# data_with_pfc_67bus_B2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B2)
# add_ens_gens!(data_with_pfc_67bus_B2; VOLL = 20000)

# #Loading data
# data_with_pfc_67bus_B3 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B3)
# add_ens_gens!(data_with_pfc_67bus_B3; VOLL = 20000)

# #Loading data
# data_with_pfc_67bus_B4 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B4)
# add_ens_gens!(data_with_pfc_67bus_B4; VOLL = 20000)

# #Loading data
# data_with_pfc_67bus_B5 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B5)
# add_ens_gens!(data_with_pfc_67bus_B5; VOLL = 50000)

# #Loading data
# data_with_pfc_67bus_B6 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B6)
# add_ens_gens!(data_with_pfc_67bus_B6; VOLL = 50000)

# #Loading data
# data_with_pfc_67bus_B7 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B7)
# add_ens_gens!(data_with_pfc_67bus_B7; VOLL = 20000)

# #Loading data
# data_with_pfc_67bus_B8 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B8)
# add_ens_gens!(data_with_pfc_67bus_B8; VOLL = 20000)

# # Scale load and wind generation
# # scale_load_wind!(data_with_pfc_67bus_B1, data_24h_with_pfc_67bus_B1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B2, data_24h_with_pfc_67bus_B2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B3, data_24h_with_pfc_67bus_B3, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B4, data_24h_with_pfc_67bus_B4, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B5, data_24h_with_pfc_67bus_B5, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B6, data_24h_with_pfc_67bus_B6, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B7, data_24h_with_pfc_67bus_B7, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B8, data_24h_with_pfc_67bus_B8, time_steps_67bus, load_profile, CF_ON, CF_OFF)

# ## Reducing the DC line capacity except line 11
# # for case_data in [data_with_pfc_67bus_B1, data_with_pfc_67bus_B2, data_with_pfc_67bus_B3, data_with_pfc_67bus_B4, data_with_pfc_67bus_B5, data_with_pfc_67bus_B6, data_with_pfc_67bus_B7, data_with_pfc_67bus_B8]
# #     for (branchdc_id, branchdc_data) in case_data["branchdc"]
# #         if branchdc_id != "11"
# #             branchdc_data["rateA"] *= 0.5
# #         end
# #         # if branchdc_data["index"] == 3
# #         #     branchdc_data["status"] = 0
# #         # end
# #     end
# # end


# # scale_load!(data_with_pfc_67bus_B1, data_24h_with_pfc_67bus_B1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B2, data_24h_with_pfc_67bus_B2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B3, data_24h_with_pfc_67bus_B3, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B4, data_24h_with_pfc_67bus_B4, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B5, data_24h_with_pfc_67bus_B5, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B6, data_24h_with_pfc_67bus_B6, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B7, data_24h_with_pfc_67bus_B7, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B8, data_24h_with_pfc_67bus_B8, time_steps_67bus, load_profile)

# scale_load_ens!(data_with_pfc_67bus_B1, data_24h_with_pfc_67bus_B1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B2, data_24h_with_pfc_67bus_B2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B3, data_24h_with_pfc_67bus_B3, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B4, data_24h_with_pfc_67bus_B4, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B5, data_24h_with_pfc_67bus_B5, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B6, data_24h_with_pfc_67bus_B6, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B7, data_24h_with_pfc_67bus_B7, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B8, data_24h_with_pfc_67bus_B8, time_steps_67bus, load_profile)


# # # Solution time
# # solution_time_with_pfc_67bus_B1_MUMPS = Vector{Any}(undef, length(time_steps_67bus))
# # solution_time_with_pfc_67bus_B1_MA27 = Vector{Any}(undef, length(time_steps_67bus))

# # Running the 24-hour simulation with PFC
# for t in time_steps_67bus

#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27")
#     # ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
#     results_24h_with_pfc_67bus_B1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B1[t] = results_24h_with_pfc_67bus_B1[t]["termination_status"]
#     # solution_time_with_pfc_67bus_B1_MUMPS[t] = results_24h_with_pfc_67bus_B1[t]["solve_time"]
#     # solution_time_with_pfc_67bus_B1_MA27[t] = results_24h_with_pfc_67bus_B1[t]["solve_time"]
# end

# # time_diff = [solution_time_with_pfc_67bus_B1_MA27[t] - solution_time_with_pfc_67bus_B1_MUMPS[t] for t in time_steps_67bus]

# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B2[t] = results_24h_with_pfc_67bus_B2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B3[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B3[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B3[t] = results_24h_with_pfc_67bus_B3[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B4[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B4[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B4[t] = results_24h_with_pfc_67bus_B4[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B5[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B5[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B5[t] = results_24h_with_pfc_67bus_B5[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B6[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B6[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B6[t] = results_24h_with_pfc_67bus_B6[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B7[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B7[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B7[t] = results_24h_with_pfc_67bus_B7[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B8[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B8[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B8[t] = results_24h_with_pfc_67bus_B8[t]["termination_status"]
# end 

# #Check ENS Gens
# ens_check_B1 = check_ens_activation(data_24h_with_pfc_67bus_B1, results_24h_with_pfc_67bus_B1, time_steps_67bus)
# ens_check_B2 = check_ens_activation(data_24h_with_pfc_67bus_B2, results_24h_with_pfc_67bus_B2, time_steps_67bus)
# ens_check_B3 = check_ens_activation(data_24h_with_pfc_67bus_B3, results_24h_with_pfc_67bus_B3, time_steps_67bus)
# ens_check_B4 = check_ens_activation(data_24h_with_pfc_67bus_B4, results_24h_with_pfc_67bus_B4, time_steps_67bus)
# ens_check_B5 = check_ens_activation(data_24h_with_pfc_67bus_B5, results_24h_with_pfc_67bus_B5, time_steps_67bus)
# ens_check_B6 = check_ens_activation(data_24h_with_pfc_67bus_B6, results_24h_with_pfc_67bus_B6, time_steps_67bus)
# ens_check_B7 = check_ens_activation(data_24h_with_pfc_67bus_B7, results_24h_with_pfc_67bus_B7, time_steps_67bus)
# ens_check_B8 = check_ens_activation(data_24h_with_pfc_67bus_B8, results_24h_with_pfc_67bus_B8, time_steps_67bus)


# # Objective values extraction
# objective_values_no_pfc_67bus      = [results_24h_no_pfc_67bus[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B1 = [results_24h_with_pfc_67bus_B1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B2 = [results_24h_with_pfc_67bus_B2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B3 = [results_24h_with_pfc_67bus_B3[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B4 = [results_24h_with_pfc_67bus_B4[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B5 = [results_24h_with_pfc_67bus_B5[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B6 = [results_24h_with_pfc_67bus_B6[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B7 = [results_24h_with_pfc_67bus_B7[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B8 = [results_24h_with_pfc_67bus_B8[t]["objective"] for t in time_steps_67bus]



# # OF matrix
# OF_matrix = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     OF_matrix[t, 1] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B1[t]
#     OF_matrix[t, 2] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B2[t]
#     OF_matrix[t, 3] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B3[t]
#     OF_matrix[t, 4] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B4[t]
#     OF_matrix[t, 5] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B5[t]
#     OF_matrix[t, 6] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B6[t]
#     OF_matrix[t, 7] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B7[t]
#     OF_matrix[t, 8] = objective_values_no_pfc_67bus[t] - objective_values_with_pfc_67bus_B8[t]
# end

# # Prepare difference vector
# difference_vector_67bus_B1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B3 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B4 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B5 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B6 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B7 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B8 = Vector{Any}(undef, length(time_steps_67bus))

# # Benefit calculation
# println("Calculating cost savings with PFCs at different locations...")
# println("================================")
# println("At Busbar 1:")
# saving_B1 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B1, difference_vector_67bus_B1, time_steps_67bus)
# println("At Busbar 2:")
# saving_B2 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B2, difference_vector_67bus_B2, time_steps_67bus)
# println("At Busbar 3:")
# saving_B3 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B3, difference_vector_67bus_B3, time_steps_67bus)
# println("At Busbar 4:")
# saving_B4 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B4, difference_vector_67bus_B4, time_steps_67bus)
# println("At Busbar 5:")
# saving_B5 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B5, difference_vector_67bus_B5, time_steps_67bus)
# println("At Busbar 6:")
# saving_B6 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B6, difference_vector_67bus_B6, time_steps_67bus)
# println("At Busbar 7:")
# saving_B7 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B7, difference_vector_67bus_B7, time_steps_67bus)
# println("At Busbar 8:")
# saving_B8 = benefit_calculation(objective_values_no_pfc_67bus, objective_values_with_pfc_67bus_B8, difference_vector_67bus_B8, time_steps_67bus)

# # Plot the saving over 24 hours for each PFC location
# scatter(1:8, [saving_B1,saving_B2,saving_B3,saving_B4,saving_B5,saving_B6,saving_B7,saving_B8], xlabel="PFC Location", ylabel="Cost Saving [%]", title="Cost Saving over 24 hours with PFCs at Different Locations", legend=false, xticks=1:8)
# # savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_AC_N1_Base.png")

# # Duty cycles
# D_matrix = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     D_matrix[t, 1] = results_24h_with_pfc_67bus_B1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 2] = results_24h_with_pfc_67bus_B2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 3] = results_24h_with_pfc_67bus_B3[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 4] = results_24h_with_pfc_67bus_B4[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 5] = results_24h_with_pfc_67bus_B5[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 6] = results_24h_with_pfc_67bus_B6[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 7] = results_24h_with_pfc_67bus_B7[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix[t, 8] = results_24h_with_pfc_67bus_B8[t]["solution"]["pfc"]["1"]["duty_cycle"]
# end

# # Internal capacitor voltage
# E_matrix = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     E_matrix[t, 1] = results_24h_with_pfc_67bus_B1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 2] = results_24h_with_pfc_67bus_B2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 3] = results_24h_with_pfc_67bus_B3[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 4] = results_24h_with_pfc_67bus_B4[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 5] = results_24h_with_pfc_67bus_B5[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 6] = results_24h_with_pfc_67bus_B6[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 7] = results_24h_with_pfc_67bus_B7[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix[t, 8] = results_24h_with_pfc_67bus_B8[t]["solution"]["pfc"]["1"]["c_voltage"]
# end
# E_matrix_round = round.(E_matrix, digits=3)
# D_matrix_round = round.(D_matrix, digits=3)

# print_dc_branch_currents(results_24h_no_pfc_67bus, time_steps_67bus)
# print_dc_branch_currents(results_24h_with_pfc_67bus_B1, time_steps_67bus)


# ### N-1 Contingency analysis for the 67 bus system with and without PFCs
# data_24h_no_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_no_pfc_67bus_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_no_pfc_67bus_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B1_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B1_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B1_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B2_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B2_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B2_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B3_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B3_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B3_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B4_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B4_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B4_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B5_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B5_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B5_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B6_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B6_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B6_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B7_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B7_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B7_N1 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B8_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B8_N1 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B8_N1 = Vector{Any}(undef, length(time_steps_67bus))


# ### No PFC data
# # Loading data
# data_no_pfc_67bus_N1 = _PM.parse_file("./test/data/PFC/case67.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_no_pfc_67bus_N1)
# add_ens_gens!(data_no_pfc_67bus_N1)

# #Reduce all dc branches capacity by 50%
# for (branchdc_id, branchdc_data) in data_no_pfc_67bus_N1["branchdc"]
#     # if branchdc_id != "11"
#     #     branchdc_data["rateA"] *= 0.5
#     # end
#     if branchdc_data["index"] == 3
#         branchdc_data["status"] = 0
#     end
# end

# # Scale load and wind generation
# # scale_load_wind!(data_no_pfc_67bus_N1, data_24h_no_pfc_67bus_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load!(data_no_pfc_67bus_N1, data_24h_no_pfc_67bus_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_no_pfc_67bus_N1, data_24h_no_pfc_67bus_N1, time_steps_67bus, load_profile)

# # Running the 24-hour simulation without PFC
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_no_pfc_67bus_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_no_pfc_67bus_N1[t] = results_24h_no_pfc_67bus_N1[t]["termination_status"]
# end

# ens_check_no_pfc_N1 = check_ens_activation(data_24h_no_pfc_67bus_N1, results_24h_no_pfc_67bus_N1, time_steps_67bus)

# ### PFC data
# #Loading data
# data_with_pfc_67bus_B1_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B1_N1)
# add_ens_gens!(data_with_pfc_67bus_B1_N1)

# #Loading data
# data_with_pfc_67bus_B2_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B2_N1)
# add_ens_gens!(data_with_pfc_67bus_B2_N1)

# #Loading data
# data_with_pfc_67bus_B3_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B3_N1)
# add_ens_gens!(data_with_pfc_67bus_B3_N1)

# #Loading data
# data_with_pfc_67bus_B4_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B4_N1)
# add_ens_gens!(data_with_pfc_67bus_B4_N1)

# #Loading data
# data_with_pfc_67bus_B5_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B5_N1)
# add_ens_gens!(data_with_pfc_67bus_B5_N1)

# #Loading data
# data_with_pfc_67bus_B6_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B6_N1)
# add_ens_gens!(data_with_pfc_67bus_B6_N1)

# #Loading data
# data_with_pfc_67bus_B7_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B7_N1)
# add_ens_gens!(data_with_pfc_67bus_B7_N1)

# #Loading data
# data_with_pfc_67bus_B8_N1 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B8_N1)
# add_ens_gens!(data_with_pfc_67bus_B8_N1; VOLL = 20000)

# # Scale load and wind generation
# # scale_load_wind!(data_with_pfc_67bus_B1_N1, data_24h_with_pfc_67bus_B1_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B2_N1, data_24h_with_pfc_67bus_B2_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B3_N1, data_24h_with_pfc_67bus_B3_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B4_N1, data_24h_with_pfc_67bus_B4_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B5_N1, data_24h_with_pfc_67bus_B5_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B6_N1, data_24h_with_pfc_67bus_B6_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B7_N1, data_24h_with_pfc_67bus_B7_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B8_N1, data_24h_with_pfc_67bus_B8_N1, time_steps_67bus, load_profile, CF_ON, CF_OFF)

# ## Reducing the DC line capacity except line 11
# for case_data in [data_with_pfc_67bus_B1_N1, data_with_pfc_67bus_B2_N1, data_with_pfc_67bus_B3_N1, data_with_pfc_67bus_B4_N1, data_with_pfc_67bus_B5_N1, data_with_pfc_67bus_B6_N1, data_with_pfc_67bus_B7_N1, data_with_pfc_67bus_B8_N1]
#     for (branchdc_id, branchdc_data) in case_data["branchdc"]
#         # if branchdc_id != "11"
#         #     branchdc_data["rateA"] *= 0.5
#         # end
#         if branchdc_data["index"] == 3
#             branchdc_data["status"] = 0
#         end
#     end
# end


# # scale_load!(data_with_pfc_67bus_B1_N1, data_24h_with_pfc_67bus_B1_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B2_N1, data_24h_with_pfc_67bus_B2_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B3_N1, data_24h_with_pfc_67bus_B3_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B4_N1, data_24h_with_pfc_67bus_B4_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B5_N1, data_24h_with_pfc_67bus_B5_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B6_N1, data_24h_with_pfc_67bus_B6_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B7_N1, data_24h_with_pfc_67bus_B7_N1, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B8_N1, data_24h_with_pfc_67bus_B8_N1, time_steps_67bus, load_profile)

# scale_load_ens!(data_with_pfc_67bus_B1_N1, data_24h_with_pfc_67bus_B1_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B2_N1, data_24h_with_pfc_67bus_B2_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B3_N1, data_24h_with_pfc_67bus_B3_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B4_N1, data_24h_with_pfc_67bus_B4_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B5_N1, data_24h_with_pfc_67bus_B5_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B6_N1, data_24h_with_pfc_67bus_B6_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B7_N1, data_24h_with_pfc_67bus_B7_N1, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B8_N1, data_24h_with_pfc_67bus_B8_N1, time_steps_67bus, load_profile)


# # Running the 24-hour simulation with PFC
# for t in time_steps_67bus

#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B1_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B1_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B1_N1[t] = results_24h_with_pfc_67bus_B1_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B2_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B2_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B2_N1[t] = results_24h_with_pfc_67bus_B2_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B3_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B3_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B3_N1[t] = results_24h_with_pfc_67bus_B3_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B4_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B4_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B4_N1[t] = results_24h_with_pfc_67bus_B4_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B5_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B5_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B5_N1[t] = results_24h_with_pfc_67bus_B5_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B6_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B6_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B6_N1[t] = results_24h_with_pfc_67bus_B6_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B7_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B7_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B7_N1[t] = results_24h_with_pfc_67bus_B7_N1[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B8_N1[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B8_N1[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B8_N1[t] = results_24h_with_pfc_67bus_B8_N1[t]["termination_status"]
# end 

# ens_check_with_pfc_B1_N1 = check_ens_activation(data_24h_with_pfc_67bus_B1_N1, results_24h_with_pfc_67bus_B1_N1, time_steps_67bus)
# ens_check_with_pfc_B2_N1 = check_ens_activation(data_24h_with_pfc_67bus_B2_N1, results_24h_with_pfc_67bus_B2_N1, time_steps_67bus)
# ens_check_with_pfc_B3_N1 = check_ens_activation(data_24h_with_pfc_67bus_B3_N1, results_24h_with_pfc_67bus_B3_N1, time_steps_67bus)
# ens_check_with_pfc_B4_N1 = check_ens_activation(data_24h_with_pfc_67bus_B4_N1, results_24h_with_pfc_67bus_B4_N1, time_steps_67bus)
# ens_check_with_pfc_B5_N1 = check_ens_activation(data_24h_with_pfc_67bus_B5_N1, results_24h_with_pfc_67bus_B5_N1, time_steps_67bus)
# ens_check_with_pfc_B6_N1 = check_ens_activation(data_24h_with_pfc_67bus_B6_N1, results_24h_with_pfc_67bus_B6_N1, time_steps_67bus)
# ens_check_with_pfc_B7_N1 = check_ens_activation(data_24h_with_pfc_67bus_B7_N1, results_24h_with_pfc_67bus_B7_N1, time_steps_67bus)
# ens_check_with_pfc_B8_N1 = check_ens_activation(data_24h_with_pfc_67bus_B8_N1, results_24h_with_pfc_67bus_B8_N1, time_steps_67bus)

# # Objective values extraction
# objective_values_no_pfc_67bus_N1      = [results_24h_no_pfc_67bus_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B1_N1 = [results_24h_with_pfc_67bus_B1_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B2_N1 = [results_24h_with_pfc_67bus_B2_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B3_N1 = [results_24h_with_pfc_67bus_B3_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B4_N1 = [results_24h_with_pfc_67bus_B4_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B5_N1 = [results_24h_with_pfc_67bus_B5_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B6_N1 = [results_24h_with_pfc_67bus_B6_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B6_N1 = [results_24h_with_pfc_67bus_B6_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B7_N1 = [results_24h_with_pfc_67bus_B7_N1[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B8_N1 = [results_24h_with_pfc_67bus_B8_N1[t]["objective"] for t in time_steps_67bus]



# # OF matrix
# OF_matrix_N1 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     OF_matrix_N1[t, 1] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B1_N1[t]
#     OF_matrix_N1[t, 2] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B2_N1[t]
#     OF_matrix_N1[t, 3] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B3_N1[t]
#     OF_matrix_N1[t, 4] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B4_N1[t]
#     OF_matrix_N1[t, 5] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B5_N1[t]
#     OF_matrix_N1[t, 6] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B6_N1[t]
#     OF_matrix_N1[t, 7] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B7_N1[t]
#     OF_matrix_N1[t, 8] = objective_values_no_pfc_67bus_N1[t] - objective_values_with_pfc_67bus_B8_N1[t]
# end

# D_matrix_N1 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     D_matrix_N1[t, 1] = results_24h_with_pfc_67bus_B1_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 2] = results_24h_with_pfc_67bus_B2_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 3] = results_24h_with_pfc_67bus_B3_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 4] = results_24h_with_pfc_67bus_B4_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 5] = results_24h_with_pfc_67bus_B5_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 6] = results_24h_with_pfc_67bus_B6_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 7] = results_24h_with_pfc_67bus_B7_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N1[t, 8] = results_24h_with_pfc_67bus_B8_N1[t]["solution"]["pfc"]["1"]["duty_cycle"]
# end

# # Internal capacitor voltage
# E_matrix_N1 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     E_matrix_N1[t, 1] = results_24h_with_pfc_67bus_B1_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 2] = results_24h_with_pfc_67bus_B2_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 3] = results_24h_with_pfc_67bus_B3_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 4] = results_24h_with_pfc_67bus_B4_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 5] = results_24h_with_pfc_67bus_B5_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 6] = results_24h_with_pfc_67bus_B6_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 7] = results_24h_with_pfc_67bus_B7_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N1[t, 8] = results_24h_with_pfc_67bus_B8_N1[t]["solution"]["pfc"]["1"]["c_voltage"]
# end

# # Prepare difference vector
# difference_vector_67bus_B1_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B2_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B3_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B4_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B5_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B6_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B7_N1 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B8_N1 = Vector{Any}(undef, length(time_steps_67bus))

# # Benefit calculation
# println("Calculating cost savings with PFCs at different locations...")
# println("================================")
# println("At Busbar 1:")
# saving_B1_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B1_N1, difference_vector_67bus_B1_N1, time_steps_67bus)
# println("At Busbar 2:")
# saving_B2_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B2_N1, difference_vector_67bus_B2_N1, time_steps_67bus)
# println("At Busbar 3:")
# saving_B3_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B3_N1, difference_vector_67bus_B3_N1, time_steps_67bus)
# println("At Busbar 4:")
# saving_B4_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B4_N1, difference_vector_67bus_B4_N1, time_steps_67bus)
# println("At Busbar 5:")
# saving_B5_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B5_N1, difference_vector_67bus_B5_N1, time_steps_67bus)
# println("At Busbar 6:")
# saving_B6_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B6_N1, difference_vector_67bus_B6_N1, time_steps_67bus)
# println("At Busbar 7:")
# saving_B7_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B7_N1, difference_vector_67bus_B7_N1, time_steps_67bus)
# println("At Busbar 8:")
# saving_B8_N1 = benefit_calculation(objective_values_no_pfc_67bus_N1, objective_values_with_pfc_67bus_B8_N1, difference_vector_67bus_B8_N1, time_steps_67bus)


# #Plot on top of previous plot
# scatter!(1:8, [saving_B1_N1,saving_B2_N1,saving_B3_N1,saving_B4_N1,saving_B5_N1,saving_B6_N1,saving_B7_N1,saving_B8_N1], xlabel="PFC Location", ylabel="Cost Saving [%]", title="Cost Saving over 24 hours with PFCs at Different Locations", legend=false, xticks=1:8)
# # savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_NO_CF_N1_last.png")

# ### N-1 at AC side

# ### N-1 Contingency analysis for the 67 bus system with and without PFCs
# data_24h_no_pfc_67bus_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_no_pfc_67bus_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_no_pfc_67bus_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B1_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B1_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B1_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B2_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B2_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B2_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B3_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B3_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B3_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B4_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B4_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B4_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B5_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B5_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B5_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B6_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B6_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B6_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B7_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B7_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B7_N2 = Vector{Any}(undef, length(time_steps_67bus))

# data_24h_with_pfc_67bus_B8_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# results_24h_with_pfc_67bus_B8_N2 = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# solution_status_with_pfc_67bus_B8_N2 = Vector{Any}(undef, length(time_steps_67bus))


# ### No PFC data
# # Loading data
# data_no_pfc_67bus_N2 = _PM.parse_file("./test/data/PFC/case67.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_no_pfc_67bus_N2)
# add_ens_gens!(data_no_pfc_67bus_N2)

# #Reduce all dc branches capacity by 50%
# # for (branchdc_id, branchdc_data) in data_no_pfc_67bus_N2["branchdc"]
# #     if branchdc_id != "11"
# #         branchdc_data["rateA"] *= 0.5
# #     end
# #     # if branchdc_data["index"] == 3
# #     #     branchdc_data["status"] = 0
# #     # end
# # end

# for (branch_id, branch_data) in data_no_pfc_67bus_N2["branch"]
#     if branch_data["index"] == 41
#         branch_data["br_status"] = 0
#     end
# end

# # Scale load and wind generation
# # scale_load_wind!(data_no_pfc_67bus_N2, data_24h_no_pfc_67bus_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load!(data_no_pfc_67bus_N2, data_24h_no_pfc_67bus_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_no_pfc_67bus_N2, data_24h_no_pfc_67bus_N2, time_steps_67bus, load_profile)

# # Running the 24-hour simulation without PFC
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_no_pfc_67bus_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_no_pfc_67bus_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_no_pfc_67bus_N2[t] = results_24h_no_pfc_67bus_N2[t]["termination_status"]
# end

# ens_check_no_pfc_N2 = check_ens_activation(data_24h_no_pfc_67bus_N2, results_24h_no_pfc_67bus_N2, time_steps_67bus)

# ### PFC data
# #Loading data
# data_with_pfc_67bus_B1_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B1.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B1_N2)
# add_ens_gens!(data_with_pfc_67bus_B1_N2)

# data_with_pfc_67bus_B2_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B2.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B2_N2)
# add_ens_gens!(data_with_pfc_67bus_B2_N2; VOLL = 20000)

# data_with_pfc_67bus_B3_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B3.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B3_N2)
# add_ens_gens!(data_with_pfc_67bus_B3_N2; VOLL = 20000)

# data_with_pfc_67bus_B4_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B4.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B4_N2)
# add_ens_gens!(data_with_pfc_67bus_B4_N2; VOLL = 20000)

# data_with_pfc_67bus_B5_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B5.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B5_N2)
# add_ens_gens!(data_with_pfc_67bus_B5_N2; VOLL = 20000)

# data_with_pfc_67bus_B6_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B6.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B6_N2)
# add_ens_gens!(data_with_pfc_67bus_B6_N2)

# data_with_pfc_67bus_B7_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B7.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B7_N2)
# add_ens_gens!(data_with_pfc_67bus_B7_N2)

# data_with_pfc_67bus_B8_N2 = _PM.parse_file("./test/data/PFC/case67_PFC_B8.m")
# #Processing additional data
# _PMACDC.process_additional_data!(data_with_pfc_67bus_B8_N2)
# add_ens_gens!(data_with_pfc_67bus_B8_N2; VOLL = 20000)

# # Scale load and wind generation
# # scale_load_wind!(data_with_pfc_67bus_B1_N2, data_24h_with_pfc_67bus_B1_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B2_N2, data_24h_with_pfc_67bus_B2_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B3_N2, data_24h_with_pfc_67bus_B3_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B4_N2, data_24h_with_pfc_67bus_B4_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B5_N2, data_24h_with_pfc_67bus_B5_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B6_N2, data_24h_with_pfc_67bus_B6_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B7_N2, data_24h_with_pfc_67bus_B7_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)
# # scale_load_wind!(data_with_pfc_67bus_B8_N2, data_24h_with_pfc_67bus_B8_N2, time_steps_67bus, load_profile, CF_ON, CF_OFF)

# ## Reducing the DC line capacity except line 11
# for case_data in [data_with_pfc_67bus_B1_N2, data_with_pfc_67bus_B2_N2, data_with_pfc_67bus_B3_N2, data_with_pfc_67bus_B4_N2, data_with_pfc_67bus_B5_N2, data_with_pfc_67bus_B6_N2, data_with_pfc_67bus_B7_N2, data_with_pfc_67bus_B8_N2]
#     # for (branchdc_id, branchdc_data) in case_data["branchdc"]
#     #     if branchdc_id != "11"
#     #         branchdc_data["rateA"] *= 0.5
#     #     end
#     #     # if branchdc_data["index"] == 3
#     #     #     branchdc_data["status"] = 0
#     #     # end
#     # end
#     for (branch_id, branch_data) in case_data["branch"]
#         if branch_data["index"] == 41
#             branch_data["br_status"] = 0
#         end
#     end
# end


# # scale_load!(data_with_pfc_67bus_B1_N2, data_24h_with_pfc_67bus_B1_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B2_N2, data_24h_with_pfc_67bus_B2_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B3_N2, data_24h_with_pfc_67bus_B3_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B4_N2, data_24h_with_pfc_67bus_B4_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B5_N2, data_24h_with_pfc_67bus_B5_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B6_N2, data_24h_with_pfc_67bus_B6_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B7_N2, data_24h_with_pfc_67bus_B7_N2, time_steps_67bus, load_profile)
# # scale_load!(data_with_pfc_67bus_B8_N2, data_24h_with_pfc_67bus_B8_N2, time_steps_67bus, load_profile)

# scale_load_ens!(data_with_pfc_67bus_B1_N2, data_24h_with_pfc_67bus_B1_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B2_N2, data_24h_with_pfc_67bus_B2_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B3_N2, data_24h_with_pfc_67bus_B3_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B4_N2, data_24h_with_pfc_67bus_B4_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B5_N2, data_24h_with_pfc_67bus_B5_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B6_N2, data_24h_with_pfc_67bus_B6_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B7_N2, data_24h_with_pfc_67bus_B7_N2, time_steps_67bus, load_profile)
# scale_load_ens!(data_with_pfc_67bus_B8_N2, data_24h_with_pfc_67bus_B8_N2, time_steps_67bus, load_profile)


# # Running the 24-hour simulation with PFC
# for t in time_steps_67bus

#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B1_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B1_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B1_N2[t] = results_24h_with_pfc_67bus_B1_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B2_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B2_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B2_N2[t] = results_24h_with_pfc_67bus_B2_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B3_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B3_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B3_N2[t] = results_24h_with_pfc_67bus_B3_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B4_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B4_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B4_N2[t] = results_24h_with_pfc_67bus_B4_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B5_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B5_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B5_N2[t] = results_24h_with_pfc_67bus_B5_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B6_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B6_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B6_N2[t] = results_24h_with_pfc_67bus_B6_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B7_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B7_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B7_N2[t] = results_24h_with_pfc_67bus_B7_N2[t]["termination_status"]
# end
# for t in time_steps_67bus
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no", "linear_solver" => "ma27") 
#     results_24h_with_pfc_67bus_B8_N2[t] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus_B8_N2[t], _PM.IVRPowerModel, ipopt; setting = s)
#     solution_status_with_pfc_67bus_B8_N2[t] = results_24h_with_pfc_67bus_B8_N2[t]["termination_status"]
# end 

# # Check ens
# ens_check_with_pfc_B1_N2 = check_ens_activation(data_24h_with_pfc_67bus_B1_N2, results_24h_with_pfc_67bus_B1_N2, time_steps_67bus)
# ens_check_with_pfc_B2_N2 = check_ens_activation(data_24h_with_pfc_67bus_B2_N2, results_24h_with_pfc_67bus_B2_N2, time_steps_67bus)
# ens_check_with_pfc_B3_N2 = check_ens_activation(data_24h_with_pfc_67bus_B3_N2, results_24h_with_pfc_67bus_B3_N2, time_steps_67bus)
# ens_check_with_pfc_B4_N2 = check_ens_activation(data_24h_with_pfc_67bus_B4_N2, results_24h_with_pfc_67bus_B4_N2, time_steps_67bus)
# ens_check_with_pfc_B5_N2 = check_ens_activation(data_24h_with_pfc_67bus_B5_N2, results_24h_with_pfc_67bus_B5_N2, time_steps_67bus)
# ens_check_with_pfc_B6_N2 = check_ens_activation(data_24h_with_pfc_67bus_B6_N2, results_24h_with_pfc_67bus_B6_N2, time_steps_67bus)
# ens_check_with_pfc_B7_N2 = check_ens_activation(data_24h_with_pfc_67bus_B7_N2, results_24h_with_pfc_67bus_B7_N2, time_steps_67bus)
# ens_check_with_pfc_B8_N2 = check_ens_activation(data_24h_with_pfc_67bus_B8_N2, results_24h_with_pfc_67bus_B8_N2, time_steps_67bus)


# # Objective values extraction
# objective_values_no_pfc_67bus_N2      = [results_24h_no_pfc_67bus_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B1_N2 = [results_24h_with_pfc_67bus_B1_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B2_N2 = [results_24h_with_pfc_67bus_B2_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B3_N2 = [results_24h_with_pfc_67bus_B3_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B4_N2 = [results_24h_with_pfc_67bus_B4_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B4_N2 = [results_24h_with_pfc_67bus_B4_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B5_N2 = [results_24h_with_pfc_67bus_B5_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B6_N2 = [results_24h_with_pfc_67bus_B6_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B6_N2 = [results_24h_with_pfc_67bus_B6_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B7_N2 = [results_24h_with_pfc_67bus_B7_N2[t]["objective"] for t in time_steps_67bus]
# objective_values_with_pfc_67bus_B8_N2 = [results_24h_with_pfc_67bus_B8_N2[t]["objective"] for t in time_steps_67bus]

# #Print Qg


# # OF matrix
# OF_matrix_N2 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     OF_matrix_N2[t, 1] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B1_N2[t]
#     OF_matrix_N2[t, 2] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B2_N2[t]
#     OF_matrix_N2[t, 3] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B3_N2[t]
#     OF_matrix_N2[t, 4] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B4_N2[t]
#     OF_matrix_N2[t, 5] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B5_N2[t]
#     OF_matrix_N2[t, 6] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B6_N2[t]
#     OF_matrix_N2[t, 7] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B7_N2[t]
#     OF_matrix_N2[t, 8] = objective_values_no_pfc_67bus_N2[t] - objective_values_with_pfc_67bus_B8_N2[t]
# end

# D_matrix_N2 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     D_matrix_N2[t, 1] = results_24h_with_pfc_67bus_B1_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 2] = results_24h_with_pfc_67bus_B2_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 3] = results_24h_with_pfc_67bus_B3_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 4] = results_24h_with_pfc_67bus_B4_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 5] = results_24h_with_pfc_67bus_B5_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 6] = results_24h_with_pfc_67bus_B6_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 7] = results_24h_with_pfc_67bus_B7_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
#     D_matrix_N2[t, 8] = results_24h_with_pfc_67bus_B8_N2[t]["solution"]["pfc"]["1"]["duty_cycle"]
# end

# # Internal capacitor voltage
# E_matrix_N2 = zeros(Float64, length(load_profile), 8)
# for t in 1:length(load_profile)
#     E_matrix_N2[t, 1] = results_24h_with_pfc_67bus_B1_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 2] = results_24h_with_pfc_67bus_B2_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 3] = results_24h_with_pfc_67bus_B3_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 4] = results_24h_with_pfc_67bus_B4_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 5] = results_24h_with_pfc_67bus_B5_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 6] = results_24h_with_pfc_67bus_B6_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 7] = results_24h_with_pfc_67bus_B7_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
#     E_matrix_N2[t, 8] = results_24h_with_pfc_67bus_B8_N2[t]["solution"]["pfc"]["1"]["c_voltage"]
# end

# D_matrix_N2_rounded = round.(D_matrix_N2, digits=3)
# E_matrix_N2_rounded = round.(E_matrix_N2, digits=3)

# # Prepare difference vector
# difference_vector_67bus_B1_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B2_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B3_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B4_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B5_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B6_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B7_N2 = Vector{Any}(undef, length(time_steps_67bus))
# difference_vector_67bus_B8_N2 = Vector{Any}(undef, length(time_steps_67bus))

# # Benefit calculation
# println("Calculating cost savings with PFCs at different locations...")
# println("================================")
# println("At Busbar 1:")
# saving_B1_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B1_N2, difference_vector_67bus_B1_N2, time_steps_67bus)
# println("At Busbar 2:")
# saving_B2_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B2_N2, difference_vector_67bus_B2_N2, time_steps_67bus)
# println("At Busbar 3:")
# saving_B3_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B3_N2, difference_vector_67bus_B3_N2, time_steps_67bus)
# println("At Busbar 4:")
# saving_B4_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B4_N2, difference_vector_67bus_B4_N2, time_steps_67bus)
# println("At Busbar 5:")
# saving_B5_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B5_N2, difference_vector_67bus_B5_N2, time_steps_67bus)
# println("At Busbar 6:")
# saving_B6_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B6_N2, difference_vector_67bus_B6_N2, time_steps_67bus)
# println("At Busbar 7:")
# saving_B7_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B7_N2, difference_vector_67bus_B7_N2, time_steps_67bus)
# println("At Busbar 8:")
# saving_B8_N2 = benefit_calculation(objective_values_no_pfc_67bus_N2, objective_values_with_pfc_67bus_B8_N2, difference_vector_67bus_B8_N2, time_steps_67bus)

#Plot on top of previous plot
# scatter!(1:8, [saving_B1_N2,saving_B2_N2,saving_B3_N2,saving_B4_N2,saving_B5_N2,saving_B6_N2,saving_B7_N2,saving_B8_N2], xlabel="PFC Location", ylabel="Cost Saving [%]", title="Cost Saving over 24 hours with PFCs at Different Locations", legend=false, xticks=1:8)
# savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_NO_CF_N1_last.png")


## Plotting results

base_saving = [saving_B1, saving_B2, saving_B3, saving_B4, saving_B5, saving_B6, saving_B7, saving_B8]

AC_saving = [saving_B1_N2, saving_B2_N2, saving_B3_N2, saving_B4_N2, saving_B5_N2, saving_B6_N2, saving_B7_N2, saving_B8_N2]

DC_saving = [saving_B1_N1, saving_B2_N1, saving_B3_N1, saving_B4_N1, saving_B5_N1, saving_B6_N1, saving_B7_N1, saving_B8_N1]

scatter(1:8, base_saving;
    label = "Base case",
    markershape = :circle,
    color = :blue,
    markersize = 7,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8,
    legend = :topright,
    xlabel = "PFC Location",
    ylabel = "Cost Saving [%]",
    title = "Cost Saving over 24 hours with PFCs",
    xticks = 1:8
)

scatter!(1:8, AC_saving;
    label = "AC N-1",
    markershape = :diamond,
    color = :orange,
    markersize = 7,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8
)

scatter!(1:8, DC_saving;
    label = "DC N-1",
    markershape = :square,
    color = :green,
    markersize = 7,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8
)

# savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_24h_all_locations_V2.png")

####### Correction of the cost benefits
### Bypassin when delta cost is negative

OF_matrix_corrected = max.(OF_matrix, 0.0)
OF_matrix_corrected_N1 = max.(OF_matrix_N1, 0.0)
OF_matrix_corrected_N2 = max.(OF_matrix_N2, 0.0)

daily_savings_corrected = sum(OF_matrix_corrected, dims=1)
daily_savings_corrected_N1 = sum(OF_matrix_corrected_N1, dims=1)
daily_savings_corrected_N2 = sum(OF_matrix_corrected_N2, dims=1)


total_of_no_pfc = sum(objective_values_no_pfc_67bus)
total_of_no_pfc_N1 = sum(objective_values_no_pfc_67bus_N1)
total_of_no_pfc_N2 = sum(objective_values_no_pfc_67bus_N2)

cost_saving_percentages_corrected = vec(daily_savings_corrected ./ total_of_no_pfc * 100)
cost_saving_percentages_corrected_N1 = vec(daily_savings_corrected_N1 ./ total_of_no_pfc_N1 * 100)
cost_saving_percentages_corrected_N2 = vec(daily_savings_corrected_N2 ./ total_of_no_pfc_N2 * 100)


cost_saving_percentages_corrected_rounded = round.(cost_saving_percentages_corrected, digits=2)
cost_saving_percentages_corrected_N1_rounded = round.(cost_saving_percentages_corrected_N1, digits=2)
cost_saving_percentages_corrected_N2_rounded = round.(cost_saving_percentages_corrected_N2, digits=2)

## Plotting corrected savings

scatter(1:8, cost_saving_percentages_corrected_rounded;
    label = "Base case",
    markershape = :circle,
    color = :blue,
    markersize = 5,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8,
    legend = :topright,
    xlabel = "PFC Location",
    ylabel = "Cost Saving [%]",
    title = "Cost Saving over 24 hours with PFCs",
    xticks = 1:8
)

# savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_24h_all_locations_V2_1.png")

scatter!(1:8, cost_saving_percentages_corrected_N1_rounded;
    label = "DC N-1",
    markershape = :diamond,
    color = :red,
    markersize = 5,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8
)

# savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_24h_all_locations_V2_2.png")


scatter!(1:8, cost_saving_percentages_corrected_N2_rounded;
    label = "AC N-1",
    markershape = :square,
    color = :green,
    markersize = 5,
    markerstrokecolor = :black,
    markerstrokewidth = 0.8
)

# savefig("/Users/rgallo/Desktop/figures/PFC_saving_67bus_Congestion_24h_all_locations_V2_3_2_04.png")

## PFC activation

# A1 = OF_matrix_corrected .> 0
# A2 = OF_matrix_corrected_N1 .> 0
# A3 = OF_matrix_corrected_N2 .> 0

E_matrix_rounded = round.(E_matrix, digits=3)
E_matrix_N1_rounded = round.(E_matrix_N1, digits=3)
E_matrix_N2_rounded = round.(E_matrix_N2, digits=3)

A1 = E_matrix_rounded .!= 0
A2 = E_matrix_N1_rounded .!= 0
A3 = E_matrix_N2_rounded .!= 0



# cmap = cgrad([:blue, :green], 2; categorical=true)


# heatmap(A1; c=cmap, colorbar=false,
#     xlabel="PFC Location",
#     ylabel="Hour",
#     title="PFC Activation (1 = Active, 0 = Bypass)")


heatmap(1:8, 1:length(load_profile), A1; xlabel="PFC Location", ylabel="Time Step", title="PFC Activation - Base Case", color=:greens,xticks=1:8, colorbar=false)

# savefig("/Users/rgallo/Desktop/figures/PFC_activation_67bus_Congestion_24h_all_locations_BaseCase_2_04.png")

heatmap(1:8, 1:length(load_profile), A2; xlabel="PFC Location", ylabel="Time Step", title="PFC Activation - DC N-1", color=:greens,xticks=1:8, colorbar=false)

# savefig("/Users/rgallo/Desktop/figures/PFC_activation_67bus_Congestion_24h_all_locations_DC_N1_2_04.png")

heatmap(1:8, 1:length(load_profile), A3; xlabel="PFC Location", ylabel="Time Step", title="PFC Activation - AC N-1", color=:greens,xticks=1:8, colorbar=false)

# savefig("/Users/rgallo/Desktop/figures/PFC_activation_67bus_Congestion_24h_all_locations_AC_N1_2_04.png")

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

function scale_load_ens_wind!(data, data_24h, time_steps, p_mult,cf_on,cf_off)
    offshore_wind_ids = ["20"]
    onshore_wind_ids = ["2","4"]
    for t in time_steps
        data_copy = deepcopy(data)
        for (load_id, load_data) in data_copy["load"]
            load_data["pd"] *= p_mult[t]
        end
        for (gen_id, gen) in data_copy["gen"]
            if gen["index"] > 20
                gen["pmax"] *= p_mult[t]
            end
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

# function scale_load_ens_matrix!(data, data_24h, time_steps, p_mult)
#     for t in time_steps
#         data_copy = deepcopy(data)
#         for (load_id, load_data) in data_copy["load"]
#             load_data["pd"] *= p_mult[t]
#             # load_data["qd"] *= p_mult[t]
#         end
#         for (gen_id, gen) in data_copy["gen"]
#             if gen["index"] > 20
#                 gen["pmax"] *= p_mult[t]
#             end
#         end
#         data_24h[t] = data_copy
#     end
# end

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

function compute_ens_gen_matrix!(data_24h, results_24h, time_steps, ens_outputs)
    for t in time_steps
        for (gen_id, gen) in results_24h[t]["solution"]["gen"]
            if data_24h[t]["gen"]["$gen_id"]["index"] > 20
                ens_outputs[t, data_24h[t]["gen"]["$gen_id"]["index"] - 20] = round(gen["pg"], digits=3)
            end
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

function check_termination_status(results_24h)
    T,C = size(results_24h)
    termination_status = []
    for t in 1:T
        for c in 1:C
            status = string(results_24h[t,c]["termination_status"])
            if status != "LOCALLY_SOLVED"
                push!(termination_status, (t,c,status))
            end
        end
    end
    return termination_status
end



# pfc_bus = ["B1","B2","B3","B4","B5","B6","B7","B8"]

# # data_24h_pfc = Dict{String, Vector{Dict{String,Any}}}()
# # results_24h_pfc = Dict{String, Vector{Dict{String,Any}}}()
# # solution_status_24_pfc = Dict{String, Vector{Any}}()

# # for pfc in pfc_bus
# #     data_24h_pfc[pfc] = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# #     results_24h_pfc[pfc] = Vector{Dict{String,Any}}(undef, length(time_steps_67bus))
# #     solution_status_24_pfc[pfc] = Vector{Any}(undef, length(time_steps_67bus))
# # end

# # ## With PFC data

# # n_locations = 8
# # i=1
# for i in 1:8

#     # data_24h_with_pfc_67bus = Array{Dict{String,Any}}(undef, length(time_steps_67bus), n_locations)
#     # results_24h_with_pfc_67bus = Array{Dict{String,Any}}(undef, length(time_steps_67bus), n_locations)
#     # solution_status_with_pfc_67bus = Array{Any}(undef, length(time_steps_67bus), n_locations)

#     path = "./test/data/PFC/case67_PFC_B$i.m"
#     data_with_pfc_67bus = _PM.parse_file(path)

#     #Processing additional data
#     _PMACDC.process_additional_data!(data_with_pfc_67bus)

#     # Scale load and wind generation
#     scale_load_wind!(data_with_pfc_67bus, data_24h_with_pfc_67bus, time_steps_67bus, load_profile, CF_ON, CF_OFF)

#     # Running the 24-hour simulation with PFC
#     for t in time_steps_67bus
#         ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3,"warm_start_init_point" => "no") 
#         results_24h_with_pfc_67bus[t,i] = _PMACDC.solve_acdcopf_iv(data_24h_with_pfc_67bus[t,i], _PM.IVRPowerModel, ipopt; setting = s)
#         solution_status_with_pfc_67bus[t,i] = results_24h_with_pfc_67bus[t,i]["termination_status"]
#     end 
# end

########### For parallel run TODO

# jobs = []

# for t in time_steps_67bus

#     # Base case
#     push!(jobs, (:base, :no_pfc, t, nothing))
#     push!(jobs, (:base, :B2,     t, nothing))
#     push!(jobs, (:base, :B3,     t, nothing))
#     push!(jobs, (:base, :B4,     t, nothing))
#     push!(jobs, (:base, :B8,     t, nothing))

#     # DC contingencies
#     for (i,dc) in enumerate(dc_branches)
#         push!(jobs, (:dc, :no_pfc, t, dc))
#         push!(jobs, (:dc, :B2,     t, dc))
#         push!(jobs, (:dc, :B3,     t, dc))
#         push!(jobs, (:dc, :B4,     t, dc))
#         push!(jobs, (:dc, :B8,     t, dc))
#     end

#     # AC contingencies
#     for (i,ac) in enumerate(ac_branches)
#         push!(jobs, (:ac, :no_pfc, t, ac))
#         push!(jobs, (:ac, :B2,     t, ac))
#         push!(jobs, (:ac, :B3,     t, ac))
#         push!(jobs, (:ac, :B4,     t, ac))
#         push!(jobs, (:ac, :B8,     t, ac))
#     end
# end

# results = pmap(jobs) do (case_type, pfc_case, t, cont_id)

#     data_input = 
#         pfc_case == :no_pfc ? data_24h_no_pfc_67bus :
#         pfc_case == :B2     ? data_24h_with_pfc_67bus_B2 :
#         pfc_case == :B3     ? data_24h_with_pfc_67bus_B3 :
#         pfc_case == :B4     ? data_24h_with_pfc_67bus_B4 :
#         pfc_case == :B8     ? data_24h_with_pfc_67bus_B8 :
#         error("Invalid PFC case: $pfc_case")

#     solve_single_opf(case_type, data_input, t, cont_id, s)
# end

# # Saving results

# for ((case_type, pfc_case, t, cont_id), res) in zip(jobs, results)

#     if case_type == :base
#         c = 1
        



# ### For parellel run

# @everywhere function solve_single_opf(case_type::Symbol, data_input::Vector, t::Int, cont_id, s)
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0,"warm_start_init_point" => "no", "linear_solver" => "ma57")

#     data_run = deepcopy(data_input[t])

#     if case_type == :dc
#         data_run["branchdc"][cont_id]["status"] = 0
#     elseif case_type == :ac
#         data_run["branch"][cont_id]["br_status"] = 0
#     elseif case_type == :base
#         # No changes needed for base case
#     else
#         error("Invalid case type: $case_type")
#     end

#     return _PMACDC.solve_acdcopf_iv(data_run, _PM.IVRPowerModel, ipopt; setting = s)
# end