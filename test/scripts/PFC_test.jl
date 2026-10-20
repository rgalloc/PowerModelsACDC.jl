using PowerModelsACDC
import PowerModels
import Ipopt

ipopt = optimizer_with_attributes(Ipopt.Optimizer, "tol" => 1e-6, "print_level" => 0)

file = pkgdir(PowerModelsACDC, "test", "data", "PFC", "prosecco_base.m")
file_pfc = pkgdir(PowerModelsACDC, "test", "data", "PFC", "prosecco_base_pfc.m")
# file_pfc2 = pkgdir(PowerModelsACDC, "test", "data", "PFC", "case5_acdc_pfc2.m")

data = parse_file(file)
data_pfc = parse_file(file_pfc)
# data_pfc2 = parse_file(file_pfc2)
s = Dict("conv_losses_mp" => true)

resultIVR = solve_acdcopf_iv(file, PowerModels.IVRPowerModel, ipopt; setting=s)
resultIVR_pfc = solve_acdcopf_iv(file_pfc, PowerModels.IVRPowerModel, ipopt; setting=s)
# resultIVR_pfc2 = solve_acdcopf_iv(file_pfc2, PowerModels.IVRPowerModel, ipopt; setting=s)

# ipfc_dc = PowerModels.var(pm, :ipfc_dc)

# @which PowerModels.sol_component_value_edge

# @less PowerModels.sol_component_value_edge
