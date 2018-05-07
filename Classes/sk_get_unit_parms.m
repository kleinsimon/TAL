function [param, mult] = sk_get_unit_parms ( unit )
    switch lower(unit)
        case 'wpc'
            param='w';
            mult = 1e-2;
        case 'apc'
            param='x';
            mult = 1e-2;
        case 'w'
            param='w';
            mult = 1;
        case 'x'
            param='x';
            mult = 1;
        otherwise
            error('Unit %s not known', unit);
    end
end