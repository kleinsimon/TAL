classdef sk_tc_eq_id < handle
    %sk_tc_eq_id(PhaseStati, ID)
    %Represents a Set of Phase Stati, to allow the assignment to one
    %Equilibrium via ID in TC
        
    properties(SetAccess = private,GetAccess = public)
        PhaseStati; %Phase Stati represented by this object
        LastCond=0; %Hash of the Conditions for the last calculation of eq
        EqID=0; %The TC-ID of the Set
        Hash=0; %The Hash of the Phase Stati
        TCSYS;
    end
    
    methods
        
        function obj=sk_tc_eq_id(TCSYS, PhaseStati, ID, varargin)
        %sk_tc_eq_id(TCSYS, PhaseStati, ID, [Hash])
        %Constructor. Takes a PhaseStati, an ID and a optional Hash, if
        %already calculated.
        
            obj.TCSYS = TCSYS;
            obj.PhaseStati = PhaseStati;
            obj.EqID=ID;
            obj.LastCond = 0;
            if numel(varargin)==1
                obj.Hash = varargin{1};
            else
                obj.Hash=obj.GetHash(PhaseStati);
            end
        end
        
        function r = IsValidFor(obj, PhaseStati)
        %r = IsValidFor(PhaseStati)
        %Checks if the current Obj represents a phase status
            
            tmp = sk_tc_eq_id.GetPhaseHash(PhaseStati);
            r = strcmp(obj.Hash, tmp);
        end
        
        function r = NeedsRecalc(obj, Conditions)
            tmpHash = obj.GetHash(Conditions);
            r = ~strcmp(tmpHash, obj.LastCond);
        end
        
        function SetLastConds(obj, Conditions)
            obj.LastCond = obj.GetHash(Conditions);
        end
    end    
    methods(Static)
        function h = GetHash(Data)
            h = DataHash(Data);
        end
    end
end

