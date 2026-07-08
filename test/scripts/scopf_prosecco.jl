using PowerModelsACDC
import PowerModels
import Ipopt
import Plots

#solver and settings
nlsolver = optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 3)
s = Dict("conv_losses_mp" => true)

 # data parsing
# data_single = PowerModels.parse_file("test/data/prosecco_base.m")
# data_single = PowerModels.parse_file("test/data/prosecco_scopf.m")
# process_additional_data!(data_single)

# result_single = solve_acdcopf(data_single, PowerModels.ACPPowerModel, nlsolver; setting=s)

# for (c,conv) in result_single["solution"]["convdc"]
#     println("Conv ID:  $c  Pdc: $(conv["pdc"])")
# end

# for (bdc,branchdc) in result_single["solution"]["branchdc"]
#     println("Branch ID:  $bdc  Pdc: $(branchdc["pf"])")
# end

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

# file = pkgdir(PowerModelsACDC, "test", "data", "case5acdc_scopf.m")
file = pkgdir(PowerModelsACDC, "test", "data", "prosecco_scopf.m")
# file = pkgdir(PowerModelsACDC, "test", "data", "prosecco_scopf_2.m")

data = PowerModels.parse_file(file)

kmax = 100
dc_converter_passivity = true


for (c, conv) in data["convdc"]
    conv["kmax"] = kmax
end

for (g, gen) in data["gen"]
    if g in ["4", "5"]
        gen["gen_slack"] = 0.02
    else
        gen["gen_slack"] = 1
    end
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
s = Dict("conv_losses_mp" => true, "optimize_converter_droop" => true, "objective_components" => ["gen","demand"], "dc_converter_passivity" => dc_converter_passivity)

# Random generation and demand time series, later replace with something more representative
# g_series = [1.0 0.7 0.75 0.78 0.85]
# l_series = [1.0 0.7 0.75 0.78 0.85]
g_series = [1.0 0.7 0.75]
l_series = [1.0 0.7 0.75]
# Select the nunmber of hours for which you want to run the optimisation
number_of_hours = 1
# get the number of contingencies from the data dictionary
number_of_contingencies = length(data["contingencies"])

# Resistance parametrisation
alpha = 1
for (b, branch) in data["branchdc"]
    branch["r"] = alpha * branch["r"]
end

CF = 0.5
for (g_id, gen) in data["gen"]
    if g_id in ["4", "5"]
        gen["pmax"] = CF * gen["pmax"]
    end
end

data_all = create_scopf_data(data, number_of_hours, g_series, l_series)

# Manual setting of contingency
# data_all["nw"]["2"]["convdc"]["1"]["status"] = 0
# data_all["nw"]["3"]["convdc"]["2"]["status"] = 0
# data_all["nw"]["4"]["convdc"]["3"]["status"] = 0
# data_all["nw"]["5"]["convdc"]["4"]["status"] = 0
# data_all["nw"]["6"]["convdc"]["5"]["status"] = 0
# data_all["nw"]["7"]["convdc"]["6"]["status"] = 0
# data_all["nw"]["8"]["convdc"]["7"]["status"] = 0
# data_all["nw"]["9"]["convdc"]["8"]["status"] = 0
# data_all["nw"]["10"]["convdc"]["9"]["status"] = 0
# data_all["nw"]["11"]["convdc"]["10"]["status"] = 0


# Tighten the bounds for dc voltage in the first stage networks
# for (b,busdc) in  data_all["nw"]["1"]["busdc"]
#     busdc["Vdcmax"] = 1.05
#     busdc["Vdcmin"] = 0.95
# end

# N-1 
for idx = 1:10
    nw = idx + 1
    data_all["nw"]["$nw"]["convdc"]["$idx"]["status"] = 0
    # for (b, busdc) in  data_all["nw"]["$nw"]["busdc"]
    #     busdc["Vdcmax"] = 2
    #     busdc["Vdcmin"] = 0.2
    # end
end

# N-1 for both converters in the same station
# for idx = 2:2:10
#     nw = Int(idx/2) + 1
#     data_all["nw"]["$nw"]["convdc"]["$idx"]["status"] = 0
#     data_all["nw"]["$nw"]["convdc"]["$(idx-1)"]["status"] = 0
# end

# for idx = 4:9
#     nw = idx + 8
#     data_all["nw"]["$nw"]["branchdc"]["$idx"]["status"] = 0
# end

for idx = 1:6
    nw = idx + 9
    data_all["nw"]["$nw"]["branchdc"]["$idx"]["status"] = 0
end

