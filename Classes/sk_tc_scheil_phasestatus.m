classdef sk_tc_scheil_phasestatus < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess=public, SetAccess=private)
        PhaseName;
        Components;
        Contents;
    end
    
    methods
        function obj = sk_tc_scheil_phasestatus(PhaseName, Components)
            obj.PhaseName=PhaseName;
            obj.Components=Components;
            obj.Contents=nan(0, numel(Components)+1);
        end
        
        function AddValues(obj, Contents, T)
            obj.Contents(end+1,1) = T;
            obj.Contents(end+1,2:end) = Contents;
        end
        
        function c = GetPhantomContent(obj)
            c = sum(obj.Contents(:,2:end), 1);
        end
    end
end

