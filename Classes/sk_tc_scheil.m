classdef sk_tc_scheil < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Step=1;
        Parameter='w';
        Results;
        PhaseInfo;
        GetContents=true;
        Tolerance=1e-12;
        StopTolerance=1e-2;
        FDE={};
        GlobalMinimization=0;
        BaseEQ;
        Silent=0;
        LiquidPhase='LIQUID'
        StartT=[];
    end
    
    properties (Access=private)
        WorkEQ;
        Components;
        NextT;
        NextMole;
        NumIter=0;
        Phases;
        PhaseParams;
        %LastLiqComp;
        %LiqElm;
        LiqState;
        ResVars;
        SysMole;
        SysPressure;
        MoleParam='N';
        DoFDE=0;
        Solids;
        SolidNames;
    end
    
    methods
        function obj = sk_tc_scheil(baseeq)
            obj.BaseEQ = baseeq;
        end
        
        function calculate(obj)
            obj.WorkEQ = obj.BaseEQ.Clone;
            obj.WorkEQ.Calculate;
            if ~isscalar(obj.StartT)
                obj.StartT = ceil(sk_func_tc_properties.get(obj.BaseEQ, 'tliq') + 3);
            end
            
            obj.DoFDE = ~isempty(obj.FDE);
            
            obj.Components = obj.WorkEQ.GetElements;
            obj.Phases = obj.WorkEQ.GetPhases;
            
            obj.NextT = obj.StartT;
            obj.SysMole = double(obj.WorkEQ.GetValue('N'));
            obj.NextMole = obj.SysMole;
            obj.SysPressure = double(obj.WorkEQ.GetValue('P'));
            obj.WorkEQ.SetCondition('t', obj.StartT);
            obj.WorkEQ.Calculate;
            
            obj.updateComposition;
            
            stablePhases=strjoin(obj.WorkEQ.GetStablePhases, ',');
            if ~strcmpi(stablePhases,obj.LiquidPhase)
                error('More phases than the liquid phase are stable (%s), aborting...', stablePhases);
            end
            
            %obj.WorkEQ.DeleteCondition('*');
            obj.WorkEQ.SetCondition('t', obj.StartT);
            obj.WorkEQ.SetCondition('n', obj.SysMole);
            obj.WorkEQ.SetCondition('p', obj.SysPressure);
            obj.setNewComposition;
            
            phnames = cellfun(@(c)(sprintf('np(%s)', c)), obj.Phases', 'UniformOutput', false);
            elmnames = {};
            if obj.GetContents
                for i=1:length(obj.Phases)
                    elmnames = [elmnames ; cellfun(@(c)(sprintf('%s(%s,%s)', obj.Parameter, obj.Phases{i}, c)), obj.Components, 'UniformOutput', 0)];
                end
            end
            
            if obj.DoFDE
                error("Not implemented");
            end
            
            obj.ResVars = elmnames';
            
            obj.Results = cell2table(cell(0, length(obj.ResVars) + length(phnames) + 2));
            obj.Results.Properties.VariableNames = matlab.lang.makeValidName([{'t','tc'}, phnames, obj.ResVars]);
            obj.Results.Properties.VariableDescriptions = [{'t','t_c'}, phnames, obj.ResVars];
            obj.PhaseParams=phnames;
            
            dorun = true;
            
            obj.WorkEQ.SetMin(obj.GlobalMinimization);
            liqchk = sprintf('np(%s)',obj.LiquidPhase);
            if obj.Silent==2
                fprintf('\tStarting Scheil Simulation...\n');
                fprintf('\t                ');
            end
            %obj.WorkEQ.TCSYS.FastMode=1;
            while dorun && obj.NextT > 300 
                obj.iterate(obj.NextT);
                obj.NextT = obj.NextT - obj.Step;
                
                
                liq = obj.WorkEQ.GetValue(liqchk)/obj.SysMole;
                if ~obj.Silent
                    fprintf(' %s=%f\n', liqchk, liq);
                end
                if obj.Silent==2
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
                    fprintf('% 5.0fK % 7.3f%%', obj.NextT, (1-liq)*100);
                end
                
                dorun = double(liq) > obj.StopTolerance;
            end
            %obj.WorkEQ.TCSYS.FastMode=0;
            fprintf('\n');
        end
        
        function drawScheil(obj)
            phI=obj.getPhaseInfo;
            phN=phI.Phase;
            phS=phI.PrecTemp;
            phS=[phS;min(obj.Results.t)];
            
            x = (obj.SysMole - obj.Results.np_LIQUID_)/obj.SysMole;
            y = obj.Results.t;
            
            Y=NaN(size(obj.Results,1),size(phS,1)-1);
            for i=1:size(phS,1)-1
                indxs = find(y<=phS(i) & y>phS(i+1));
                if i>1
                    indxs = [min(indxs)-1; indxs];
                end
                Y(indxs,i)=y(indxs);
            end
                
            plot(x, Y-273.15);
            title('Scheil Plot');
            ylabel('Temperature [°C]');
            xlabel('Mole Fraction of Solid');
            legend(phN,'Interpreter','none');
        end
                
        function ResTab = getSegregationFactors(obj)
            if ~obj.GetContents
               error ('need to be calculated with "GetContents=true"'); 
            end

            nel=length(obj.Components);
                        
            liqvars=cellfun(@(c)(sprintf('%s(%s,%s)', obj.Parameter, obj.LiquidPhase, c)), obj.Components, 'UniformOutput', false);
            vars = matlab.lang.makeValidName(liqvars);
            
            ResTab = obj.Results([1,end],vars);
            ResTab{3,:}=NaN;
            
            for n=1:nel
                ResTab{3,n}=max(table2array(ResTab(1:2,n)))/min(table2array(ResTab(1:2,n)));
            end
            
            %ResTab=array2table([mins';maxs';Res'],'VariableNames', obj.Components);
            ResTab.Properties.VariableNames=obj.Components;
            ResTab.Properties.RowNames={'Liq','Sol','Segr.Fact.'};
        end
        
        function [liqstate, solstate] = getStates(obj)
            liqstate = sk_tc_state(obj.WorkEQ.TCSYS);
            solstate = sk_tc_state(obj.WorkEQ.TCSYS);
            
            syscond = obj.WorkEQ.GetSystemConditions;
            
            liqstate.SetConditions(syscond);
            solstate.SetConditions(syscond);
            
            segt = obj.getSegregationFactors;
            seg = table2array(segt);
            
            nel=length(obj.Components);
            
            for i=1:nel
                q = sprintf('%s(%s)',obj.Parameter, obj.Components{i});
                liqstate.SetCondition(q, seg(1,i));
                solstate.SetCondition(q, seg(2,i));
            end
        end
        
        function Res = getSolidificationInterval(obj)
            r=struct;
            tmp = table2array( obj.Results(:,'t'));
            tmp=tmp(tmp~=0);
            r.TLiq = max(tmp);
            r.TSol = min(tmp);
            r.TLiq_C = r.TLiq-273.15;
            r.TSol_C = r.TSol-273.15;
            r.Interval=r.TLiq-r.TSol;
            Res = r;
        end
               
        function Res = getPhaseInfo(obj)
            temp=table2array(obj.Results(:,[1 2]));
            li=[];
            pi=struct;
            
            for i=1:length(obj.Phases)
                ph = obj.Phases{i};

                cnt=table2array(obj.Results(:,matlab.lang.makeValidName(obj.PhaseParams{i})));
                
                fi=find(cnt>0,1,'first');
                
                if strcmpi(ph, obj.LiquidPhase) || max(cnt)==0
                    li(end+1)=i;
                end
                
                pi(i).Phase=ph;
                pi(i).MaxContent=max(cnt);
                pi(i).PrecTemp=temp(fi,1);
                pi(i).PrecTempC=temp(fi,2);
            end
            
            pi(li)=[];
            obj.PhaseInfo=struct2table(pi);
            obj.PhaseInfo=sortrows(obj.PhaseInfo, {'PrecTemp'},'descend');
            Res=obj.PhaseInfo;
        end
        
        function r = uint8(~)
            r = 0;
        end
    end
    
    methods (Access=private)
        function iterate(obj, thisTemp)
            if ~obj.Silent
                fprintf('Calculating t=%g', thisTemp);
            end
            
            obj.LiqState = obj.WorkEQ.GetLocalState(obj.LiquidPhase, obj.MoleParam);
            
            obj.WorkEQ=obj.LiqState;
            
            obj.WorkEQ.SetCondition('t', thisTemp);
            obj.WorkEQ.SetCondition('n', obj.NextMole);
            
            oldmole = obj.NextMole;
            obj.NextMole = obj.WorkEQ.GetValue('np(%s)',obj.LiquidPhase);
                        
            if abs(obj.NextMole - obj.SysMole) <= obj.Tolerance
                return;
            end
            tmpres = cellfun(@(c)(obj.WorkEQ.GetValue(c)), obj.ResVars, 'UniformOutput', false);
            tmpphinfo = cellfun(@(c)(obj.WorkEQ.GetValue(c)), obj.PhaseParams, 'UniformOutput', false);
            
            if obj.DoFDE && abs(oldmole-obj.SysMole)>1e-16
                error("NotImplemented");
            end
                        
            obj.Results = sk_tool_tableAddRow(obj.Results, [thisTemp, thisTemp-273.15, tmpphinfo, tmpres]);
        end
        
        function updateComposition(obj)
           obj.LiqState = obj.WorkEQ.GetLocalState(obj.LiquidPhase, obj.MoleParam);
        end
        
        function setNewComposition(obj)
            obj.WorkEQ=obj.LiqState;
        end
    end
end

