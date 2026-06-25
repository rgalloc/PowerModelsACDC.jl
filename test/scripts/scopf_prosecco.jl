using PowerModelsACDC
import PowerModels
import Ipopt
import Plots

#solver and settings
nlsolver = optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3)
s = Dict("conv_losses_mp" => true)

 # data parsing
data_single = PowerModels.parse_file("test/data/prosecco_base.m")
process_additional_data!(data_single)

result_single = solve_acdcopf(data_single, PowerModels.ACPPowerModel, nlsolver; setting=s)

 # LF = [0.75, 1, 1.25]
 # CF = [0.25, 0.5, 0.75, 1]
# LF = [1.0 0.7 0.75 0.78 0.85]
# CF = [1.0 0.7 0.75 0.78 0.85]


# results_dict = Dict{Tuple{Float64, Float64}, Any}()
    
# for lf in LF
#     for cf in CF
#         data_run = scale_load_wind(data, lf, cf)
#         result_run = solve_acdcopf(data_run, PowerModels.ACPPowerModel, nlsolver; setting=s)

#         results_dict[(lf, cf)] = result_run
#     end
# end

# SCOPF

data = PowerModels.parse_file("test/data/prosecco_scopf.m")

kmax = 1e6
dc_converter_passivity = true


for (c, conv) in data["convdc"]
    conv["kmax"] = kmax
end

for (g, gen) in data["gen"]
    gen["gen_slack"] = 0.02
end

# Process demand reduction and curtailment data
for (l, load) in data["load"]
    data["load"][l]["pred_rel_max"] = 0.3
    data["load"][l]["cost_red"] = 100.0 * data["baseMVA"]
    data["load"][l]["cost_curt"] = 10000.0 * data["baseMVA"]
    data["load"][l]["flex"] = 1
end

# data["contingencies"]["2"]["dcbranch_id1"] = 0
# data["contingencies"]["2"]["dcconv_id1"] = 1
# data["contingencies"]["3"]["dcconv_id1"] = 2


# OPF settings
s = Dict("conv_losses_mp" => true, "optimize_converter_droop" => true, "objective_components" => ["gen"], "dc_converter_passivity" => dc_converter_passivity)

# Random generation and demand time series, later replace with something more representative
# g_series = [1.0 0.7 0.75 0.78 0.85]
# l_series = [1.0 0.7 0.75 0.78 0.85]
g_series = [1.0 0.7 0.75]
l_series = [1.0 0.7 0.75]
# Select the nunmber of hours for which you want to run the optimisation
number_of_hours = 1
# get the number of contingencies from the data dictionary
number_of_contingencies = length(data["contingencies"])

data_all = create_scopf_data(data, number_of_hours, g_series, l_series)

# N-1 
for idx = 1:6
    nw = idx + 1
    data_all["nw"]["$nw"]["convdc"]["$idx"]["status"] = 0
    # for (b, busdc) in  data_all["nw"]["$nw"]["busdc"]
    #     busdc["Vdcmax"] = 2
    #     busdc["Vdcmin"] = 0.2
    # end
end

# for idx = 4:9
#     nw = idx + 8
#     data_all["nw"]["$nw"]["branchdc"]["$idx"]["status"] = 0
# end

# for nw in 1:number_of_hours * number_of_contingencies
#     for (b, busdc) in  data_all["nw"]["$nw"]["busdc"]
#         busdc["Vdcmax"] = 2
#         busdc["Vdcmin"] = 0.2
#     end
# end


# Solve OPF
result = solve_scopf(data_all, PowerModels.ACPPowerModel, nlsolver; multinetwork=true, setting=s)

############ Processing the results ###################
k_droop = zeros(number_of_hours, length(result["solution"]["nw"]["1"]["convdc"]))
pconv = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
qconv = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
pg = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["gen"]))
qg = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["gen"]))
# pd = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["load"]))
branch_flows = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["branchdc"]))
busdc_voltages = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["busdc"]))

baseMVA = data_all["nw"]["1"]["baseMVA"]

for (c,conv) in result["solution"]["nw"]["1"]["convdc"]
    k_droop[1, parse(Int, c)] = conv["k_droop"]
end

