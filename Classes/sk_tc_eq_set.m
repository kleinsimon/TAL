classdef sk_tc_eq_set < handle
    %Represents a set of equilibria together with identifiers
    
    properties
        EQs;
        IDs;
        Num;
        TCSYS;
    end
    
    methods
        function obj = sk_tc_eq_set(varargin)
            %sk_tc_eq_set([EQs, IDs])
            
            switch numel(varargin)
                case 0
                case 2
                    obj.EQs=varargin{1};
                    obj.IDs=varargin{2};
                otherwise
                    error("only 0 or 2 arguments allowed");
            end
        end
        
        function n=get.Num(obj)
            n = numel(obj.EQs);
        end
        
        function n=get.TCSYS(obj)
            n = obj.EQs{1}.TCSYS;
        end
        
        function addEQ(obj, eq, id)
            obj.EQs{end+1}=eq;
            obj.IDs{end+1}=id;
        end
        
        function eq = getEQ(obj, id)
            if ischar(id)
                eq = obj.EQs{strcmp(obj.IDs, id)};
            else
                eq = obj.EQs{id};
            end
        end
        
        function c = Clone(obj)
            eqs = cellfun(@(c)(c.Clone), obj.EQs, 'UniformOutput', 0);
            c = sk_tc_eq_set(eqs, obj.IDs);
        end
    end    
end