# for idx = 4:9
#     nw = idx - 2
#     data_all["nw"]["$nw"]["branchdc"]["$idx"]["status"] = 0
# end

# for idx = 1:6
#     nw = idx + 1
#     data_all["nw"]["$nw"]["branchdc"]["$idx"]["status"] = 0
# end

# for nw in 1:number_of_hours * number_of_contingencies
#     for (b, busdc) in  data_all["nw"]["$nw"]["busdc"]
#         busdc["Vdcmax"] = 2
#         busdc["Vdcmin"] = 0.2
#     end
# end

# For 5 bus test case
# for idx = 1:3
#     nw = idx + 1
#     data_all["nw"]["$nw"]["convdc"]["$idx"]["status"] = 0
# end


# Solve OPF
result = solve_scopf(data_all, PowerModels.ACPPowerModel, nlsolver; multinetwork=true, setting=s)

############ Processing the results ###################
k_droop = zeros(number_of_hours, length(result["solution"]["nw"]["1"]["convdc"]))
pconv = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
qconv = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
pg = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["gen"]))
qg = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["gen"]))
pflex = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["load"]))
pred = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["load"]))
pcurt = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["load"]))
branch_flows = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["branchdc"]))
busdc_voltages = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["busdc"]))
ac_branch_flows = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["branch"]))

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
    for (bdc, branchdc) in network["branchdc"]
        branch_flows[parse(Int, n), parse(Int, bdc)] = max(abs(branchdc["pf"]), abs(branchdc["pt"]))*baseMVA
    end
    for (bdc, busdc) in network["busdc"]
        busdc_voltages[parse(Int, n), parse(Int, bdc)] = busdc["vm"]
    end
    for (b,branch) in network["branch"]
        ac_branch_flows[parse(Int, n), parse(Int, b)] = max(abs(branch["pf"]), abs(branch["pt"]))*baseMVA
    end
end

for (n,network) in result["solution"]["nw"]
    for (l,load) in network["load"]
        pflex[parse(Int, n), parse(Int, l)] = load["pflex"]*baseMVA
        pred[parse(Int, n), parse(Int, l)] = load["pred"]*baseMVA
        pcurt[parse(Int, n), parse(Int, l)] = load["pcurt"]*baseMVA
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

droop_u_diff = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
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

        droop_u_diff[n_idx, c_idx] = u_con - u_ref
        droop_p_diff[n_idx, c_idx] = (p_con - p_ref)
    end
end

# droop_p_diff_pu = droop_p_diff ./ data_all["nw"]["1"]["baseMVA"]
k_calc = droop_p_diff ./ droop_u_diff

max_k_droop = maximum(k_droop./kmax)

# Required delta P for converter outages
d_p_required = zeros(number_of_hours, length(result["solution"]["nw"]["1"]["convdc"]))
p_dc_ref = zeros(number_of_hours, length(result["solution"]["nw"]["1"]["convdc"]))
p_dc_free_cont = zeros(number_of_hours, length(result["solution"]["nw"]["1"]["convdc"]))

p_dc_ref = pconv[1:number_of_contingencies:end, :]

for i in 1:length(result["solution"]["nw"]["1"]["convdc"])
   if i >= 7
        p_dc_free_cont[i] = minimum(pconv[:, i])
   else
        p_dc_free_cont[i] = maximum(pconv[:, i])
   end
end

d_p_required = p_dc_free_cont - p_dc_ref

max_d_u = 1.1 - 1
k = 50

max_d_p = (k*max_d_u)*baseMVA

# Matrix of required voltages
p_dc_ref_mat = repeat(p_dc_ref,number_of_contingencies-1)
p_dc_free_cont_mat = pconv[2:end,:]
u_dc_ref = [busdc_voltages[1,1],busdc_voltages[1,1], busdc_voltages[1,2], busdc_voltages[1,2], busdc_voltages[1,3], busdc_voltages[1,3], busdc_voltages[1,4], busdc_voltages[1,4], busdc_voltages[1,5], busdc_voltages[1,5]]'
U_dc_ref = repeat(u_dc_ref,number_of_contingencies-1) #converter ref voltage

delta_P_required = (p_dc_free_cont_mat - p_dc_ref_mat) ./ baseMVA
delta_U_required = delta_P_required ./ (k*baseMVA)

Udc_required = U_dc_ref .+ delta_U_required
U_dc_required_calc = zeros(10,10)

