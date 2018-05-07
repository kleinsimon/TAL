classdef sk_tc_property_scheil_range < sk_tc_property

    properties (Access=private)
        ScheilObj;
    end
    
    properties (GetAccess=public,SetAccess=private)
        zNames={'ScheilRange'};
        %Names of properties which have to be calculated first
        DependsOn={}; 
        SetBefore=1;
    end
    
    methods 
        function obj=sk_tc_property_scheil_range(varargin)
            obj.ScheilObj = sk_tc_prop_result.getByType(varargin, 10);
            
            if isempty(obj.ScheilObj)
                error('Scheil object needed');
            end
            
            if iscell(obj.ScheilObj)
                obj.ScheilObj=obj.ScheilObj{1};
            end
        end
        function res = calculate(obj, ~, ~, ~)
            
            scheil = obj.ScheilObj.value{1};
            restab=scheil.getSegregationFactors;
            
            prop = scheil.Parameter;
            
            rescel=table2cell(restab(1:2, :));
            h = cellfun(@(c)(sprintf('%s(%s)', prop, c)), restab.Properties.VariableNames, 'UniformOutput', 0);
            c1=[h' rescel(1,:)'];
            c2=[h' rescel(2,:)'];
            
            res = sk_tc_prop_result(obj.zNames, 3, {c1;c2});
        end
    end
end