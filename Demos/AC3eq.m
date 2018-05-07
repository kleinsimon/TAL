function ac3 = AC3eq( vars, values )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    sk_tc_set_conditions_for_component(vars, values);
    sk_tc_check_env;
    tc_compute_equilibrium;

    %ac3 = sk_tc_get_phase_transition('FCC',300,0);
    Tfcc = sk_tc_get_phase_transition('FCC_A1', 700, 0);
    ac3 = sk_tc_get_phase_transition('BCC_A2', Tfcc+20, 0) - 273.15;
end

