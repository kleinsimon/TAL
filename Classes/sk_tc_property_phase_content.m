classdef sk_tc_property_phase_content < sk_tc_property
%sk_tc_property_phase_content: Child of sk_tc_property. Class for evaluating the
%content of a given phase. If no phase is given, all phases are measured.
%By default, the content is measured using vpv.

    properties
        PhaseComparer='vpv'; %The variable to use for measuring. Defaults to "vpv"
        PhaseName='*';       %The name of the phase to measure. Can be set using the pipe.
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'Phase_Content'};   %The Name of this property.
        %Names of properties which have to be calculated first
        DependsOn={};   %Dependencies: None. 
        SetBefore=1;    %Set Conditions in the pipe before evaluating. =ALL
    end
    
    methods 
        function obj = sk_tc_property_phase_content(pipe)
            %Phase objects will be taken from the pipe, if available. The
            %phase comparer may be submitted as a string. If two strings
            %are received, the first will be taken as a phase and the
            %second as the comparer.
            
            ph = sk_tc_prop_result.getByType(pipe, 4);
            ph2 = sk_tc_prop_result.getByType(pipe, 5, {@ischar});
            
            if ~isempty(ph)
                obj.PhaseName = ph{1}.value;
                if ~isempty(ph2)
                    obj.PhaseComparer = ph2{1}.value;
                end
            else
                if length(ph2)==1
                    obj.PhaseName = ph2{1}.value;
                elseif length(ph2)>=2
                    obj.PhaseName = ph2{1}.value;
                    obj.PhaseComparer = ph2{2}.value;
                end
            end
            
        end
        
        function n = get.zNames(obj)
            n = sprintf('%s(%s)', obj.PhaseComparer, obj.PhaseName);
        end
        
        function res = calculate(obj, ~, eq, ~)
            n = obj.PhaseName;
            cnt = eq.GetValue('%s(%s)', obj.PhaseComparer, n);
            
            if strcmp(n, '*') || iscell(n)
                res = sk_tc_prop_result('Phase_Contents', 0, cnt(:,2));
            else
                res = sk_tc_prop_result(obj.zNames, 6, cnt);
            end
        end
    end
end