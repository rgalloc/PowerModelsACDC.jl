using PowerModels ; const _PM = PowerModels
using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using JuMP
using Ipopt

# Testing PFC addition 

## Data with no PFC added 

data = _PM.parse_file("./test/data/case5_acdc.m")

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Data with PFC added
data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

data["pfc"] = Dict( "1" => Dict(
                                "pfc_status" => 1,
                                "terminal1_bus"  => 1,
                                "terminal2_bus"  => 4,
                                "terminal3_bus"  => 5,
                                "c_voltage_min"  => -4/345,
                                "c_voltage_max"  =>  4/345,
                                "duty_cycle_min" => 0.01,
                                "duty_cycle_max" => 0.99,
                                "pfc_current_min" => -1.2,
                                "pfc_current_max" => 1.2
                                    )
                    )

_PMACDC.process_additional_data!(data)

ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

resultIVR_PFC = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)

## Printing results
println("Results without PFC")
println("Objective: ", resultIVR["objective"])
println("Termination status: ", resultIVR["termination_status"])
println("Results with PFC")
println("Objective: ", resultIVR_PFC["objective"])
println("Termination status: ", resultIVR_PFC["termination_status"])

















# data = _PM.parse_file("./test/data/case5_acdc.m")
# data = _PM.parse_file("./test/data/case5.m")

# _PMACDC.process_additional_data!(data)

# ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
# s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)

# resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)
# resultACPM = _PM.solve_opf(data, _PM.ACPPowerModel, ipopt; setting = s)

# # ref_add_pfc!


# data = _PM.parse_file("./test/data/case5_acdc_pfc.m")
# data["pfc"] = Dict( "1" => Dict(
#                                 "pfc_status" => 1,
#                                 "terminal1_bus"  => 1,
#                                 "terminal2_bus"  => 4,
#                                 "terminal3_bus"  => 5,
#                                 "emin"  => -4/345,
#                                 "emax"  =>  4/345
# ))


# pm = _PM.instantiate_model(data, ACPPowerModel, build_opf; setting = s)
# ref_data = _PM.ref(pm)

# ref_data[:pfc] = Dict(x for x in ref_data[:pfc] if (x.second["pfc_status"] == 1 && x.second["terminal1_bus"] in keys(ref_data[:busdc]) && x.second["terminal2_bus"] in keys(ref_data[:busdc]) && x.second["terminal3_bus"] in keys(ref_data[:busdc])))

# ref_data[:arcs_from_12_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal2_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 2
# ref_data[:arcs_from_13_pfc] = [(i, pfc["terminal1_bus"],pfc["terminal3_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 2 to 1
# ref_data[:arcs_to_12_pfc]   = [(i, pfc["terminal2_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 1 to 3
# ref_data[:arcs_to_13_pfc]   = [(i, pfc["terminal3_bus"],pfc["terminal1_bus"]) for (i,pfc) in ref_data[:pfc]] # Current 3 to 1
# ref_data[:arcs_pfc] = [ref_data[:arcs_from_12_pfc]; ref_data[:arcs_from_13_pfc]; ref_data[:arcs_to_12_pfc]; ref_data[:arcs_to_13_pfc]]

#         bus_arcs_pfc = Dict((i, []) for (i,busdc) in ref_data[:busdc])
#         for (l,i,j) in ref_data[:arcs_pfc]
#             push!(bus_arcs_pfc[i], (l,i,j))
#         end
#         ref_data[:bus_arcs_pfc] = bus_arcs_pfc



#        ## Variable testing 
# nw = 0
#         duty_cycle = _PM.var(pm, nw)[:duty_cycle] = JuMP.@variable(pm.model,
#         [i in _PM.ids(pm, nw, :pfc)], base_name="$(nw)_duty_cycle",
#         start = 0.5
#     )
# pfc_id = _PM.ids(pm,0, :pfc)

# pfc_current = _PM.var(pm, nw)[:pfc_current] = JuMP.@variable(pm.model,
#         [(l,i,j) in _PM.ref(pm, nw, :arcs_pfc)], base_name="$(nw)_pfc_current",
#         start = 0.5 # To avoid division by zero, maybe change later
#     )
#     _PM.ref(pm, 0, :pfc, 1)

#     pfc_current  = _PM.var(pm, 0, :pfc_current)

#     for a in bus_arcs_pfc
#         println(a)
#     end

#     JuMP.@constraint(pm.model, sum(pfc_current[a] for a in values(bus_arcs_pfc)) == 0)

#     bus_arcs_dcgrid = ref_data[:bus_arcs_dcgrid]

#     pfc = _PM.ref(pm, 0, :pfc, 1)

#     duty_cycle = _PM.var(pm, 0, :duty_cycle, 1)
#     c_voltage = _PM.var(pm, 0, :c_voltage, 1)
#     busdc_terminal_1 = _PM.var(pm, 0, :busdc, 1)
#     busdc_terminal_2 = _PM.var(pm, 0, :busdc, 2)

#     JuMP.@constraint(pm.model, duty_cycle >= 0)

#     arcs_pfc = _PM.ref(pm, 0, :arcs_pfc)
#     (l,i,j) = arcs_pfc

#     ipfc_dc = _PM.var(pm, 0, :pfc_current, arcs_pfc)

