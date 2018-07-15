classdef sk_tc_system<handle
    %sk_tc_system is the very basic class of the thermodynamic stack. 
    %
    %It interacts with the tc_* subsystem and defines the
    %thermodynamic system. It keeps track of changes to the current
    %conditon set and calculates the equilibrium only if neccessary.
    %
    %It furthermore keeps track of different sets of
    %phase stati and automatically assigns them to indivdual EQ-IDs for
    %performance and stability issues. 
    
    properties
        Elements;           %Elements (Components) to get from database. Mandatory.
        Database;           %The database to use. Mandatory.
        RejPhases;          %The phases to reject. Mandatory.
        ResPhases;          %The phases to restore. Mandatory.
        LastApplied;        %Contains the last equilibrium that was applied.
        LastCalc;           %Contains the last equilibrium that was calculated.
        BaseElement='FE';   %Default FE. Base Element. By setting this, stability can be improved.
        Log=0;              %Default 0. Sets wether commands shall be logged or not. Logging may slow down performance.
        LogLength=100;      %Default 100. Start length of the Log. Higher values take more memory but may improve performance.
    end
    
    properties(GetAccess = public, SetAccess = private)
        Phases;                     %Link to sk_tc_system.GetPhases
    end
    
    properties(Access = private)
        logPointer=1;
        InitialEq;
        initElm;
        Elm;
        Ph;
        Min=1;
        DirtyStates=[];
        TCLog = cell(100,6);
        EqIds;
        CurEqId;
        CurEQ=0;                    %Current EQ ID in Thermo-Calc
        Functions=containers.Map;   %Functions that are set in Thermo-Calc
        Variables=containers.Map;   %Variables that are set in Thermo-Calc
    end
    
    methods
        
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
        
            %Set init parameters
            [database,elements,reject_phases,restore_phases] = sk_tool_parse_varargin(varargin,[],[],[],[]);
            obj.LogAndExecute(@tc_init_root);
            obj.initElm = elements;
            obj.Database = database;
            obj.ResPhases = restore_phases;
            obj.RejPhases = reject_phases;
                       
            obj.LastApplied=sk_tc_equilibrium(obj);
            
            %init the eq-ID collection
            obj.EqIds = sk_tc_eq_id_collection(obj);
            
            %Check if everything is there and initialize. If not, init has to be issued manually
            if obj.CheckDefined
                obj.Init;
            end
        end
        
        function isdef = CheckDefined(obj)
            %Check, if the system is defined
            
            isdef=~(isempty(obj.initElm) || isempty(obj.Database) || isempty(obj.RejPhases) || isempty(obj.ResPhases));
        end
        
        function isinit = CheckInit(obj)
            %Check, if the system is initalized
            
            isinit=isa(obj.InitialEq, 'sk_tc_equilibrium');
        end
        
        function ph = GetPhases(obj)
            %get the potentially stable phases of the system
            
            %[~,ph]=tc_list_phase;
            ph = obj.Ph;
        end
        
        function SetFunction(obj, varargin)
            %Enters a function into thermo-calc.
            %SetFunction(name, func)
            
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
            obj.LogAndExecute(@tc_enter_function, name, func);
        end
        
        function funcs = ListFunctions(obj)
            %List all functions in TC
            
            c=[keys(obj.Functions); values(obj.Functions)];
            funcs = sprintf('%s=%s\n', c{:});
        end
        
        function SetVariable(obj, varargin)
            %Enters a named Variable into thermo-calc.
            %SetVariable(name, var)
            
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
            obj.LogAndExecute(@tc_enter_variable, name, func);
        end
        
        function vars = ListVariables(obj)
            %List all variables in TC
            
            c=[keys(obj.Variables); values(obj.Variables)];
            vars = sprintf('%s=%s\n', c{:});
        end
        
        function varargout = Init(obj) 
            % Initializes the system. Returns an empty EQ if nargout = 1
            % [eq] = Init()
            
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
            
            %Init log
            obj.TCLog=cell(obj.LogLength,6);
            
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
            %Returns the initial Equilibrium
            %initEQ = GetInitialEquilibrium()
            
            eqObj = obj.InitialEq;
        end
        
        function eqObj = GetNewEquilibrium(obj)
            %Returns an empty equilibrium. Equal to sk_tc_equilibrium(tcsys).
            %neqEQ = GetNewEquilibrium()
            
            eqObj = sk_tc_equilibrium(obj);
        end
                    
        function b = IsActiveEquilibrium(obj, eq)
            % Checks, weather the given EQ is the active one.
            % bool = IsActiveEquilibrium(EQ)
            
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
            %Check, wether global minimization is on or off
            
            m=obj.Min;
        end
        
        function Recalc(obj, state, varargin)
            %Applies the current state to the TC-Subsystem and calculates
            %the Equilibrium if neccessary. Force Recalc with force=1.
            %Recalc(EQ, [force])
            
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
        
        function Flush(obj)
            %Reinitializes the poly3 module. May be useful to reset the internal state of TC
            
            obj.LastApplied = sk_tc_equilibrium(obj);
            obj.EqIds.Clear;
            obj.LogAndExecute(@tc_poly3_command, 'REINITIATE_MODULE');
        end

        function ierr = checkError(obj, varargin)
            %Check for a TC-Error, return it if available. If a Error is
            %found, the optionally given state is saved in the
            %StateWithError variable
            
            [state]=sk_tool_parse_varargin(varargin, []);
            [ierr,msg]=tc_error;
            if  ierr ~= 0
                tc_reset_error;
                assignin('base', 'StateWithError', state.Clone);
                error('Error in TC system:\n %s', msg);
            end
        end
        
        function l = GetLog(obj)
            %Return the command-log
            
            l=obj.TCLog;
            if isempty(l)
                warning('Log is empty. Set sk_tc_system.Log=1 to save Debug Data');
            end
        end
        function l = GetLogChar(obj)
            %Return the command-log in a readable format
            
            l = sk_tool_plotfunctionlog(obj.GetLog);
        end
        
        function ClearLog(obj)
            %Clear the command-log
            
            obj.TCLog=cell(0,6);
        end
        
        function ExportJSONFile(obj, path, varargin)
            %Exports this system to the file in path. if no EQ is given the initial EQ is included.
            %ExportJSONFile(path, [EQ])
            
            fid = fopen(path, 'w');
            fprintf(fid, '%s', obj.ExportJSON(varargin{:}));
            fclose(fid);
        end
        
        function json = ExportJSON(obj, varargin)
            %Serializes this System together with the given EQ or the initial EQ to a JSON-String
            %json = ExportJSON([EQ])
            
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
        
        function CreateEQ(obj, id)
            %Creates the EQ with the ID id
            obj.LogAndExecute(@tc_create_new_equilibrium, id);
            %fprintf('created ID %d\n\n', id);
        end   
        
        function SelectEQ(obj, id)
            %Activates the EQ with the ID id
            obj.LogAndExecute(@tc_select_equilibrium, id);
            %fprintf('switched to ID %d\n\n', id);
        end
    end
    
    methods (Access=private)
        function recalc = ApplyState(obj, state, ~)
            %Applies the conditions and phase states of the current state
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
            %switch to the given EQ ID and apply the phase stati
            obj.SelectEQ(eqid.EqID);
            obj.ApplyPhaseStati(eqid);
            obj.CurEqId=eqid;
        end
        
        function ApplyPhaseStati(obj, eqid)
            %Apply phase stati
            PhaseStati = eqid.PhaseStati;
            %obj.LogAndExecute(@tc_set_phase_status, '*', 'ENTERED', '0');
            for i=1:size(PhaseStati,1)
                obj.LogAndExecute(@tc_set_phase_status, PhaseStati{i,1}, PhaseStati{i,2}, PhaseStati{i,3});
            end
        end
        
        function ApplyConditions(obj, Conditions)
            %Apply all conditions
            obj.LogAndExecute(@tc_delete_condition, '*');
            for i=1:size(Conditions,1)
                obj.LogAndExecute(@tc_set_condition, Conditions{i,1}, Conditions{i,2});
            end
        end
        
        function varargout = LogAndExecute(obj, func, varargin)
            %Log the given handle in func with the following parameters and execute it.
            
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
            %Create a sk_tc_system object from the given JSON file
            
            txt = fileread(path);
            
            obj = sk_tc_system.fromJSON(txt);
        end
        
        function obj = fromJSON(txt)
            %Create a sk_tc_system object from the given JSON string
            
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

