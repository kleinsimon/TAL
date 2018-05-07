classdef sk_tc_scheil3 < handle
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
        BaseEQ;
        Silent=0;
        LiquidPhase='LIQUID'
        StartT=[];
        Activities; %Cell mole, FDE mole, FDE mu
        PhaseMole;
        BaseElm;
        WorkEQ;
    end
    
    properties (Access=private)
        Components;
        CurT;
        LastT;
        NumIter=0;
        Phases;
        PhaseParams;
        Solidified=0;
        FDEcor=0;
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
        FDEAcs;
        Findex;
    end
    
    methods
        function obj = sk_tc_scheil3(baseeq)
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
            
            obj.FDEAcs = [];
            obj.FDEcor = containers.Map;
            obj.Components = weq.GetElements;
            obj.Phases = weq.GetPhases;
            
            obj.CurT = obj.StartT;
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
            
            obj.updateComposition;
            
            stablePhases=strjoin(weq.GetStablePhases, ',');
            if ~strcmpi(stablePhases,obj.LiquidPhase)
                error('More phases than the liquid phase are stable (%s), aborting...', stablePhases);
            end
            
            obj.Solidified = 0;
           
            phnames = cellfun(@(c)(sprintf('np(%s)', c)), obj.Phases', 'UniformOutput', false);
            elmnames = {};
            if obj.GetContents
                for i=1:length(obj.Phases)
                    elmnames = [elmnames ; cellfun(@(c)(sprintf('%s(%s,%s)', obj.Parameter, obj.Phases{i}, c)), obj.Components, 'UniformOutput', 0)];
                end
            end
            
            if obj.DoFDE
                obj.PhaseMole=containers.Map;
                obj.Findex = strcmpi(obj.Components, obj.FDE);
            end
            
            obj.ResVars = elmnames';
            
            obj.Results = cell2table(cell(0, length(obj.ResVars) + length(phnames) + 2));
            obj.Results.Properties.VariableNames = matlab.lang.makeValidName([{'t','tc'}, phnames, obj.ResVars]);
            obj.Results.Properties.VariableDescriptions = [{'t','t_c'}, phnames, obj.ResVars];
            obj.PhaseParams=phnames;
            
            dorun = true;
            
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
            while dorun && obj.CurT > 300 
                obj.LastT = obj.CurT;
                dorun = obj.iterate;
                %obj.setNewComposition(obj.NextT);
                
                liq = weq.GetValue(liqchk)/obj.SysMole;
                if ~obj.Silent
                    %fprintf(' %s=%f\n', liqchk, liq);
                end
                if obj.Silent==2
                    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
                    fprintf('% 5.0fK % 7.3f%%', obj.CurT, (1-liq)*100);
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
                if numel(indxs) == 0
                    continue;
                end
                if i>1
                    indxs = [min(indxs)-1; indxs];
                end
                indxs(indxs<1)=[];
                Y(indxs,i)=y(indxs);
            end
                
            plot(x, Y-273.15);
            title('Scheil Plot');
            ylabel('Temperature [°C]');
            xlabel('Mole Fraction of Solid');
            legend(phN,'Interpreter','none');
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
            obj.PhaseInfo=sortrows(obj.PhaseInfo, {'PrecTemp'}, 'descend');
            Res=obj.PhaseInfo;
        end
        
        function r = uint8(~)
            r = 0;
        end
    end
    
    methods (Access=private)
        function dorun = iterate(obj)
            weq = obj.WorkEQ;
            weq.SetCondition('t', obj.CurT);
            
            if ~obj.Silent
                %fprintf('Calculating t=%g', thisTemp);
            end
            
            CurMole = weq.GetValue('n');
            
            %Get Liquid State at current temperature
            obj.updateComposition;
            
            %Set Global state to old liquid state
            obj.setNewComposition;
            weq = obj.WorkEQ;
            
            %Calculate Backdiffusion if necessary
            if obj.DoFDE
                obj.calcBackDiffusion;
                obj.setNewComposition;
                weq = obj.WorkEQ;
            end
            
            %lower temperature
            obj.CurT = obj.CurT - obj.Step;
            weq.SetCondition('t', obj.CurT);
            
            if obj.DoFDE
                for i=1:numel(obj.Phases)
                    %initialize empty mole vector
                    if ~obj.PhaseMole.isKey(obj.Phases{i})
                        obj.PhaseMole(obj.Phases{i}) = zeros(size(obj.Components));
                    end
                    
                    %if tmpphinfo{i}>0 %Phase stable
                        tmpPhMole = cellfun(@(c)(weq.GetValue('n(%s,%s)', obj.Phases{i}, c)), [obj.Components ; obj.BaseElm]);
                        obj.PhaseMole(obj.Phases{i}) = obj.PhaseMole(obj.Phases{i}) + tmpPhMole';
                    %end
                end
            end
                     
            tmp = weq.GetValue('x(*)');
            fprintf('%g:  ', weq.GetValue('t')-273.15);
            sk_tool_xprintf('%g', tmp(:,2), 12);           
            %CurMole = weq.GetValue('np(%s)', obj.LiquidPhase);
           
            %Get and store Phase information
            tmpres = cellfun(@(c)(weq.GetValue(c)), obj.ResVars, 'UniformOutput', false);
            tmpphinfo = cellfun(@(c)(weq.GetValue(c)), obj.PhaseParams, 'UniformOutput', false);
           
            
            fprintf('=%g', CurMole / obj.SysMole);

            fprintf('\n');
            
            obj.Results = sk_tool_tableAddRow(obj.Results, [obj.CurT, obj.CurT-273.15, tmpphinfo, tmpres]);
            
            if ~obj.Solidified
                obj.Solidified = abs(CurMole - obj.SysMole) > obj.Tolerance;
            end
            
            dorun = CurMole / obj.SysMole > obj.StopTolerance;
        end
        
        function calcBackDiffusion(obj)
            weq = obj.WorkEQ;
            
            % Check if other Phases are stable, instead just proceed
            if ~obj.Solidified
                return;
            end
            
            phEqs = containers.Map;
            
            pmk = obj.PhaseMole.keys;
            pmv = obj.PhaseMole.values;

            %For every already existing phase, get its mean content by
            %summing up all cells
            for i=1:obj.PhaseMole.length
                pname = pmk{i};
                pmole = pmv{i};
                
                %Sum up mole contents of all cells 
                psum = sum(pmole);
                if sum(psum) == 0
                    continue;
                end
                
                %Correct the solid amount of FDE in the partial EQs
                if obj.FDEcor.isKey(pname)
                    psum(obj.Findex) = obj.FDEcor(pname);
                end
                
                %Create empty eq
                teq = sk_tc_equilibrium(weq.TCSYS);
                
                %Set n of all elements, 
                teq.SetConditionsForComponents([obj.Components ; obj.BaseElm], psum', 'n');
                
                %Set Phase Status
                teq.SetPhaseStatus('*', 'SUSPENDED', 0);
                teq.SetPhaseStatus(pname, 'ENTERED', 0);
                teq.SetCondition('t', obj.CurT);
                teq.SetCondition('p', obj.SysPressure); 
                
                phEqs(pname)=teq;
            end
            
            %Only Liquid stable... skip
            if phEqs.length<=1
                return;
            end
            
            %Set liquid state in the partial eq to the one just calculated
            leq = phEqs(obj.LiquidPhase);
            leq.SetConditions(obj.LiqState, true);
            
            eqset = sk_tc_eq_set(phEqs.values, phEqs.keys);
            peq = sk_tc_partial_eq(eqset);
            
            %para.StartAcs = obj.FDEAcs;
            resSet = peq.calculate(obj.FDE);
            
            %nFDE = cellfun(@(c)(c.GetValue(FQ)), peq.PartEQs);
            
            for i=1:numel(resSet.IDs)
                obj.FDEcor(resSet.IDs{i}) = peq.LastN(i,:);
            end
            
            %fprintf('%g\t', obj.FDEAcs(1));
            
            %store Para state of liquid EQ
            obj.LiqState = leq.GetValue('n(%s,*)', obj.LiquidPhase);

        end
             
        % Store the local state of the liquid
        function updateComposition(obj)
            obj.LiqState = obj.WorkEQ.GetValue('n(%s,*)', obj.LiquidPhase);
        end
        
        % Set Liquid state as global
        function setNewComposition(obj)
            obj.WorkEQ = obj.ProtoEQ.Clone;
            
            weq = obj.WorkEQ;
            weq.SetCondition('p', obj.SysPressure);
            weq.SetCondition('t', obj.CurT);
            
            obj.LiqState(:,1) = strrep(obj.LiqState(:,1), [obj.LiquidPhase ','], '');
            weq.SetConditions(obj.LiqState, true);
        end
    end
end