U_free_mat = [busdc_voltages[2:end,1] busdc_voltages[2:end,1] busdc_voltages[2:end,2] busdc_voltages[2:end,2] busdc_voltages[2:end,3] busdc_voltages[2:end,3] busdc_voltages[2:end,4] busdc_voltages[2:end,4] busdc_voltages[2:end,5] busdc_voltages[2:end,5]]
U_error = zeros(10,10)

delta_U_free = U_free_mat - U_dc_ref
k_required = zeros(10,10)

for c in 1:10
    for n in 1:10
        if c == n
            U_dc_required_calc[n,c] = NaN
            U_error[n,c] = NaN
            k_required[n,c] = NaN
        else
            U_dc_required_calc[n,c] = u_dc_ref[c] + (p_dc_free_cont_mat[n,c] - p_dc_ref_mat[n,c])/(k*baseMVA)
            U_error[n,c] = U_dc_required_calc[n,c] - U_free_mat[n,c]
            k_required[n,c] = delta_P_required[n,c] / delta_U_free[n,c] 
        end
    end
end

# Required K for each converter to achieve the required voltage change


# Testing feasibility of the required Udc voltages at the converters
U_dc_station = [U_dc_required_calc[:,1] U_dc_required_calc[:,3] U_dc_required_calc[:,5] U_dc_required_calc[:,7] U_dc_required_calc[:,9]]
U_dc_station[1,1] = U_dc_station[2,1]
U_dc_station[3,2] = U_dc_station[4,2]
U_dc_station[5,3] = U_dc_station[6,3]
U_dc_station[7,4] = U_dc_station[8,4]
U_dc_station[9,5] = U_dc_station[10,5]

# Test 1: fixing Udc at converters and checking if the DC network can feasibly operate with the required voltages
# for n in 2:11
#     n_idx = n - 1
#     data_test_1["nw"]["$n_idx"] = deepcopy(data_all["nw"]["$n"])
# end
data_test_1 = deepcopy(data_all["nw"]["2"])
data_test_1["per_unit"] = true
for (b,busdc) in data_test_1["busdc"]
    if b in ["1", "2", "3", "4", "5"]
        busdc["Vdcmax"] = U_dc_station[1, parse(Int, b)]
        busdc["Vdcmin"] = U_dc_station[1, parse(Int, b)]
    end
end
data_test_1["convdc"]["2"]["type_dc"] = 3

# result_test_1 = solve_acdcopf(data_test_1, PowerModels.ACPPowerModel, nlsolver; setting=s)

# Print data to check that required voltages are assuigned correctly
# for (b,busdc) in data_test_1["busdc"]
#     println("Busdc ID:  $b Vdcmin: $(busdc["Vdcmin"]), Vdcmax: $(busdc["Vdcmax"])")
# end

# for (conv_id,conv) in data_test_1["convdc"]
#     println("-----------------")
#     println("Conv ID: $conv_id, Status: $(conv["status"]), DC bus ID: $(conv["busdc_i"]), DC bus min: $(data_test_1["busdc"][string(conv["busdc_i"])]["Vdcmin"]), DC bus max: $(data_test_1["busdc"][string(conv["busdc_i"])]["Vdcmax"])")
#     println("-----------------")
# end


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



# function scale_load_wind(data, LF, CF)
#     data_run = deepcopy(data)
#     for (load_id, load) in data_run["load"]
#         data_run["load"][load_id]["pd"] = LF * data["load"][load_id]["pd"]
#     end
#     for (gen_id, gen) in data_run["gen"]
#         # if gen_id in ["4", "5"]
#             data_run["gen"][gen_id]["pmax"] = CF * data["gen"][gen_id]["pmax"]
#         # end
#     end
#     return data_run
# end

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


# pg
# 17×5 Matrix{Float64}:
#  715.532  651.098  769.631  1000.0    1000.0
#  882.002  587.305  694.356   988.233   988.245
#  882.002  587.305  694.356   988.233   988.245
#  712.332  740.406  709.927   988.252   988.262
#  712.332  740.406  709.927   988.252   988.262
#  699.482  589.071  874.465   988.25    988.26
#  699.482  589.071  874.465   988.25    988.26
#  763.5    641.732  761.777   986.121   988.309
#  763.5    641.732  761.777   986.121   988.309
#  720.193  671.012  777.064   988.27    986.113
#  774.59   642.488  753.003   988.23    986.112
#  772.475  641.053  751.222   988.284   988.278
#  764.741  648.238  750.163   988.297   988.304
#  711.613  649.159  806.795   988.238   988.235
#  758.667  641.179  764.209   988.277   988.315
#  762.048  640.597  760.358   988.297   988.308
#  762.048  640.597  760.358   988.297   988.308