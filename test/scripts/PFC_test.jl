using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt

# Testing PFC addition 

data = _PM.parse_file("./test/data/case5_acdc.m")
data = _PM.parse_file("./test/data/case5.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)
resultACPM = _PM.solve_opf(data, _PM.ACPPowerModel, ipopt; setting = s)

# ref_add_pfc!


data = _PM.parse_file("./test/data/case5_acdc.m")
data["pfc"] = Dict( "1" => Dict(
                                "pfc_status" => 1,
                                "terminal1_bus"  => 1,
                                "terminal2_bus"  => 2,
                                "terminal3_bus"  => 3,
                                "emin"  => -4/345,
                                "emax"  =>  4/345
))


pm = _PM.instantiate_model(data, ACPPowerModel, build_opf; setting = s)
ref_data = _PM.ref(pm)

ref_data[:pfc] = Dict(x for x in ref_data[:pfc] if (x.second["pfc_status"] == 1 && x.second["terminal1_bus"] in keys(ref_data[:busdc]) && x.second["terminal2_bus"] in keys(ref_data[:busdc]) && x.second["terminal3_bus"] in keys(ref_data[:busdc])))

ref_data[:arcs_from_12_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal2_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 2
ref_data[:arcs_from_13_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal3_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 2 to 1
ref_data[:arcs_to_12_pfc]   = [(i, pfc["terminal2_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 3
ref_data[:arcs_to_13_pfc]   = [(i, pfc["terminal3_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 3 to 1
ref_data[:arcs_pfc] = [ref_data[:arcs_from_12_pfc]; ref_data[:arcs_from_13_pfc]; ref_data[:arcs_to_12_pfc]; ref_data[:arcs_to_13_pfc]]

        bus_arcs_pfc = Dict((i, []) for (i,busdc) in ref_data[:busdc])
        for (l,i,j) in ref_data[:arcs_pfc]
            push!(bus_arcs_pfc[i], (l,i,j))
        end
        ref_data[:bus_arcs_pfc] = bus_arcs_pfc
nw = 0
        duty_cycle = _PM.var(pm, nw)[:duty_cycle] = JuMP.@variable(pm.model,
        [i in _PM.ids(pm, nw, :pfc)], base_name="$(nw)_duty_cycle",
        start = 0.5
    )
pfc_id = _PM.ids(pm,0, :pfc)

pfc_current = _PM.var(pm, nw)[:pfc_current] = JuMP.@variable(pm.model,
        [(l,i,j) in _PM.ref(pm, nw, :arcs_pfc)], base_name="$(nw)_pfc_current",
        start = 0.5 # To avoid division by zero, maybe change later
    )
    _PM.ref(pm, 0, :pfc, 1)

    pfc_current  = _PM.var(pm, 0, :pfc_current)

    for a in bus_arcs_pfc
        println(a)
    end

    JuMP.@constraint(pm.model, sum(pfc_current[a] for a in values(bus_arcs_pfc)) == 0)

    bus_arcs_dcgrid = ref_data[:bus_arcs_dcgrid]

    pfc = _PM.ref(pm, 0, :pfc, 1)

    duty_cycle = _PM.var(pm, 0, :duty_cycle, 1)
    c_voltage = _PM.var(pm, 0, :c_voltage, 1)
    busdc_terminal_1 = _PM.var(pm, 0, :busdc, 1)
    busdc_terminal_2 = _PM.var(pm, 0, :busdc, 2)

    JuMP.@constraint(pm.model, duty_cycle >= 0)

    arcs_pfc = _PM.ref(pm, 0, :arcs_pfc)
    (l,i,j) = arcs_pfc

    ipfc_dc = _PM.var(pm, 0, :pfc_current, arcs_pfc)

    JuMP.@constraint(pm.model, duty_cycle - abs(ipfc_dc[1])/(abs(ipfc_dc[1]) + abs(ipfc_dc[2]) + 1e-6) == 0)

    arcs_pfc

    ipfc_dc[(1,1,2)]