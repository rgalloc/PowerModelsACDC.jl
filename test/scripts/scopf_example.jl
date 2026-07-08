# A test script for running a simple preventive SCOPF model considering DC network contingencies, and optimising HVDC Converter droop gains

using PowerModelsACDC
import PowerModels
import Ipopt
import Plots

## Use first one for MA27, check the local path for your HSL library
ipopt = optimizer_with_attributes(Ipopt.Optimizer)


###### Load your test file
case_name = "case67"
kmax = 100
dc_converter_passivity = true
#######################

if case_name == "case5"
    file = pkgdir(PowerModelsACDC, "test", "data", "case5acdc_scopf.m")
elseif case_name == "case39"
    file = pkgdir(PowerModelsACDC, "test", "data", "case39acdc_scopf.m")
elseif case_name == "case67"
    file = pkgdir(PowerModelsACDC, "test", "data", "case67acdc_scopf.m")
end

data = PowerModels.parse_file(file)

for (c, conv) in data["convdc"]
    conv["kmax"] = kmax
end

for (g, gen) in data["gen"]
    gen["gen_slack"] = 0.0
end

# Process demand reduction and curtailment data
for (l, load) in data["load"]
    data["load"][l]["pred_rel_max"] = 0.3
    data["load"][l]["cost_red"] = 100.0 * data["baseMVA"]
    data["load"][l]["cost_curt"] = 10000.0 * data["baseMVA"]
    data["load"][l]["flex"] = 1
end


# OPF settings
s = Dict("conv_losses_mp" => true, "optimize_converter_droop" => true, "objective_components" => ["gen"], "dc_converter_passivity" => dc_converter_passivity)
# Reference droop
kref = 1 / 100

# Random generation and demand time series, later replace with something more representative
g_series = [1.0 0.7 0.75 0.78 0.85 0.88 0.9 1.0 1.12 1.25 1.2 1.08 0.99 0.92 0.8 0.73 0.8 0.9 1.03 1.2 1.11 0.99 0.8 0.69]
l_series = [1.0 0.7 0.75 0.78 0.85 0.88 0.9 1.0 1.12 1.25 1.2 1.08 0.99 0.92 0.8 0.73 0.8 0.9 1.03 1.2 1.11 0.99 0.8 0.69]
# Select the nunmber of hours for which you want to run the optimisation
number_of_hours = 2
# get the number of contingencies from the data dictionary
number_of_contingencies = length(data["contingencies"])

# violations = HVDCdroop.find_binding_contingencies(data, ipopt, l_series, g_series, s, kref)
data_all = create_scopf_data(data, number_of_hours, g_series, l_series)

# Solve OPF
result = solve_scopf(data_all, PowerModels.ACPPowerModel, ipopt; multinetwork=true, setting=s)




############ PRINT droop coefficient for converters ###################
k_droop = zeros(length(result["solution"]["nw"]["1"]["convdc"]))
for (c, conv) in result["solution"]["nw"]["1"]["convdc"]
    k_droop[parse(Int, c)] = conv["k_droop"]
end

Plots.scatter(k_droop)
Plots.xlabel!("Converter ID")
Plots.ylabel!("k in MW / kV")

########## PRINT Converter dc side & generator setpoints for all hours and contingencies

pconv = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["convdc"]))
pg = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["gen"]))

for (n, network) in result["solution"]["nw"]
    for (g, gen) in network["gen"]
        pg[parse(Int, n), parse(Int, g)] = gen["pg"] * data_all["nw"]["1"]["baseMVA"]
    end
    for (c, conv) in network["convdc"]
        pconv[parse(Int, n), parse(Int, c)] = conv["pdc"] * data_all["nw"]["1"]["baseMVA"]
    end
end

Plots.scatter(pg[:, 1])
for idx in 2:length(result["solution"]["nw"]["1"]["gen"])
    Plots.scatter!(pg[:, idx])
end
Plots.xlabel!("contingency ID")
Plots.ylabel!("Pg in MW")

Plots.scatter(pconv[:, 1])
for idx in 2:length(result["solution"]["nw"]["1"]["convdc"])
    Plots.scatter!(pconv[:, idx])
end
Plots.xlabel!("contingency ID")
Plots.ylabel!("Pdc in MW")


for (n, network) in result["solution"]["nw"]
    if parse(Int, n) < data_all["number_of_contingencies"]
        for (c, conv) in network["convdc"]
            bus_id = data_all["nw"]["1"]["convdc"][c]["busdc_i"]
            pd = result["solution"]["nw"][n]["convdc"][c]["pdc"] + (result["solution"]["nw"]["1"]["convdc"][c]["k_droop"] * (network["busdc"]["$bus_id"]["vm"] - result["solution"]["nw"][n]["busdc"]["$bus_id"]["vm"]))
            println("Contingency ID: ", n, " Conv ID: ", c, " Pdc calc: ", pd, " Pdc: ", network["convdc"][c]["pdc"])
        end
    end
