## Contraints for superconducting branches
## Replace the Ohm's law to use power flows --> r = 0 then cooling power represents loses

# Ohm's law for DC branches
# Use sc = 1 if branch is superconducting and change from 
function constraint_ohms_dc_branch(pm::_PM.AbstractIVRModel, n::Int,  f_bus, t_bus, f_idx, t_idx, r, p, sc)
    i_dc_fr = _PM.var(pm, n,  :igrid_dc, f_idx)
    i_dc_to = _PM.var(pm, n,  :igrid_dc, t_idx)
    vmdc_fr = _PM.var(pm, n,  :vdcm, f_bus)
    vmdc_to = _PM.var(pm, n,  :vdcm, t_bus)
    p_fr  = _PM.var(pm, n,  :p_dcgrid, f_idx)
    p_to  = _PM.var(pm, n,  :p_dcgrid, t_idx)

    if r == 0
        JuMP.@constraint(pm.model, i_dc_fr + i_dc_to == 0)
    else
        JuMP.@constraint(pm.model, vmdc_to ==  vmdc_fr - 1/p * r * i_dc_fr)
        JuMP.@constraint(pm.model, vmdc_fr ==  vmdc_to - 1/p * r * i_dc_to)
    end

    JuMP.@NLconstraint(pm.model, p_fr ==  vmdc_fr * i_dc_fr)
    JuMP.@NLconstraint(pm.model, p_to ==  vmdc_to * i_dc_to)
end

function sc_test_function()
    print("Developing of PowerModelsACDC is being sinc")
end