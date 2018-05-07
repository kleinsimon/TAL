classdef sk_scheil < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Step=1;
        Parameter='w';
        BaseElement='FE';
        Results;
        PhaseInfo;
        GetContents=true;
        Tolerance=1e-2;
        FastDiffusingElements={};
    end
    
    properties% (Access=private)
        Components;
        NextT;
        NextMole;
        Phases;
        PhaseParams;
        LastLiqComp;
        LiqElm;
        ResVars;
        SysMole;
        SysPressure;
        OldConds;
        MoleParam='N';
        StartT=1720;
    end
    
    methods
        function obj = sk_scheil()

        end
        
        function calculate(obj)
            %obj.StartT = 1700; %sk_func_calc_tliq.get() + 3;
            
            [~, cmp] = tc_list_component;
            cmp(strcmp('VA', cmp)) = [];
            [~, obj.Phases] = tc_list_phase;
            [~, obj.OldConds] = tc_list_conditions;
            obj.Components = cmp; %sk_tool_del_cell(cmp, {'VA'});
            
            obj.NextT = obj.StartT;
            obj.SysMole = double(sk_tc_get_condition('N'));
            obj.NextMole = obj.SysMole;
            obj.SysPressure = double(sk_tc_get_condition('P'));
            tc_set_condition('t', obj.StartT);
            
            tc_compute_equilibrium;
            obj.updateComposition;
            
            stablePhases=strjoin(sk_tc_get_stable_phases, ',');
            if ~strcmpi(stablePhases,'LIQUID')
                error('More phases than the liquid phase are stable (%s), aborting...', stablePhases);
            end
            
            tc_delete_condition('*');
            tc_set_condition('t', obj.StartT);
            tc_set_condition('n', obj.SysMole);
            tc_set_condition('p', obj.SysPressure);
            obj.setNewComposition;
            
            phnames = cellfun(@(c)(sprintf('np(%s)', c)), obj.Phases', 'UniformOutput', false);
            elmnames = {};
            if obj.GetContents
                for i=1:length(obj.Phases)
                        elmnames = [elmnames, cellfun(@(c)(sprintf('%s(%s,%s)', obj.Parameter, obj.Phases{i}, c)), obj.Components', 'UniformOutput', false)];
                end
            end
            
            obj.ResVars = elmnames;
            
            obj.Results = cell2table(cell(0, length(obj.ResVars) + length(phnames) + 2));
            obj.Results.Properties.VariableNames = matlab.lang.makeValidName([{'t','tc'}, phnames, obj.ResVars]);
            obj.Results.Properties.VariableDescriptions = [{'t','t_c'}, phnames, obj.ResVars];
            obj.PhaseParams=phnames;
            
            dorun = true;
            
            tc_set_minimization('off');
            
            while dorun && obj.NextT > 300 
                obj.iterate(obj.NextT);
                obj.NextT = obj.NextT - obj.Step;
                
                liqchk = 'np(LIQUID)';
                liq = tc_get_value(liqchk);
                fprintf(' %s=%f\n', liqchk, liq);
                
                dorun = double(liq) > obj.Tolerance;
            end
            tc_set_minimization('on');
            
            tc_delete_condition('*');
            sk_tc_set_conditions(obj.OldConds);
        end
        
        function drawScheil(obj)
            phI=obj.getPhaseInfo;
            phN=phI.Phase;
            phS=phI.PrecTemp;
            phS=[phS;min(obj.Results.t)];
            
            x = 1 - obj.Results.np_LIQUID_;
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
            len=length(obj.ResVars);
            nel=length(obj.Components);
            
            Res = NaN(nel,1);
            mins = NaN(nel,1);
            maxs = NaN(nel,1);
            
            vars = matlab.lang.makeValidName(obj.ResVars);
            
            for i=1:len
                v = vars{i};
                if isempty(strfind(v, 'LIQUID'))
                    continue;
                end
                
                elm = [];
                for j=1:nel
                    srch=sprintf('_%s_', obj.Components{j});
                    if ~isempty(strfind(v, srch))
                        elm = obj.Components{j};
                        break;
                    end
                end
                
                ind=sk_tool_find_cell_index(obj.Components, elm);

                if ind==-1
                    error('Element not found');
                end
                tmp = table2array(obj.Results(:,v));
                minval = min(tmp);
                maxval = max(tmp);
                
                mins(ind)=min(mins(ind), minval);
                maxs(ind)=max(maxs(ind), maxval);
            end
            
            for n=1:nel
                Res(n)=maxs(n)/mins(n);
            end
            
            ResTab=array2table([mins';maxs';Res'],'VariableNames', obj.Components);
            ResTab.Properties.RowNames={'Min','Max','Segr.Fact.'};
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
                
                if strcmpi(ph, 'LIQUID') || max(cnt)==0
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
    end
    
    methods (Access=private)
        function iterate(obj, thisTemp)
            fprintf('Calculating t=%f', thisTemp);
            obj.updateComposition;
            tc_set_condition('t', thisTemp); %%Set Temperature
            
            obj.setNewComposition;
            
            tc_set_condition('n', obj.NextMole);
            tc_check_error;
            tc_compute_equilibrium;
            
            obj.NextMole = tc_get_value('np(LIQUID)');
            
            if abs(obj.NextMole - obj.SysMole) <= obj.Tolerance
                return;
            end
            tmpres = cellfun(@(c)(tc_get_value(c)), obj.ResVars, 'UniformOutput', false);
            tmpphinfo = cellfun(@(c)(tc_get_value(c)), obj.PhaseParams, 'UniformOutput', false);
                        
            obj.Results = sk_tool_tableAddRow(obj.Results, [thisTemp, thisTemp-273.15, tmpphinfo, tmpres]);
        end
        
        function updateComposition(obj)
            [obj.LiqElm, obj.LastLiqComp] = sk_tc_get_phase_contents('LIQUID', obj.MoleParam);
        end
        
        function setNewComposition(obj)
            sk_tc_set_conditions_for_component(obj.LiqElm, obj.LastLiqComp, obj.MoleParam);
            tc_delete_condition(sprintf('%s(%s)', obj.MoleParam, obj.BaseElement)); 
        end
    end
end

