classdef sk_tc_property_pren < sk_tc_property
% sk_tc_property_pren: Child of sk_funcs. Evaluates the PREN number of the main-phase or a given phase. 
%

    properties

    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'PREN'};
        %Names of properties which have to be calculated first
        DependsOn={'mainphase'}; 
        SetBefore=1;
        Phase=[];
    end
    
    methods 
                
        function d = get.DependsOn(obj)
            if isempty(obj.Phase)
                d = {'mainphase'};
            else
                d = {};
            end
        end
        
        function obj = sk_tc_property_pren(varargin)
            tmp = sk_tc_prop_result.getByType(varargin, 4);
            
            if numel(tmp)>0
                obj.Phase = tmp{1}.tostring;
            end
        end
        
        function res = calculate(obj, ~, eq, deps)
            
            if numel(deps)>=1
                ph = deps{1}.value;
            else
                ph = obj.Phase;
            end

            EM = eq.GetValue('w(%s,*)',ph);

            wpc=@(elm)(100*sk_tool_def(0,EM{strcmpi(EM(:,1),elm),2}));
            
            pren = wpc('CR') + 3.3 * wpc('MO') + 20 * wpc('N');

            res = sk_tc_prop_result(obj.zNames, 6, pren);
        end
    end
end