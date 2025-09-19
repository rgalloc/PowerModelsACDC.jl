using PowerModels ; const _PM = PowerModels
using PowerModelsACDC
using Ipopt

#Test new superconductivity model
data = _PM.parse_file("./test/data/superconductivity/case5_acdc_sc.m")