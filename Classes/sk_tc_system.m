classdef sk_tc_system<handle
    
    properties
        Elements;
        Database;
        RejPhases;
        ResPhases;
        Functions=containers.Map;
        Variables=containers.Map;
        CurEQ=0;
        Phases;
        LastApplied;
        LastCalc;
        BaseElement='FE';
        Log=0;
        LogLength=100;
    end
    
    properties(Access = private)
        logPointer=1;
        maxEq=350;
        InitialEq;
        initElm;
        Elm;
        Ph;
        Min=1;
        NeedRecalc=1;
        DirtyStates=[];
        TCLog = cell(100,6);
        EqIds;
        CurEqId;
    end
    
    methods
        function set.LogLength(obj,val)
            obj.TCLog=cell(val,6);
        end
        
        function elm = get.Elements(obj) 
            elm=obj.Elm;
        end
        
        function set.Elements(obj, value) 
            obj.initElm = value;
        end
        
        function elm = get.Phases(obj) 
            elm = obj.GetPhases;
        end

        function obj=sk_tc_system(varargin)
        %sk_tc_system(database,elements,reject_phases,restore_phases)
            [database,elements,reject_phases,restore_phases] = sk_tool_parse_varargin(varargin,[],[],[],[]);
            obj.LogAndExecute(@tc_init_root);
            obj.initElm = elements;
            obj.Database = database;
            obj.ResPhases = restore_phases;
            obj.RejPhases = reject_phases;
                       
            obj.LastApplied=sk_tc_equilibrium(obj);
            obj.EqIds = sk_tc_eq_id_collection(obj);
            
            if obj.CheckDefined
                obj.Init;
            end
        end
        
        function ExportJSONFile(obj, path, varargin)
            fid = fopen(path, 'w');
            fprintf(fid, '%s', obj.ExportJSON(varargin{:}));
            fclose(fid);
        end
        
        function json = ExportJSON(obj, varargin)
            eq = sk_tool_parse_varargin(varargin, obj.InitialEq);
            
            tmp = struct;
            tmp.eq.Conditions = eq.Conditions;
            tmp.eq.PhaseStati = eq.PhaseStati;
            tmp.eq.Minimization = eq.Minimization;
            
            tmp.ResPhases = obj.ResPhases;
            tmp.RejPhases = obj.RejPhases;
            tmp.Elements = obj.Elements;
            tmp.Database = obj.Database;
            tmp.BaseElement = obj.BaseElement;
            tmp.Functions = obj.Functions;
            tmp.Variables = obj.Variables;
            
            json = jsonencode(tmp);
        end
        
        function isdef = CheckDefined(obj)
            isdef=~(isempty(obj.initElm) || isempty(obj.Database) || isempty(obj.RejPhases) || isempty(obj.ResPhases));
        end
        
        function isinit = CheckInit(obj)
            isinit=isa(obj.InitialEq, 'sk_tc_equilibrium');
        end
        
        function ph = GetPhases(obj)
            [~,ph]=tc_list_phase;
        end
        
        function SetFunction(obj, varargin)
            narginchk(2,3);
            
            if length(varargin)==1
                str=varargin{1};
                f=strsplit(str,'=');
                name=lower(f{1});
                func=f{2};
            else
                name=lower(varargin{1});
                func=varargin{2};
            end
            validateattributes(name,{'char'},{});
            validateattributes(func,{'char'},{});
            obj.Functions(name)=func;
            %tc_enter_function(name, func);
            obj.LogAndExecute(@tc_enter_function, name, func);
        end
        
        function ListFunctions(obj)
            c=[keys(obj.Functions); values(obj.Functions)];
            fprintf('%s=%s\n', c{:});
        end
        
        function SetVariable(obj, varargin)
            narginchk(2,3);
            
            if length(varargin)==1
                str=varargin{1};
                f=strsplit(str,'=');
                name=lower(f{1});
                func=f{2};
            else
                name=lower(varargin{1});
                func=varargin{2};
            end
            validateattributes(name,{'char'},{});
            validateattributes(func,{'double'},{});
            obj.Variables(name)=func;
            %tc_enter_variable(name, func);
            obj.LogAndExecute(@tc_enter_variable, name, func);
        end
        
        function ListVariables(obj)
            c=[keys(obj.Variables); values(obj.Variables)];
            fprintf('%s=%s\n', c{:});
        end
        
        function varargout = Init(obj) 
            if ~obj.CheckDefined
                error('System not completely defined');
            end
            if ischar(obj.initElm)
                elements=strsplit(obj.initElm);
            else
                elements=obj.initElm;
            end
            if ischar(obj.ResPhases)
                restore_phases = strsplit(obj.ResPhases);
            end
            if ischar(obj.RejPhases)
                reject_phases = strsplit(obj.RejPhases);
            end
            
            obj.LogAndExecute(@tc_open_database, obj.Database);
            for iel=1:numel(elements)
                obj.LogAndExecute(@tc_element_select, elements{iel});
            end
            for iph=1:numel(reject_phases)
                obj.LogAndExecute(@tc_phase_reject, reject_phases{iph});
            end
            for ips=1:numel(restore_phases)
                obj.LogAndExecute(@tc_phase_select, restore_phases{ips});
            end
            obj.LogAndExecute(@tc_get_data);
            
            obj.LogAndExecute(@tc_create_new_equilibrium, 0);
            obj.LogAndExecute(@tc_select_equilibrium, 0);
            
            %obj.DirtyStates(0)=1;
            %obj.NeedRecalc=1;
            obj.checkError;
           
            [~, obj.Elm] = tc_list_component;
            vaind = find(strcmp(obj.Elm, 'VA'));
            if isscalar(vaind)
                obj.Elm(vaind)=[];
            end
            [~, obj.Ph] = tc_list_phase;
            obj.InitialEq=sk_tc_equilibrium(obj);
            obj.CurEQ=obj.InitialEq;
            
            obj.CurEqId = obj.EqIds.GetOrAdd(obj.InitialEq.GetPhaseStatus);
            
            if nargout == 1
                varargout{1} = obj.InitialEq;
            end
        end
        
        function eqObj = GetInitialEquilibrium(obj)
            eqObj = obj.InitialEq;
        end
        
        function eqObj = GetNewEquilibrium(obj)
            eqObj = sk_tc_equilibrium(obj);
        end
                    
        function b = IsActiveEquilibrium(obj, eq)
            b = obj.CurEQ == eq;
        end
        function SetMinimization(obj, state)
            %SetMinimization(state) sets minimization to on(1) or off(0)
            if ischar(state)
                state = lower(state);
            end
            
            switch state
                case 'on'
                    s = 'on';
                    b = 1;
                case 'off'
                    s = 'off';
                    b = 0;
                case 1
                    s = 'on';
                    b = 1;
                case 0 
                    s = 'off';
                    b = 0;
                otherwise
                    error('unknown state %s', state);
            end
            obj.LogAndExecute(@tc_set_minimization,s);
            %tc_set_minimization(s);
            obj.Min=b;
        end
        function m = GetMinimization(obj)
            m=obj.Min;
        end
        function Recalc(obj, state, varargin)
            [force] = sk_tool_parse_varargin(varargin, obj.CurEQ.NeedRecalc);
            
            recalc = obj.ApplyState(state, force);
            
            d = tc_degrees_of_freedom;            
            if d ~= 0
                error('Degree of Freedom is %i, should be 0', d);
            end
            if force || recalc
                try
                    obj.LogAndExecute(@tc_compute_equilibrium);
                catch e
                    obj.LastCalc=state.Clone;
                    error(getReport(e));
                    return;
                end
                obj.LastCalc=state.Clone;
                obj.CurEqId.SetLastConds(state.GetConditions);
                obj.checkError(state);
            end
        end 
        function CreateEQ(obj, id)
            obj.LogAndExecute(@tc_create_new_equilibrium, id);
            %fprintf('created ID %d\n\n', id);
        end        
        function SelectEQ(obj, id)
            obj.LogAndExecute(@tc_select_equilibrium, id);
            %fprintf('switched to ID %d\n\n', id);
        end
        function Flush(obj)
            obj.LastApplied = sk_tc_equilibrium(obj);
            obj.EqIds.Clear;
            obj.LogAndExecute(@tc_poly3_command, 'REINITIATE_MODULE');
        end
        function recalc = ApplyState(obj, state, ~)
            recalc = 0;
            
            phn=state.GetPhaseStatus;
            nc =state.GetConditions;
            
            % Find ID object of the Phase Stati Set
            eqid = obj.EqIds.GetOrAdd(phn);
            
            % Switch to this state
            if obj.CurEqId ~= eqid
                obj.ApplyEqID(eqid);
                recalc=1;
            end
            
            if eqid.NeedsRecalc(nc)
                obj.ApplyConditions(nc);
                obj.SetMinimization(state.Minimization);
                recalc=1;
            else
                if obj.Min ~= state.Minimization
                    obj.SetMinimization(state.Minimization);
                    recalc=1;
                end
            end
            
            obj.checkError;
        end 
        
        function ApplyEqID(obj, eqid)
            obj.SelectEQ(eqid.EqID);
            obj.ApplyPhaseStati(eqid);
            obj.CurEqId=eqid;
        end
        
        function ApplyPhaseStati(obj, eqid)
            PhaseStati = eqid.PhaseStati;
            %obj.LogAndExecute(@tc_set_phase_status, '*', 'ENTERED', '0');
            for i=1:size(PhaseStati,1)
                obj.LogAndExecute(@tc_set_phase_status, PhaseStati{i,1}, PhaseStati{i,2}, PhaseStati{i,3});
            end
        end
        
        function ApplyConditions(obj, Conditions)
            obj.LogAndExecute(@tc_delete_condition, '*');
            for i=1:size(Conditions,1)
                obj.LogAndExecute(@tc_set_condition, Conditions{i,1}, Conditions{i,2});
            end
        end
        
        function ierr = checkError(obj, varargin)
            [state]=sk_tool_parse_varargin(varargin, []);
            [ierr,msg]=tc_error;
            if  ierr ~= 0
                tc_reset_error;
                assignin('base', 'StateWithError', state);
                error('Error in TC system:\n %s', msg);
            end
        end
        function l = GetLog(obj)
            l=obj.TCLog;
            if isempty(l)
                warning('Log is empty. Set sk_tc_system.Log=1 to save Debug Data');
            end
        end
        function l = GetLogChar(obj)
            l = sk_tool_plotfunctionlog(obj.GetLog);
        end
        function ClearLog(obj)
            obj.TCLog=cell(0,6);
        end
        function varargout = LogAndExecute(obj, func, varargin)
            n=length(varargin);
            if obj.Log
                row=[{func2str(func)} varargin];
                obj.TCLog(obj.logPointer,1:n+1) = row;
                if size(obj.TCLog, 1) > obj.LogLength
                    obj.TCLog(1,:)=[];
                else
                    obj.logPointer = obj.logPointer+1;
                end
            end
            if  nargout>0
                varargout{1:nargout} = func(varargin{:});
            else
                func(varargin{:});
            end
        end
    end
    
    methods (Static)
        function obj = fromJSONFile(path)
            txt = fileread(path);
            
            obj = sk_tc_system.fromJSON(txt);
        end
        
        function obj = fromJSON(txt)
            tmp = jsondecode(txt);
            
            obj = sk_tc_system(tmp.db, tmp.elm, tmp.rejph, tmp.resph);
            
            obj.InitialEq.Conditions = tmp.eq.Conditions;
            obj.InitialEq.PhaseStati = tmp.eq.PhaseStati;
            obj.InitialEq.Minimization = tmp.eq.Minimization;
            
            tmp.ResPhases = obj.ResPhases;
            tmp.RejPhases = obj.RejPhases;
            tmp.Elements = obj.Elements;
            tmp.Database = obj.Database;
            tmp.BaseElement = obj.BaseElement;
            tmp.Functions = obj.Functions;
            tmp.Variables = obj.Variables;
        end
    end
end

