classdef sk_tc_property_elf < sk_tc_property
% sk_func_calc_elf:    Child of sk_funcs. Calculates the electrical
% conductivity. ?specimen(n?m)=?iron + 340C +146N +135Si + 54Cr + 50Mn +
% 15Ni + 34Mo + 40Cu (DOI 10.1179/174328407X157218)
%   Result:     Electric Conductivity in n?-1m-1
    properties (GetAccess=public,SetAccess=private)
        zNames={'ELF'};
        %Names of properties which have to be calculated first
        DependsOn; 
        Phase;
    end
    
    properties (Access=private)
        actComponents;
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_elf(varargin)
            obj.Phase = sk_tool_parse_varargin(varargin, obj.Phase);
        end
        
        function d = get.DependsOn(obj)
            if isempty(obj.Phase)
                d = {'mainphase'};
            else
                d = {};
            end
        end
        
        function res = calculate(obj, ~, eq, deps)
            if isempty(obj.Phase)
                mp = deps{1}.value;
            else
                mp = obj.Phase;
            end
            
            obj.actComponents = eq.GetElements;
            
            EM = eq.GetValue('w(%s,*)',mp);
            wpc=@(elm)(100*sk_tool_def(0,EM{strcmpi(EM(:,1),elm),2}));
            
            riron=100; %100 n?m
            
            r = riron + 340 * wpc('C') +146 * wpc('N') ...
                + 135 * wpc('Si') + 54 * wpc('Cr') ...
                + 50 * wpc('Mn') + 15 * wpc('Ni') ...
                + 34 * wpc('Mo') + 40 * wpc('Cu');
            
            res = sk_tc_prop_result(obj.zNames, 6, 1/r, '1/nOhm*m');
        end
    end
end


