using PowerModelsACDC
import PowerModels
import Ipopt

ipopt = optimizer_with_attributes(Ipopt.Optimizer)
s = Dict("conv_losses_mp" => true)

data_no_pfc = PowerModels.parse_file("test/data/PFC/prosecco_base.m")
data_pfc = PowerModels.parse_file("test/data/PFC/prosecco_base_pfc.m")

process_additional_data!(data_no_pfc)
process_additional_data!(data_pfc)

result_base = solve_acdcopf_iv(data_no_pfc, PowerModels.IVRPowerModel, ipopt; setting=s)
result_pfc = solve_acdcopf_iv(data_pfc, PowerModels.IVRPowerModel, ipopt; setting=s)
