classdef sk_tc_property_dg < sk_tc_property
% sk_func_calc_deltaG: Child of sk_funcs. Evaluates the Difference
% of Gibbs enthalpies between two phases in the local state of the main
% phase.
%
%   phase1:     TC-Name of the first phase (eg. fcc)
%   phase2:     TC-Name of the second phase (eg. bcc)
%   Result:     Delta G
    properties
        Phase1='fcc';
        Phase2='bcc';
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'C+N'};
        %Names of properties which have to be calculated first
        DependsOn={'mainphase'}; 
        SetBefore=1;
    end
    
    methods 
        function obj = sk_tc_property_dg(varargin)
            tmp = sk_tc_prop_result.getByType(varargin, 4);
            
            ph = cell(1,0);
            for i=1:length(tmp)
                ph = [ph tmp{i}.tostring];
            end
            
            t = varargin{1};
            for i=1:length(t)
                if ischar(t{i})
                    ph = [ph t{i}];
                end
            end
            
            if numel(ph) ~= 2
                error('exactly 2 phases must be submitted, either as a string or as a sk_tc_prop_result');
            end
            
            obj.Phase1 = ph{1};
            obj.Phase2 = ph{2};
            
            %[obj.Phase1, obj.Phase2] = sk_tool_parse_varargin(varargin, obj.Phase1, obj.Phase2);
        end
        
        function r = get.zNames(obj)
            r={sprintf('$\\Delta$G %s-%s', obj.Phase1, obj.Phase2)};
        end
        
        function res = calculate(obj, ~,  eq, deps)
            mainphase = deps{1}.value;
            
            eq = eq.GetLocalState(mainphase);
            
            eq.SetMin(0);
            eq.SetPhaseStatus('*','SUSPENDED',0);
            eq.SetPhaseStatus(obj.Phase1,'ENTERED',0);

            gePh1 = eq.GetValue('gm(%s)',obj.Phase1);

            eq.SetPhaseStatus('*','SUSPENDED',0);
            eq.SetPhaseStatus(obj.Phase2,'ENTERED',0);

            gePh2 = eq.GetValue('gm(%s)',obj.Phase2);
            
            res = sk_tc_prop_result(obj.zNames, 6, gePh1-gePh2);
        end
    end
end