#     JuMP.@constraint(pm.model, duty_cycle - abs(ipfc_dc[1])/(abs(ipfc_dc[1]) + abs(ipfc_dc[2]) + 1e-6) == 0)

#     arcs_pfc
#     terminal_1 = pfc["terminal1_bus"]
#     terminal_2 = pfc["terminal2_bus"]
#     terminal_3 = pfc["terminal3_bus"]
#     i2 = ipfc_dc[(terminal_1,terminal_2,terminal_1)]
#     i3 = ipfc_dc[(terminal_1,terminal_3,terminal_1)]

#     JuMP.@constraint(pm.model, duty_cycle - abs(i3)/(abs(i3) + abs(i2) + 1e-6) == 0)


#     ## KCL constraint test
#     # Original
#     JuMP.@constraint(pm.model, sum(igrid_dc[a] for a in bus_arcs_dcgrid) + sum(iconv_dc[c] for c in bus_convs_dc) + sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0) # deal with pd

#     # New
#     JuMP.@constraint(pm.model, sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0) # deal with pd

#     ref_data[:branchdc] = Dict([x for x in ref_data[:branchdc] if (x.second["status"] == 1 && x.second["fbusdc"] in keys(ref_data[:busdc]) && x.second["tbusdc"] in keys(ref_data[:busdc]))])
#     # DC grid arcs for DC grid branches
#     ref_data[:arcs_dcgrid_from] = [(i,branch["fbusdc"],branch["tbusdc"]) for (i,branch) in ref_data[:branchdc]]
#     ref_data[:arcs_dcgrid_to]   = [(i,branch["tbusdc"],branch["fbusdc"]) for (i,branch) in ref_data[:branchdc]]
#     ref_data[:arcs_dcgrid] = [ref_data[:arcs_dcgrid_from]; ref_data[:arcs_dcgrid_to]]
#     #bus arcs of the DC grid
#     bus_arcs_dcgrid = Dict([(bus["busdc_i"], []) for (i,bus) in ref_data[:busdc]])
#     for (l,i,j) in ref_data[:arcs_dcgrid]
#         push!(bus_arcs_dcgrid[i], (l,i,j))
#     end
#     ref_data[:bus_arcs_dcgrid] = bus_arcs_dcgrid

#     ref_data[:convdc] = Dict([x for x in ref_data[:convdc] if (x.second["status"] == 1 && x.second["busdc_i"] in keys(ref_data[:busdc]) && x.second["busac_i"] in keys(ref_data[:bus]))])

#     ref_data[:arcs_conv_acdc] = [(i,conv["busac_i"],conv["busdc_i"]) for (i,conv) in ref_data[:convdc]]

#     # Bus converters for existing ac buses
#     bus_convs_dc = Dict([(bus["busdc_i"], []) for (i,bus) in ref_data[:busdc]])
#     ref_data[:bus_convs_dc]= assign_bus_converters!(ref_data[:convdc], bus_convs_dc, "busdc_i") 

#     igrid_dc = _PM.var(pm, nw)[:igrid_dc] = JuMP.@variable(pm.model,
#     [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_igrid_dc",
#     start = (_PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 0.0) / 1)
#     )

#     ### Test with branches and pfc
#     igrid_dc = _PM.var(pm, nw)[:igrid_dc] = JuMP.@variable(pm.model,
#     [(l,i,j) in _PM.ref(pm, nw, :arcs_dcgrid)], base_name="$(nw)_igrid_dc",
#     start = (_PM.comp_start_value(_PM.ref(pm, nw, :branchdc, l), "p_start", 0.0) / 1)
#     )

#     igrid_dc_set = Dict(
#     1 => [],
#     2 => [(2, 2, 3), (1, 2, 4)],
#     3 => [(2, 3, 2), (3, 3, 5)],
#     4 => [(1, 4, 2)],
#     5 => [(3, 5, 3)]
# )

# pfc_current_set = Dict(
#     1 => [(1, 1, 4), (1, 1, 5)],
#     2 => [],
#     3 => [],
#     4 => [(1, 4, 1)],
#     5 => [(1, 5, 1)]
# )

#     JuMP.@constraint(pm.model, sum(igrid_dc[a] for a in igrid_dc_set) + sum(ipfc_dc[a] for a in pfc_current_set)== 0)

#     JuMP.@constraint(pm.model,sum(ipfc_dc[a] for a in bus_arcs_pfc)== 0)
    
#     keys(igrid_dc)


#     ##### Testing function

#     data = _PM.parse_file("./test/data/case5_acdc_pfc.m")

#     data["pfc"] = Dict( 1 => Dict(
#                                 "pfc_status" => 1,
#                                 "terminal1_bus"  => 1,
#                                 "terminal2_bus"  => 4,
#                                 "terminal3_bus"  => 5,
#                                 "c_voltage_min"  => -4/345,
#                                 "c_voltage_max"  =>  4/345,
#                                 "duty_cycle_min" => 0.01,
#                                 "duty_cycle_max" => 0.99,
#                                 "pfc_current_min" => -1.2,
#                                 "pfc_current_max" => 1.2
#                                     )
#                     )
#     _PMACDC.process_additional_data!(data)
#     ipopt = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)
#     s = Dict("output" => Dict("branch_flows" => true), "conv_losses_mp" => true)
#     resultIVR = _PMACDC.solve_acdcopf_iv(data, _PM.IVRPowerModel, ipopt; setting = s)