for (n, network) in result["solution"]["nw"]
    for (g, gen) in network["gen"]
        pg[parse(Int, n), parse(Int, g)] = gen["pg"]*baseMVA
        qg[parse(Int, n), parse(Int, g)] = gen["qg"]*baseMVA
    end
    for (c, conv) in network["convdc"]
        pconv[parse(Int, n), parse(Int, c)] = conv["pdc"]*baseMVA
        qconv[parse(Int, n), parse(Int, c)] = conv["qconv"]*baseMVA
    end
    # for (l, load) in network["load"]
    #     pd[parse(Int, n), parse(Int, l)] = load["pflex"]
    # end
    for (bdc, branchdc) in network["branchdc"]
        branch_flows[parse(Int, n), parse(Int, bdc)] = max(abs(branchdc["pf"]), abs(branchdc["pt"]))*baseMVA
    end
    for (bdc, busdc) in network["busdc"]
        busdc_voltages[parse(Int, n), parse(Int, bdc)] = busdc["vm"]
    end
end

### Computing voltage differences

vdc_min = 0.9
vdc_max = 1.1

margin_low = busdc_voltages .- vdc_min
margin_high = vdc_max .- busdc_voltages

dc_voltage_diff = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["branchdc"]))

for (b,branchdc) in data_all["nw"]["1"]["branchdc"]
    b_idx = parse(Int, b)

    fbus = branchdc["fbusdc"]
    tbus = branchdc["tbusdc"]

    for n in 1:number_of_hours * number_of_contingencies
        u_f = busdc_voltages[n, fbus]
        u_t = busdc_voltages[n, tbus]

        dc_voltage_diff[n, b_idx] = abs(u_f - u_t)
    end
end

droop_v_diff = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
droop_p_diff = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))


for (n, network) in result["solution"]["nw"]
    n_idx = parse(Int, n)

    # Reference network of the corresponding hour
    ref_idx = div(n_idx - 1, number_of_contingencies) * number_of_contingencies + 1
    ref_key = string(ref_idx)

    for (c, conv) in network["convdc"]
        c_idx = parse(Int, c)

        busdc_id = string(data_all["nw"][ref_key]["convdc"][c]["busdc_i"])

        u_ref = result["solution"]["nw"][ref_key]["busdc"][busdc_id]["vm"]
        u_con = result["solution"]["nw"][n]["busdc"][busdc_id]["vm"]

        p_ref = result["solution"]["nw"][ref_key]["convdc"][c]["pdc"]
        p_con = result["solution"]["nw"][n]["convdc"][c]["pdc"]

        droop_v_diff[n_idx, c_idx] = u_con - u_ref
        droop_p_diff[n_idx, c_idx] = (p_con - p_ref) * data_all["nw"]["1"]["baseMVA"]
    end
end

droop_p_diff_pu = droop_p_diff ./ data_all["nw"]["1"]["baseMVA"]
k_calc = droop_p_diff_pu ./ droop_v_diff







# total_load = sum(pd, dims=2)
# total_gen = sum(pg, dims=2)
# losses = total_gen - total_load

# wind_pmax = zeros(number_of_hours * number_of_contingencies, 2)
# for (n, network) in data_all["nw"]
#     for (g, gen) in network["gen"]
#         if g in ["4", "5"]
#             wind_pmax[parse(Int, n), parse(Int, g)-3] = gen["pmax"] * data_all["nw"]["1"]["baseMVA"]
#         end
#     end
# end
# wind_pmax_total = sum(wind_pmax, dims=2)

# diff = wind_pmax_total - total_gen




# for (n, network) in result["solution"]["nw"]
#     if parse(Int, n) < data_all["number_of_contingencies"]
#         for (c, conv) in network["convdc"]
#             bus_id = data_all["nw"]["1"]["convdc"][c]["busdc_i"]
#             pd = result["solution"]["nw"][n]["convdc"][c]["pdc"] + (result["solution"]["nw"]["1"]["convdc"][c]["k_droop"] * (network["busdc"]["$bus_id"]["vm"] - result["solution"]["nw"][n]["busdc"]["$bus_id"]["vm"]))
#             println("Contingency ID: ", n, " Conv ID: ", c, " Pdc calc: ", pd, " Pdc: ", network["convdc"][c]["pdc"])
#         end
#     end
# end



function scale_load_wind(data, LF, CF)
    data_run = deepcopy(data)
    for (load_id, load) in data_run["load"]
        data_run["load"][load_id]["pd"] = LF * data["load"][load_id]["pd"]
    end
    for (gen_id, gen) in data_run["gen"]
        # if gen_id in ["4", "5"]
            data_run["gen"][gen_id]["pmax"] = CF * data["gen"][gen_id]["pmax"]
        # end
    end
    return data_run
end

# Postprocessing of results

# function dc_voltage_margins(busdc_voltages)
#     vdc_min = 0.9
#     vdc_max = 1.1

#     margin_low = busdc_voltages .- vdc_min
#     margin_high = vdc_max .- busdc_voltages

#     return margin_low, margin_high
# end

# function dc_branch_diff(busdc_voltages)
# end
