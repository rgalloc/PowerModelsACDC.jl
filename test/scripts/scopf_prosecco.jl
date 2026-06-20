using PowerModelsACDC
import PowerModels
import Ipopt

#solver and settings
nlsolver = optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
s = Dict("conv_losses_mp" => true)

# data parsing
data = PowerModels.parse_file("test/data/prosecco.m")
process_additional_data!(data)

LF = [0.75, 1, 1.25]
CF = [0.25, 0.5, 0.75, 1]
results_dict = Dict{Tuple{Float64, Float64}, Any}()
    
for lf in LF
    for cf in CF
        data_run = scale_load_wind(data, lf, cf)
        result_run = solve_acdcopf(data_run, PowerModels.ACPPowerModel, nlsolver; setting=s)

        results_dict[(lf, cf)] = result_run
    end
end

# print results for each case
for (lf, cf) in keys(results_dict)
    println("Results for Load Factor = $lf, Capacity Factor = $cf")
    for (gen_id, gen) in results_dict[(lf, cf)]["solution"]["gen"]
        println("Generator $gen_id: Pg = $(gen["pg"]), Qg = $(gen["qg"])")
    end
end




# print results
for (gen_id, gen) in result["solution"]["gen"]
    println("Generator $gen_id: Pg = $(gen["pg"]), Qg = $(gen["qg"])")
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


function scale_load_wind(data, LF, CF)
    data_run = deepcopy(data)
    for (load_id, load) in data_run["load"]
        data_run["load"][load_id]["pd"] = LF * data["load"][load_id]["pd"]
    end
    for (gen_id, gen) in data_run["gen"]
        if gen_id in ["4", "5"]
            data_run["gen"][gen_id]["pmax"] = CF * data["gen"][gen_id]["pmax"]
        end
    end
    return data_run
end