end


#
branch_flows = zeros(number_of_hours * number_of_contingencies, length(result["solution"]["nw"]["1"]["branchdc"]))

for (n, network) in result["solution"]["nw"]
    for (bdc, branchdc) in network["branchdc"]
        branch_flows[parse(Int, n), parse(Int, bdc)] = max(abs(branchdc["pf"]), abs(branchdc["pt"]))*data_all["nw"]["1"]["baseMVA"]
    end
end

# 67 with droop

# 18×11 Matrix{Float64}: branch flows
#  470.829  365.506   416.807  147.381   171.7     395.777    255.895     91.381    276.909   360.723   230.594
#  299.324  274.393   356.005  127.408   299.85    298.537    267.328    130.698    324.786   359.299   230.594
#  381.855  364.677   463.915  162.77    132.639   530.758    216.527     54.6551   149.796   355.627   230.594
#  392.558  182.686   337.987  121.412    47.5973  323.723    243.046    136.666    257.303   353.259   230.594
#  480.957  418.611   340.3    122.13    146.891   358.082    226.907    131.942    209.138   350.125   230.594
#  410.813  270.173   215.311   79.8424  197.665   348.188    471.214    120.98     338.253   256.477   230.594
#  484.723  410.826   394.053   55.4003  152.859   378.071    210.678     55.4181   226.645   283.035   230.594
#  487.153  401.789   440.73   230.906   158.926   395.927    199.417     21.0287   244.17    230.598   230.594
#  329.514  302.366   339.504  121.023   143.777    84.2286    84.1931    68.4865   170.903   286.91    230.594
#  239.447  177.633   148.965   73.3145   89.441   156.561    158.822     29.1101   151.226   104.743   117.543
#  153.569  132.0     118.506   63.3017  153.696   107.836    164.594     48.8519   175.267   104.052   117.543
#  180.072  177.015   180.272   83.5498   63.4081  246.349    132.503      4.63109   66.4637  101.314   117.543
#  201.318   88.5347  110.537   60.646    28.9343  121.422    152.569     51.2336   141.682   101.122   117.543
#  243.468  198.574   118.893   63.3832   79.6762  141.755    147.406     45.0812   124.542   100.585   117.543
#  228.516  160.28    112.288   61.019    94.1578  147.855    197.947     34.5004   162.37     85.7621  117.543
#  245.442  197.111   139.265   33.8953   81.3595  149.011    139.406     33.9015   129.66     71.4362  117.543
#  241.861  182.987   152.505   85.6283   87.5596  156.599    150.497     18.7369   146.403    85.5897  117.543
#  171.126  147.071   111.511   60.5439   75.951     5.75374    5.75357   18.0769    99.9976   69.033   117.543

# julia> pconv
# 18×9 Matrix{Float64}:
#  -299.293        350.295        -306.908        -237.62         519.933        -238.762        -213.463        650.425        -230.594
#     4.63083e-19  324.428        -343.96         -276.24         446.475        -258.106        -231.987        564.919        -230.594
#  -249.309          4.10375e-19  -267.003        -195.1          601.199        -217.425        -192.998        745.535        -230.594
#  -344.974        324.846           3.27059e-19  -276.242        446.797        -258.078        -231.933        565.804        -230.594
#  -334.191        330.419        -335.215           3.18341e-19  462.133        -254.072        -228.081        583.942        -230.594
#  -213.347        399.429        -237.514        -162.859          2.60287e-19  -200.822        -176.667        817.641        -230.594
#  -331.998        331.641        -333.397        -266.264        465.045           1.69347e-19  -227.652        587.66         -230.594
#  -328.372        333.685        -330.425        -263.012        470.482        -251.935           2.46238e-19  594.205        -230.594
#  -185.84         415.502        -215.813        -140.032        709.586        -189.51         -165.959         -9.17737e-19  -230.594
#  -150.048        233.692        -149.604         -93.6183        94.7123       -102.425         -31.4571       315.122        -117.543
#    -2.51931e-19  220.709        -168.227        -113.027         57.8295       -112.154         -40.7713       272.221        -117.543
#  -116.685         -7.1944e-19   -122.95          -65.2484       148.866         -88.1808        -17.8          378.454        -117.543
#  -172.389        221.253          -9.93111e-20  -112.507         58.9703       -111.88          -40.4962       273.786        -117.543
#  -163.826        225.857        -160.781          -4.37626e-23   71.9431       -108.464         -37.2234       288.938        -117.543
#  -134.403        242.625        -136.966         -80.0163         1.11453e-19   -95.5194        -24.7623       345.485        -117.543
#  -164.117        225.68         -161.001        -105.922         71.1646          1.54978e-19   -37.547        288.195        -117.543
#  -154.341        231.244        -153.077         -97.3619        87.4358       -104.365           2.13131e-19  306.847        -117.543
#   -95.2035       265.174        -105.547         -46.4698       186.212         -78.6208         -8.5073         1.46926e-18  -117.543

