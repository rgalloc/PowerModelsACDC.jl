using PowerModelsACDC ; const _PMACDC = PowerModelsACDC
using PowerModels     ; const _PM = PowerModels
using Ipopt

## Code to test the PFC implementation into PowerModelsACDC
## Add a three-point element to the test case in the DC grid that redirects the power flows
## Based on the variable 'D' 

# Load test case data
# Modified 5 bus to include the additional 2 dc buses after the PFC
filepath = "test/data/case5_acdc_PFC.m"
data = _PM.parse_file(filepath)