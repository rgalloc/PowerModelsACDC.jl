using PowerModelsACDC
import PowerModels
import Ipopt

#solver and settings
nlsolver = optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 4)
s = Dict("conv_losses_mp" => true)

# data parsing
data = PowerModels.parse_file("test/data/prosecco.m")
process_additional_data!(data)

# for (convdc_id, convdc) in data["convdc"]
#     println("Converter $convdc_id: busdc=$(convdc["busdc_i"]), busac=$(convdc["busac_i"]), type_dc=$(convdc["type_dc"]), type_ac=$(convdc["type_ac"])")
#     println("  Imax=$(convdc["Imax"]), Vdcset=$(convdc["Vdcset"]), Pacmax=$(convdc["Pacmax"]), Qacmax=$(convdc["Qacmax"])")
# end

result = solve_acdcopf(data, PowerModels.ACPPowerModel, nlsolver; setting=s)

# print results
for (gen_id, gen) in result["solution"]["gen"]
    println("Generator $gen_id: Pg=$(gen["pg"]), Qg=$(gen["qg"])")
end

for (convdc_id, convdc) in result["solution"]["convdc"]
    println("Converter $convdc_id: Pac=$(convdc["pconv"]), Pdc=$(convdc["pdc"]), Ploss=$(convdc["pconv"] + convdc["pdc"])")
end

for (bus_id, bus) in result["solution"]["bus"]
    println("Bus $bus_id: Vrm=$(bus["vm"]), Va=$(bus["va"])")
end

for (busdc_id, busdc) in result["solution"]["busdc"]
    println("DC Bus $busdc_id: Vdc=$(busdc["vm"])")
end

for (branchdc_id, branchdc) in result["solution"]["branchdc"]
    println("DC Branch $branchdc_id: pt=$(branchdc["pt"]), pf=$(branchdc["pf"])")
end

# Reduciton of OWF capacity factor

data_cf = deepcopy(data)
CF = 0.5

data_cf["gen"]["4"]["pmax"] = CF * data["gen"]["4"]["pmax"]
data_cf["gen"]["5"]["pmax"] = CF * data["gen"]["5"]["pmax"]

result_cf = solve_acdcopf(data_cf, PowerModels.ACPPowerModel, nlsolver; setting=s)

# print results
for (gen_id, gen) in result_cf["solution"]["gen"]
    println("Generator $gen_id: Pg=$(gen["pg"]), Qg=$(gen["qg"])")
end