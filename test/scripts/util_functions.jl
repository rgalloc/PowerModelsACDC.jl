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