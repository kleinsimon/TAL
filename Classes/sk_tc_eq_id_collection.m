classdef sk_tc_eq_id_collection < handle
    %sk_tc_eq_id_collection(TCSys)
        
    properties(SetAccess = private,GetAccess = public)
        EqIdObjects=containers.Map;
        IDCount=0;
        TCSys;
    end
    
    methods
        function obj = sk_tc_eq_id_collection(TCSys)
            obj.TCSys = TCSys;
            obj.Clear;
        end
        
        function varargout = FindPhaseStatus(obj, PhaseStati)
            tmpHash = sk_tc_eq_id.GetHash(PhaseStati);
            
            if obj.EqIdObjects.isKey(tmpHash)
                varargout{1}=obj.EqIdObjects(tmpHash);
            else
                varargout{1}=0;
            end
            
            if nargout==2
                varargout{2}=tmpHash;
            end 
        end
        
        function o = AddPhaseStatus(obj, PhaseStati, varargin)
            o = sk_tc_eq_id(obj.TCSys, PhaseStati, obj.IDCount, varargin{:});
            obj.IDCount = obj.IDCount+1;
            obj.EqIdObjects(o.Hash) = o;
            obj.TCSys.CreateEQ(o.EqID);
        end
        
        function Clear(obj)
            obj.EqIdObjects=containers.Map;
            obj.IDCount=0;
        end
        
        function r = GetOrAdd(obj, PhaseStati)
            [tmp, tmpHash] = obj.FindPhaseStatus(PhaseStati);
            
            if isa(tmp, 'sk_tc_eq_id')
                r=tmp;
            else
                r=obj.AddPhaseStatus(PhaseStati, tmpHash);
            end
        end
    end    
end

