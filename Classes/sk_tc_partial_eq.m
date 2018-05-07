classdef sk_tc_partial_eq < handle
    % Represents a Set of partial Equilibria. These are isolated, single
    % phase Equilibria, which may be linked by temperature, FDE activity
    % etc.
    %
    % sk_tc_partial_eq(PhaseNames, PhaseEQs)
    % obj.GetGlobalEQ()     Reunites the partial equilibria
    % 
    
    properties
        EqSet;
        LastN;
    end
    
    properties(Access=private)
        WorkEQs;
        MUs;
        FDE;
    end
        
    methods
        function obj = sk_tc_partial_eq(PhaseEQs)
            if ~isa(PhaseEQs, 'sk_tc_eq_set')
                error('An object of type sk_tc_eq_set must be submitted');
            end
            if PhaseEQs.Num < 2 
                error('At least 2 partial equilibria are required');
            end
            obj.EqSet = PhaseEQs;
        end
        
        function r = calculate(obj, varargin)
            %Calculate partial Equilibrium
            
            if numel(varargin)==0
                obj.FDE={'C'};
            else
                obj.FDE=varargin{1};
            end
            
            nph = obj.EqSet.Num;
            nfde=numel(obj.FDE);
            obj.WorkEQs=cell(1,nph);
            tcsys = obj.EqSet.TCSYS;
            obj.MUs = zeros(size(obj.FDE));
            
            for ix=1:nph
                teq = sk_tc_equilibrium(tcsys);
                peq = obj.EqSet.EQs{ix};
                
                teq.SetCondition('t', peq.GetValue('t'));
                teq.SetCondition('p', peq.GetValue('p'));
                teq.SetConditions(peq.GetValue('n(*)'), true);
                for iy=1:nfde
                    teq.DeleteCondition('n(%s)', obj.FDE{iy});
                    mu = peq.GetValue('mu(%s)', obj.FDE{iy});
                    obj.MUs(iy)=mu;
                    teq.SetCondition('mu(%s)', obj.FDE{iy}, mu);
                end
                
                obj.WorkEQs{ix}=teq;
            end
            %minimization parameters
            options = optimset('Display','none','MaxIter',100,'TolFun',1e-3,'TolX',1e-3);
            
            %Search minimum difference
            lsqnonlin(@obj.getMuDiff, obj.MUs, [], -1e-5, options);
            
            r=sk_tc_eq_set(obj.WorkEQs, obj.EqSet.IDs);
        end
        
        function diff = getMuDiff(obj, mu)
            nph = obj.EqSet.Num;
            nfde=numel(obj.FDE);
            r = zeros(nph, nfde);
            
            for iph=1:nph
                peq = obj.WorkEQs{iph};
                for ifde=1:nfde
                    peq.SetCondition('mu(%s)', obj.FDE{ifde}, mu(ifde));
                    r(iph,ifde) = peq.GetValue('n(%s)', obj.FDE{ifde});
                end
            end
            obj.LastN = r;
            %diff = max(pdist(r));
            diff = max(r)-min(r);
        end
        
        function Add(obj, PhaseName, EQ)
            obj.PhaseNames = [obj.PhaseNames PhaseName];
            obj.PartEQs = [obj.PartEQs EQ];
        end
        
        function eq = GetByPhase(obj, PhaseName)
            eq = obj.PartEQs{strcmp(obj.PhaseNames, PhaseName)};
        end
        
        function Display(obj)
            for i=1:numel(obj.PhaseNames)
                disp(obj.PhaseNames{i});
                obj.PartEQs{i}.DisplayEquilibrium('np', 'n');
            end
        end
    end    
end