#   67 with no droop
# pconv
# 18×9 Matrix{Float64}:
#  -325.687        442.336        -305.041        -247.993        382.114        -203.556        -155.143        636.85         -229.937
#    -1.09859e-18  392.012        -367.296        -302.989        337.473        -235.93         -184.723        586.548        -230.13
#  -247.724         -7.56898e-19  -245.926        -201.591        489.337        -174.584        -133.181        737.99         -229.927
#  -376.235        404.13           -2.82154e-18  -299.769        348.136        -249.644        -195.819        594.498        -229.858
#  -374.664        417.234        -360.184          -6.29804e-17  353.415        -235.603        -187.628        611.963        -229.871
#  -248.519        552.96         -244.078        -187.603         -7.0837e-19   -199.561        -178.009        729.548        -229.794
#  -346.929        423.318        -342.033        -275.515        370.743          -1.4827e-18   -220.822        615.199        -229.832
#  -344.059        431.406        -333.906        -274.647        380.03         -262.053          -1.09944e-18  626.945        -229.946
#  -185.14         416.44         -216.82         -140.392        710.491        -189.751        -166.469          6.0529e-17   -231.027
#  -133.2          229.292        -141.533        -111.502        170.336        -132.76          -88.4171       324.065        -117.748
#    -9.26834e-20  204.28         -157.098        -133.807        147.028        -147.529         -98.2359       301.854        -117.751
#   -94.6158         1.01707e-17  -107.821         -77.5134       197.823        -109.145         -60.4243       368.362        -117.769
#  -155.471        205.595          -8.12738e-19  -133.08         146.65         -150.677         -97.795        301.393        -117.713
#  -155.489        215.665        -165.807           1.00394e-18  155.47         -146.868         -99.0531       312.539        -117.732
#  -108.132        256.011        -117.397         -86.5216        -1.35474e-19  -114.001         -65.419        351.782        -117.769
#  -148.378        216.395        -174.028        -131.006        155.65            4.17113e-18  -113.972        311.808        -117.807
#  -143.836        224.382        -159.123        -128.805        162.135        -159.343           1.15813e-18  320.879        -117.759
#   -95.9117       265.154        -106.213         -46.8449       186.406         -77.1634         -7.98536       -8.06398e-18  -117.949

# julia> branch_flows
# 18×11 Matrix{Float64}:
#  496.057  364.118   372.285  140.236   170.544   354.022    284.073     63.3199  302.328   295.261   229.937
#  317.671  278.865   332.327  127.868   318.256   281.408    306.145    108.061   357.072   312.497   230.13
#  371.152  352.028   428.316  156.547   123.517   512.841    226.997     18.0366  142.614   289.585   229.927
#  424.489  181.276   315.853  123.258    48.2678  310.064    285.499    126.387   291.287   318.986   229.858
#  525.666  438.656   314.373  120.806   151.122   344.679    268.293    114.797   238.0     308.357   229.871
#  450.37   271.51    202.587   74.7349  202.074   276.375    454.726    124.826   380.866   252.713   229.794
#  511.536  406.783   364.195   47.7354  164.768   355.593    260.772     47.749   269.369   268.544   229.832
#  514.641  392.792   411.569  224.571   170.752   373.625    254.524     37.4821  292.442   224.275   229.946
#  329.734  302.884   339.94   121.079   144.698    84.1343    84.0989    68.6715  171.528   287.475   231.027
#  230.059  162.284   170.186   71.5178   96.9146  164.952    159.428     61.2419  164.663   159.904   117.748
#  153.232  121.401   150.724   66.6833  153.368   133.822    168.3       80.8458  185.206   164.893   117.751
#  163.718  156.391   187.668   78.7978   69.1272  239.999    128.751     30.3467   76.4507  139.19    117.769
#  194.651   78.4434  141.834   64.9166   39.1888  144.063    157.598     85.7599  155.37    162.687   117.713
#  242.936  195.98    144.187   64.0104   87.4862  161.284    151.511     82.858   134.415   163.042   117.732
#  210.914  132.22    101.15    49.9176  102.853   135.911    216.311     64.0831  181.53    115.32    117.769
#  243.505  196.579   167.465   17.8214   95.1785  168.737    143.349     17.8232  142.078   131.792   117.807
#  241.352  179.232   190.795  116.728    97.5711  176.154    145.024     42.6148  159.663   116.65    117.759
#  171.844  148.133   111.98    60.3885   75.9606    6.15601    6.15582   16.7749   99.6623   68.3557  117.949