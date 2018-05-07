classdef sk_tc_scheil2 < handle
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
        Activities; %Cell mole, FDE mole, FDE mu
        BaseElm;
        WorkEQ;
    end
    
    properties (Access=private)
        Components;
        NextT;
        NumIter=0;
        Phases;
        PhaseParams;
        %LastLiqComp;
        %LiqElm;
        LiqState;
        LiqSize;
        ResVars;
        SysMole;
        SysPressure;
        MoleParam='N';
        ProtoEQ;
        DoFDE=0;
        Solids;
        SolidNames;
    end
    
    methods
        function obj = sk_tc_scheil2(baseeq)
            obj.BaseEQ = baseeq;
        end
        
        function calculate(obj)
            obj.WorkEQ = obj.BaseEQ.Clone;
            weq = obj.WorkEQ;
            
            if ~isscalar(obj.StartT)
                obj.StartT = ceil(obj.BaseEQ.GetProperty('tliq') + 3);
            end
            
            if ~ischar(obj.BaseElm)
                obj.BaseElm = weq.GetBaseElement;
            end
            
            obj.DoFDE = ~isempty(obj.FDE);
            
            obj.Components = weq.GetElements;
            obj.Phases = weq.GetPhases;
            
            obj.NextT = obj.StartT;
            obj.SysMole = double(weq.GetValue(obj.MoleParam));
            obj.SysPressure = double(weq.GetValue('P'));
            weq.SetCondition('t', obj.StartT);
            weq.Calculate;
            
            % Transform Condition set to mole fraction
            %weq.ConvertConditions('x');
            weq.ConvertConditions('n');
            weq.GetValueSetCondition('n(%s)', obj.BaseElm);
            weq.DeleteCondition('n');
            
            obj.ProtoEQ = weq.Clone;
            
            obj.updateComposition( obj.NextT);
            
            stablePhases=strjoin(weq.GetStablePhases, ',');
            if ~strcmpi(stablePhases,obj.LiquidPhase)
                error('More phases than the liquid phase are stable (%s), aborting...', stablePhases);
            end
            
           
            phnames = cellfun(@(c)(sprintf('np(%s)', c)), obj.Phases', 'UniformOutput', false);
            elmnames = {};
            if obj.GetContents
                for i=1:length(obj.Phases)
                    elmnames = [elmnames ; cellfun(@(c)(sprintf('%s(%s,%s)', obj.Parameter, obj.Phases{i}, c)), obj.Components, 'UniformOutput', 0)];
                end
            end
            
            if obj.DoFDE
                obj.Activities=zeros(0,3);
            end
            
            obj.ResVars = elmnames';
            
            obj.Results = cell2table(cell(0, length(obj.ResVars) + length(phnames) + 2));
            obj.Results.Properties.VariableNames = matlab.lang.makeValidName([{'t','tc'}, phnames, obj.ResVars]);
            obj.Results.Properties.VariableDescriptions = [{'t','t_c'}, phnames, obj.ResVars];
            obj.PhaseParams=phnames;
            
            dorun = true;
            
            weq.SetMin(obj.GlobalMinimization);
            liqchk = sprintf('np(%s)',obj.LiquidPhase);
            if obj.Silent==2
                fprintf('\tStarting Scheil Simulation...\n');
                fprintf('\t                ');
            end
            
            tmp = weq.GetValue('x(*)');
            fprintf('Temp   :  ');
            sk_tool_xprintf('%s', tmp(:,1), 12);
            fprintf('N\n');
            
            %weq.TCSYS.FastMode=1;
            while dorun && obj.NextT > 300 
                dorun = obj.iterate(obj.NextT);
                %obj.setNewComposition(obj.NextT);
                
                obj.NextT = obj.NextT - obj.Step;
                
                
                liq = weq.GetValue(liqchk)/obj.SysMole;
                if ~obj.Silent
                    %fprintf(' %s=%f\n', liqchk, liq);
                end
                if obj.Silent==2
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
                    fprintf('% 5.0fK % 7.3f%%', obj.NextT, (1-liq)*100);
                end
            end
            %weq.TCSYS.FastMode=0;
            fprintf('\n');
        end
        
        function drawScheil(obj)
            phI=obj.getPhaseInfo;
            phN=phI.Phase;
            phS=phI.PrecTemp;
            phS=[phS;min(obj.Results.t)];
            phS=phS + obj.Step;
            
            x = (obj.SysMole - obj.Results.np_LIQUID_)/obj.SysMole;
            %x = (obj.SysMole-obj.Results.n) / obj.SysMole;
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
        function dorun = iterate(obj, thisTemp)

            weq = obj.WorkEQ;
            if ~obj.Silent
                %fprintf('Calculating t=%g', thisTemp);
            end
            
            %Get Liquid State at current temperature
            obj.updateComposition(thisTemp);
            
            %Set Global state to old liquid state
            obj.setNewComposition(thisTemp);
            %Calculate Backdiffusion if necessary
            if obj.DoFDE
                obj.calcBackDiffusion;
                obj.setNewComposition(thisTemp);
            end
                     
            tmp = weq.GetValue('x(*)');
            fprintf('%g:  ', weq.GetValue('t')-273.15);
            sk_tool_xprintf('%g', tmp(:,2), 12);           
            CurMole = weq.GetValue(obj.MoleParam);
           
            %Get and store Phase information
            tmpres = cellfun(@(c)(weq.GetValue(c)), obj.ResVars, 'UniformOutput', false);
            tmpphinfo = cellfun(@(c)(weq.GetValue(c)), obj.PhaseParams, 'UniformOutput', false);
            
            if obj.DoFDE
                obj.Activities(end+1,:) = [weq.GetValue(obj.MoleParam) weq.GetValue('x(%s)', obj.FDE{1}) weq.GetValue('ac(%s)', obj.FDE{1})];
            end
            
            fprintf('=%g', CurMole / obj.SysMole);
            %fprintf(' (%g)', diff);
            fprintf('\n');
            
            obj.Results = sk_tool_tableAddRow(obj.Results, [thisTemp, thisTemp-273.15, tmpphinfo, tmpres]);
                        
            dorun = CurMole / obj.SysMole > obj.StopTolerance;
        end
        
        function calcBackDiffusion(obj)
            diff=0;
            if numel(obj.Activities) < 1 || ~obj.DoFDE
                return;
            end
            
            weq = obj.WorkEQ;
            
            %OldMole = weq.GetValue('n', obj.FDE{1});
            
            weq.SetPhaseStatus('*', 'SUSPENDED', 0);
            weq.SetPhaseStatus('LIQUID', 'ENTERED', 0);
            
            nc = obj.Activities(1,2); %moles of C in the whole System, equals n(c) in the first (liquid) step
            b = obj.Activities(:,3) ./ obj.Activities(:,2);
            a = nc / sum(1./b);
            
            weq.DeleteCondition('n(%s)', obj.FDE{1});
            weq.SetCondition('ac(%s)', obj.FDE{1}, a);
            
            %CurMole = weq.GetValue('n', obj.FDE{1});
            
            %diff = OldMole - CurMole;
            obj.LiqState = weq.GetValue('n(*)');
        end
             
        % Store the local state of the liquid
        function updateComposition(obj, t)
            weq=obj.WorkEQ;
           
            weq.SetCondition('t', t);
            obj.LiqState = weq.GetValue('n(%s,*)', obj.LiquidPhase);
        end
        
        % Set Liquid state as global
        function setNewComposition(obj, t)
            obj.WorkEQ = obj.ProtoEQ.Clone;
            
            weq = obj.WorkEQ;
            weq.SetCondition('p', obj.SysPressure);
            weq.SetCondition('t', t);

            for i=1:size(obj.LiqState,1)
                weq.SetCondition('n(%s)', obj.LiqState{i,1}, obj.LiqState{i,2});
            end
        end
    end
end

