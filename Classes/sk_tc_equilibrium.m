classdef sk_tc_equilibrium <handle
%sk_tc_equilibrium represents a Thermo-Calc Equilibrium and acts a
%a wrapper function for thermocalc subsystem (tc_*).   

    properties%(Access = private)
        PhaseStabilityTolerance=1e-12;
    end
    
    properties(SetAccess = private,GetAccess = public)
        TCSYS;
        NeedRecalc=0;
        ForceFlush=0;
        Conditions = cell(0,2);
        PhaseStati = cell(0,3);
        Minimization = 1;
    end
    
    properties(Access = private)
    end    
    
    methods
        function obj = sk_tc_equilibrium(TCSYS)
        %obj = sk_tc_equilibrium(tcsys) creates new object using the given sk_tc_system object

            validateattributes(TCSYS, {'sk_tc_system'}, {'nonempty'});

            obj.TCSYS = TCSYS;
        end
        
        function newobj = Clone(obj)
        %Clones the equilibrium to a new object
        
            newobj = obj.TCSYS.GetNewEquilibrium;
            obj.CopyTo(newobj);
        end
        
        function eq = isequal(obj, oobj)
            %Checks wether the given EQ is equal to the current one
            %regarding conditions, phase stati and minimization
            
            eq = all([isequal(obj.GetConditions,oobj.GetConditions), isequal(obj.GetPhaseStatus,oobj.GetPhaseStatus), obj.Minimization==oobj.Minimization]);
        end
        
        function CopyTo(obj, otherObj)
        %Clone() Copies this state to another Eq Object
        
            validateattributes(otherObj,{'sk_tc_equilibrium'},{'nonempty'});
            
            otherObj.SetConditions(obj.GetConditions);
            otherObj.SetPhaseStati(obj.GetPhaseStatus);
            otherObj.Minimization=obj.Minimization;
        end
        
        function CopyFrom(obj, otherObj)
        %Clone() Copies state from another Eq Object

            validateattributes(otherObj,{'sk_tc_equilibrium'},{'nonempty'});
            
            obj.DeleteCondition('*');
            obj.DeletePhaseStatus('*');
            obj.SetConditions(otherObj.GetConditions);
            obj.SetPhaseStati(otherObj.GetPhaseStatus);
            obj.Minimization=otherObj.Minimization;
        end
        
        function ExportJSON(obj, path)
            %Export this state to json file
            
            fid = fopen(path, 'w');
            tmp = struct;
            tmp.Conditions = obj.Conditions;
            tmp.PhaseStati = obj.PhaseStati;
            tmp.Min = obj.Minimization;
            
            fprintf(fid, '%s', jsonencode(tmp));
            fclose(fid);
        end
        
        function ImportJSON(obj, path)
            %import from json file
            
            txt = fileread(path);
            tmp = jsondecode(txt);
            obj.Conditions = tmp.Conditions;
            obj.PhaseStati = tmp.PhaseStati;
            obj.Minimization = tmp.Min;
        end
        
        function obj = ImportCSV(obj, path, BaseElement)
            %import from CSV with the weight percent for each element in
            %one column and containing only one data row and a header row
            %with the elements.
            %ie:
            %
            
            T = readtable(path);
            
            obj.ImportTable(T, BaseElement);
        end
        
        function obj = ImportTable(obj, T, BaseElement)
            %import from table with the weight percent for each element in
            %one column and containing only one row. The column names must
            %be the element names.
            %
            %eq = ImportTable(T, BaseElement)
            
            elm = T.Properties.VariableNames;
            elm = upper(elm);
            cnts = table2array(T(1,:));
            
            syselm = obj.TCSYS.Elements;
            syselm(ismember(syselm, BaseElement)) = [];
            
            [elm2, i2] = setdiff(elm, syselm);
            [elm3, ~] = setdiff(syselm, elm);
            
            if ~isempty(elm2)
                warning('Elements %s were ignored in import', char(join(elm2, ', ')));
            end
            if ~isempty(elm3)
                warning('Defined Elements %s were not in the imported Dataset', char(join(elm3, ', ')));
            end
            elm(i2) = [];
            cnts(i2) = [];
            
            obj.SetConditionsForComponents(elm', cnts'/100, 'w');
        end
        
        function thumb = GetThumb(obj, varargin)
        %Create a hash for the current state. 
        
            if ~isempty(varargin)
                ignoreCond = varargin{1};
                c = sk_tool_delcellrowbyid(obj.Conditions, ignoreCond);
                thumb = DataHash({c obj.PhaseStati obj.Minimization});
            else
                thumb = DataHash({obj.Conditions obj.PhaseStati obj.Minimization});
            end
        end
        
        function eq = isEqualTo(obj, state, varargin)
        %Check if is equal to eq, ignoring some optionally given conditions
        % equal = isEqualTo(eq, [excludeConds])
            
            if ~isempty(varargin)
                ignoreCond = varargin{1};
                c1=obj.Conditions;
                c2=state.Conditions;
                
                c1(strcmpi(ignoreCond,c1(:,1)),:)=[];
                c2(strcmpi(ignoreCond,c2(:,1)),:)=[];
                
                eq1 = isempty(sk_tool_celldiff(c1, c2));
            else
                eq1 = isempty(sk_tool_celldiff(obj.Conditions, state.Conditions));
            end

            eq2 = isempty(sk_tool_celldiff(obj.PhaseStati, state.PhaseStati));
            eq = eq1 && eq2;
        end
        
        function Load(obj)
        %Activates and reloads the Equilibrium. Same as ApplyState(true)
        
            obj.ApplyState(1);
        end
        
        function Calculate(obj)
        %Recalculates the Equilibrium
        
            obj.Recalc(0);
        end

        %%
        function SetCondition(obj, Pattern, varargin)
        %Sets a Condition with a formated string (sprintf syntax). The last
        %parameter represents the value to be set.
        %SetCondition(Pattern, Vars..., Content)
        
            validateattributes(Pattern,{'char'},{'nonempty'});
            
            q = sprintf(Pattern, varargin{1:end-1});
            v = varargin{end};
            
            if contains(q,'*')
                wcph = regexp(q,'\(\*,?([^)*]*)\)', 'tokens');
                wcel = regexp(q,'\(([^,)*%]*),?[*%]\)','tokens');
                op = regexp(q, '([^\(]+)\(', 'tokens');
                if ~isempty(wcel)
                    el = obj.TCSYS.Elements;
                    el(strcmpi(el, obj.TCSYS.BaseElement))=[];
                    for i=1:numel(el)
                        if strcmp(wcel{1}, '')
                            q=sprintf('%s(%s)', op{1}{1}, el{i});
                        else
                            q=sprintf('%s(%s,%s)', op{1}{1}, wcel{1}{1}, el{i});
                        end
                        obj.SetCondition(q, v)
                    end
                elseif ~isempty(wcph)
                    ph = obj.TCSYS.Phases;
                    for i=1:numel(ph)
                        if strcmp(wcph{1}, '')
                            q=sprintf('%s(%s)', op{1}{1}, ph{i});
                        else
                            q=sprintf('%s(%s,%s)', op{1}{1}, ph{i}, wcph{1}{1});
                        end
                        obj.SetCondition(q, v);
                    end
                end
                return;
            end
            

            Condition = obj.NormalizeCondition(q);       
            obj.Conditions=sk_tool_addtocellunique(obj.Conditions, {Condition, v});
        end
        
        function GetValueSetCondition(obj, Pattern, varargin) 
        %Gets a value and sets it as a condition
        %GetValueSetCondition(Patter, Vars...)
        
            obj.SetCondition(Pattern, varargin{:}, obj.GetValue(Pattern, varargin{:}));
        end
        
        function SetPhaseStatus(obj, Phase, Status, Value)
        %Sets the Status of the phases to the
        %given Status and Amount (eg 'fixed', 1)
        %SetPhaseStatus(Phase, Status, Amount)
        
            if strcmp(Phase, '*')
                obj.SetPhaseStati(obj.TCSYS.Phases, Status, Value);
                return;
            end
            
            Phase = obj.ParsePhaseName(Phase);
            obj.PhaseStati=sk_tool_addtocellunique(obj.PhaseStati, {Phase, upper(Status), Value});
        end
        function SetPhaseStati(obj, varargin)
            %Set multiple phase stati.
            %SetPhaseStati(obj, Cellarray) Sets Phase Stati from nx3 Cellarray
            %SetPhaseStati(obj, Cell, Status, Value) Sets the status of all Phases in Cell to the given Status
            
            narginchk(2,4);
            [Cell, Status, Value] = sk_tool_parse_varargin(varargin, [], 'ENTERED', 0);
            
            if size(Cell,2)==3
                Value=Cell(:,3);
                Status=Cell(:,2);
                Phase=Cell(:,1);
            else
                Status=repmat({Status}, size(Cell));
                Value=repmat({Value}, size(Cell));
                Phase = Cell;
            end
            
            for i=1:size(Cell,1)
                obj.SetPhaseStatus(Phase{i}, Status{i}, Value{i});
            end
        end
        function SetState(obj, Status)
        %Deprecated. Sets the active State to the given Status
        
            if ~isa(Status, 'sk_tc_equilibrium')
                warning('Status not set, wrong type');
                return;
            end

            obj.CopyFrom(Status);
            %obj.NeedRecalc = 1;
        end
        function SetMinimization(obj, state)
        %Changes the Global Minimization status
        %Valid Values are 1 0 on off
        
            if ischar(state)
                state = lower(state);
            end
            
            switch state
                case {'on', 1}
                    s = 1;
                case {'off', 0}
                    s = 0;
                otherwise
                    error('unknown state %s', state);
            end

            obj.Minimization=s;
        end
        %%
        function SetWpc(obj, varargin)
        % Sets the Content of Element to the given Weight%
        % SetWpc(Element, Weight%)
        % SetWpc(M) Where M is a nx2 Cellarray with Elements in the first and
        % contents in the second column
        
            [Elm, wpc] = sk_tool_parse_varargin(varargin, [],[]);
            de = obj.GetElements;
            if iscell(Elm) && isempty(wpc)
                for i=1:size(Elm,1)
                    e=Elm{i,1};
                    if ~any(strcmpi(de, e))
                        warning('Element %s not in System, ignored!', e);
                        continue;
                    end
                    v=Elm{i,2};
                    if isempty(v)
                        v=0;
                    end
                    obj.SetCondition('w(%s)', e, v/100);
                end
            elseif ischar(Elm) && isscalar(wpc)
                obj.SetCondition('w(%s)', Elm, wpc/100);
            else
                error('Wrong arguments');
            end
        end
        
        function SetDegree(obj, T)
        %Sets Temperature to T in Celsius
                
            obj.SetCondition('T', T+273.15);
        end
        
        function SetCelsius(obj, T)
        %Sets Temperature to T in Celsius
            obj.SetDegree(T);
        end
        
        function SetDefaultConditions(obj)
        %Sets a standard Environment. T=1000°C, n=1, p=101325
        
            obj.SetCondition('T', 1273.15);
            obj.SetCondition('n', 1);
            obj.SetCondition('p', 101325);
        end
        
        function SetCondsToZero(obj)
            %Sets the content of all independend elements to 0
            
            e=obj.GetVarElements(obj.GetBaseElement);
            z=zeros(length(e), 1);
            obj.SetConditionsForComponents(e, z , 'w');
        end
        
        function SetConditions(obj, Cell, varargin) 
        %Sets Conditions from a Cell array nx2, with Conditions in the fist and values in the second column
        %SetConditions(input, [forceBaseElement]) 

            forceBE = sk_tool_parse_varargin(varargin, false);
        
            if ~iscell(Cell) 
                Cell=sk_tool_kvsplit(Cell);
            end
            
            Value=Cell(:,2);
            Condition=Cell(:,1);
            if ~forceBE
                be = obj.GetBaseElement;
            end
            
            %obj.PhaseStati(Phase)={Status, Value};
            for i=1:length(Condition)
                %
                if ~forceBE
                    if ~isempty(regexpi(Condition{i}, ['[^a-zA-Z]' be '[^a-zA-Z]']))
                        continue;
                    end
                end
                v = Value{i};
                if ischar(v)
                    v = str2double(v);
                end
                
                obj.SetCondition(Condition{i}, v);
            end
        end
        function SetConditionsForComponents(obj, components, values, defaultParm)
        % Set Conditions for set of components
        %   component:    component like {'w(c)', t} or elements, see defaultparm
        %   values:       values to set, array
        %   defaultparm:  Parameter to add if only elements are given in component
            
            validateattributes(components,{'cell'},{});
            validateattributes(values,{'numeric','cell'},{'size',size(components)});
            narginchk(3,4);
            n=length(components);
            syselm = obj.TCSYS.Elements;

            if iscell(values)
                values = cell2mat(values);
            end

            
            for i=1:n
                if nargin==4
                    if ~any(strcmpi(components{i}, syselm))
                        warning('Element %s not in system, ignored', components{i});
                        continue;
                    end
                    obj.SetCondition('%s(%s)',defaultParm, components{i}, values(i));
                else
                    obj.SetCondition(components{i},values(i));
                end
            end
        end
        
        function SetMin(obj, state)
        %Alias for SetMinimization
        
            obj.SetMinimization(state);
        end
        
        function DeleteCondition(obj, cond, varargin) 
        %Deletes one or more condition.
        %DeleteCondition(cond) Delete one or more conditons if its a cellarray.
        %DeleteCondition(condPattern, var1, var2, ...)   Parses the Format like sprintf
        %DeleteCondition('*') Delete all conditions
                
            if iscell(cond)
                for i=1:numel(cond)
                    obj.DeleteCondition(cond{i}, varargin{:});
                end
                return;
            end
            
            if ~isempty(varargin)
                cond = sprintf(cond, varargin{1:end});
            end
            
            if strcmpi(cond,'*')
                obj.Conditions=cell(0,2);
            else 
                c = obj.NormalizeCondition(cond);
                obj.Conditions=sk_tool_delcellrowbyid(obj.Conditions, c);
            end
        end
        
        function DeletePhaseStatus(obj, phname) 
        %Deletes one or more phase stati if its a cellarray.
        %To delete all Phase Stati, '*' can be given.
                
            if iscell(phname)
                for i=1:numel(phname)
                    obj.DeletePhaseStatus(phname{i});
                end
                return;
            end
                       
            if strcmpi(phname,'*')
                obj.PhaseStati=cell(0,3);
            else 
                c = obj.ParsePhaseName(phname);
                obj.PhaseStati=sk_tool_delcellrowbyid(obj.PhaseStati, c);
            end
        end
        
        function ApplyLocalComposition(obj, Phase)
        %Sets the State to match the composition of the given phase
        %ApplyLocalComposition(Phase)
            
            state = obj.GetLocalState(Phase);
            obj.CopyFrom(state);
        end
        %%
        function varargout = GetMainElementInPhase(obj, phase, varargin)
        % Finds the main element of a phase. Operator defaults to 'w'.
        % [element] = GetMainElementInPhase(obj, phase [, operator=w])
        % [element, content] = GetMainElementInPhase(obj, phase [, operator=w])
        
            op = sk_tool_parse_varargin(varargin, 'w');
            
            el = obj.GetElements;
            cnt = cellfun(@(e)(obj.GetValue('%s(%s,%s)', op, phase, e)), el);
        
            [~,i]=max(cnt);
            
            varargout{1} = el{i};
            if nargout >= 2
                varargout{2} = cnt(i);
            end
        end
        function minState = GetMinimization(obj)
        %Returns the Minimization mode
            
            minState = obj.Minimization;
        end
        
        function minState = GetMin(obj)
        %Returns the Minimization mode
        
            minState = obj.GetMinimization;
        end
        
        function tcsys = GetTCSystem(obj)
        %Returns the sk_tc_system
            
            tcsys = obj.TCSYS;
        end
        
        function phases = GetPhases(obj, varargin)
            %GetPhases()         Returns all Phases
            %GetPhases(Status)   Returns Phases matching the given State
            %
            
            [Status] = sk_tool_parse_varargin(varargin, []);
            
            if isempty(Status)
                %phases=obj.Phases;
                phases = obj.TCSYS.GetPhases;
                return;
            end
                       
            stats=obj.GetPhaseStatus;
            stats=stats(ismember(stats(:,2), upper(Status)),:);
            phases = stats(:,1);
        end
        
        function Phases = GetStablePhases(obj)
        %GetStablePhases    Returns all Phases with an amount > 0
            
            phlist = obj.GetPhases;
            cont = zeros(size(phlist));
            num=numel(phlist);

            for n=1:num
                ph = phlist{n};
                cont(n)=obj.GetValue('vpv(%s)', phlist{n});
            end
            Phases = phlist(cont>=obj.PhaseStabilityTolerance);
        end
        
        function elem = GetComponents(obj)
        %Returns all Elements in the System. Same as GetElements.
        
            elem=obj.GetElements;
        end
        
        function elem = GetElements(obj)
        %Returns all Elements in the System
            
            elem=obj.TCSYS.Elements;
        end
        
        function elem = GetVarElements(obj, varargin)
        %Returns all elements except the base element or a given optional Element
            
            [be] = sk_tool_parse_varargin(varargin, @obj.GetBaseElement);
            elem=obj.GetElements;
            elem(strcmpi(elem, be()))=[];
        end
        
        function sysconds = GetSystemConditions(obj) 
        %GetSystemConditions    Returns all Conditions not matching an
        %                       Element (N, P, T)

            conds = obj.GetConditions;
            
            sysconds=cell(0,2);
            for i=1:size(conds,1)
                if ~contains(conds{i,1}, '(')
                    sysconds=[sysconds;conds(i,:)];
                end
            end
        end
        
        function varargout = GetValuesInPhase(obj, Phase, Var, varargin)
        %Gets Variable of all Components in the given Phase, sorted descending by content.
        %GetValuesInPhase(Phase, Var, FilterElem)
                        
            [felem] = sk_tool_parse_varargin(varargin, []);
            
            elem = obj.GetElements;
            if ~isempty(felem)
                elem(strcmpi(elem,felem))=[];
            end
            n=length(elem);
            vars=cell(n,1);
            vars2=cell(n,1);
            vals=NaN(n,1);
            for i=1:n
                q=sprintf('%s(%s,%s)', Var, Phase, elem{i});
                vals(i) = obj.GetValue(q);
                vars2{i}=q;
                vars{i} = sprintf('%s=%d', q, vals(i));
            end
            [~,I] = sort(vals, 'descend');
            if nargout==1
                varargout{1}=vars(I);
            else
                varargout{1}=vars2(I);
                varargout{2}=vals(I);
            end
        end
        
        function phstat = GetPhaseStatus(obj, varargin)
        %cellarray = GetPhaseStatus()       Gets the Status of all Phases
        %cellarray = GetPhaseStatus(Phase)  Gets the Status of a Phase 
        
            [Phase] = sk_tool_parse_varargin(varargin, '*');
            
            if strcmp(Phase,'*')
                phstat = obj.PhaseStati;
            else
                ph = obj.ParsePhaseName(Phase);
                phstat = sk_tool_getcellrowbyid(obj.PhaseStati, ph);
            end
            phstat = sortrows(phstat);
        end
        
        function [conds, Phase] = GetLocalConditions(obj, varargin)
        %Returns the local conditions of a phase.
        %GetLocalConditions(Phase)          Get Conditions in a Phase
        %GetLocalConditions(Phase, Operator)          Get Conditions in a Phase
        %GetLocalConditions(Phase, Operator, baseElement)          Get Conditions in a Phase
        
            
            [Phase, Operator, belem] = sk_tool_parse_varargin(varargin, [], 'x', []);
            if isempty(Phase)
                Phase = obj.GetMainPhase;
            end
            if isempty(belem)
                belem = obj.GetBaseElement;
            end
            [vars, vals] = obj.GetValuesInPhase(Phase, Operator, belem);
            vars = obj.local2globalCond(vars);
            
            conds = [vars num2cell(vals)];
            glob = obj.GetSystemConditions;
            conds = [conds; glob];
        end
        
        function state = GetLocalState(obj, varargin) 
            %Returns the local state of a phase.
            %GetLocalState()                Gets State of Main Phase
            %GetLocalState(Phase)           Gets State of a Phase
            %GetLocalState(Phase, Operator) Gets State of a Phase with a given Operator            
            %GetLocalState(Phase, Operator, Base Element) Gets State of a Phase with a given Operator   
            
            [conds, phase] = obj.GetLocalConditions(varargin{:});
            
            state=obj.TCSYS.GetNewEquilibrium;
            for i=1:size(conds,1)
                state.SetCondition(conds{i,1}, conds{i,2});
            end
            state.SetCondition('n', obj.GetValue('np(%s)', phase));
        end
        
        function partEQs = GetPartialEquilibrium(obj, varargin)
            %GetPartialEquilibrium()           Gets Partial Equilibrium of
            %                                  all stable Phases
            %GetPartialEquilibrium(Phases)     Gets State of a Set of
            %                                  Phases
            
            [Phases] = sk_tool_parse_varargin(varargin, '*');
            
            if strcmp(Phases, '*')
                Phases = obj.GetStablePhases;
            else
                if ~iscell(Phases)
                    Phases = {Phases};
                end
                Phases = obj.ParsePhaseName(Phases);
            end            
            
            n=numel(Phases);
            pheqs=cell(1,n);
            for i=1:n
                ph = Phases{i};
                conds = obj.GetValue('x(%s,*)', ph);
                conds = sk_tool_delcellrowbyid(conds, obj.GetBaseElement);
                pheq = obj.TCSYS.GetNewEquilibrium;
                conds(:,1) = sk_tool_csprintf('x(%s)', conds(:,1));
                pheq.SetConditions(conds);
                pheq.SetCondition('n', obj.GetValue('np(%s)', ph));
                pheq.SetCondition('t', obj.GetValue('t'));
                pheq.SetCondition('p', obj.GetValue('p'));
                pheq.SetPhaseStatus('*', 'SUSPENDED', 0);
                pheq.DeletePhaseStatus(ph);
                pheqs{i}=pheq;
            end
            partEQs = sk_tc_partial_eq(Phases, pheqs);
        end
        function belm = GetBaseElement(obj)
        %GetBaseElement     Returns the Base element, which has no conditions
            if ~isempty(obj.TCSYS.BaseElement)
                belm = obj.TCSYS.BaseElement;
                return;
            end

            cmp = obj.GetElements;
            nc=length(cmp);
            cond = obj.GetConditions;
            nco=length(cond);
            belm=[];
            matches=0;

            for ci=1:nc
                found = false;
                for con=1:nco
                    if ~isempty(regexpi(cond{con}, ['^[a-z]+\(' cmp{ci} '\)']))
                        found = true;
                        break;
                    end
                end

                if ~found
                    belm=cmp{ci};
                    matches = matches + 1;
                end
            end

            if matches~=1
                error('%i elements are not defined... base element could not be identified', matches);
            end
        end
        
        function [varargout] = GetMainPhase(obj, varargin) 
            %Searches the main phase of the system. 
            %GetMainPhase()                         Gets the Main Phase using vpv
            %GetMainPhase(Operator)                 Gets the Main Phase using operator
            %GetMainPhase(Operator,AllowedPhases)   Gets the Main Phase using operator
            %                                       and the given Whitelist of Phases
            
            [operator, allowed] = sk_tool_parse_varargin(varargin, 'vpv', {});

            phlist = obj.GetPhases;
            num=length(phlist);
            maxval = 0;
            maxid = [];
            filter = 0;

            if ~isempty(allowed)
                filter = 1;
                if strcmpi(allowed, '*')
                    filter=0;
                else
                    allowed = cellfun(@(c)(obj.ParsePhaseName(c)), allowed, 'UniformOutput', false);
                end
            end

            for n=1:num
                ph = phlist{n};
                if filter && ~any(strcmp(ph, allowed))
                    continue;
                end

                cont=obj.GetValue('%s(%s)', operator, ph);
                if (cont > maxval)
                    maxval=cont;
                    maxid=ph;
                end
            end

            if maxval==0
                error('No main phase found... check filter');
            end

            varargout = sk_tool_mkvarargout(nargout, maxid, maxval);
        end
        
        function varargout = GetValue(obj, Pattern, varargin )
%Queries one or more values of the system.
%GetValue(Query)                 Passes the Query to TC and returns the Value
%                                If Query is a Cellarray, a Cellarray with
%                                the same size as query is returned. The
%                                queries itself are also returned as a
%                                second cellarray.
%GetValue(Pattern, var1, var2)   Parses the Pattern using the given vars
%                               (like sprintf) and queries the result.
%One Wildcard for Species or Components can be used, querying all available
%eg. w(fcc,*) or x(*) or x(*,c)
            
            if iscell(Pattern)
                res=cell(size(Pattern));
                for i=1:numel(Pattern)
                    res{i}=obj.GetValue(Pattern{i});
                end
                varargout{1}=res;
                varargout{2}=Pattern;
                return;
            end
            q = sprintf(Pattern, varargin{:});
            
            if contains(q,'*')
                op = regexp(q, '([^\(]+)\(', 'tokens');
                op = op{1}{1};
                qs = {};
                
                if contains(q,'*,*') % Alle Phasen, Alle Elemente
                    el = obj.GetElements;       
                    ph = obj.GetStablePhases;
                    
                    qperms = combvec(1:numel(el), 1:numel(ph))';
                    qM = [el(qperms(:,1)) ph(qperms(:,2))];
                    qGrps = mat2cell(qM, ones(size(qperms,1),1), 2);
                    
                    qs = cellfun(@(c)(sprintf('%s(%s,%s)', op, c{2}, c{1})), qGrps, 'UniformOutput', false);                
                else              
                    wcph = regexp(q,'\(\*,?([^)*]*)\)', 'tokens');
                    wcel = regexp(q,'\(([^,)*%]*),?[*%]\)','tokens');

                    phops = {'vpv', 'npn', 'vp', 'np'}; %Operatoren auf phasen
                    isph = any(strcmpi(phops, op)); % Ist eine Nachfrage nach phasen

                    if ~isempty(wcel) && ~isph
                        %All components are queried
                        el = obj.GetElements;
                        if strcmp(wcel{1}, '')
                            qs = cellfun(@(C)(sprintf('%s(%s)', op, C)), el, 'UniformOutput', false);
                        else
                            pname = obj.ParsePhaseName(wcel{1}{1});
                            qs = cellfun(@(C)(sprintf('%s(%s,%s)', op, pname, C)), el, 'UniformOutput', false);
                        end
                    elseif ~isempty(wcph) && isph
                        %All Phases are queried
                        ph = obj.GetPhases;
                        if strcmp(wcph{1}, '')
                            qs = cellfun(@(C)(sprintf('%s(%s)', op, C)), ph, 'UniformOutput', false);
                        else
                            qs = cellfun(@(C)(sprintf('%s(%s,%s)', op, C, wcph{1}{1})), ph, 'UniformOutput', false);
                        end
                    end
                end
                
                res = obj.GetValue(qs);

                if nargout <= 1
                    varargout{1}=[qs res];
                else
                    varargout{1}=qs;
                    varargout{3}=res;
                end   
            else
                obj.Recalc;
                res = tc_get_value(q);
                obj.checkError;
                varargout{1}=res;
            end
        end
        
        function res = GetValuesInRange(obj, VarCond, Range, Pattern, varargin)
        %Variates condition VarCond in Range and returns the Value given by Pattern
        %res = GetValuesInRange(VarCond, Range, Pattern, var1, var2, ...)
        
            n=numel(Range);
            res=nan(n,2);
            res(:,1)=Range;
            
            tmpState = obj.Clone;
            
            for i=1:n
                tmpState.SetCondition(VarCond, Range(i));
                res(i,2) = tmpState.GetValue(Pattern, varargin{:});
            end
        end
            
        function conds = GetConditions(obj, varargin)
        %GetConditions      Returns all Conditions in the current state
        %GetConditions(C)      Returns the value of the given condition
        
            [c] = sk_tool_parse_varargin(varargin, '*');
            
            if strcmp(c,'*')
                conds = obj.Conditions;
            else
                conds = sk_tool_getcellrowbyid(obj.Conditions, c);
            end
            conds = sortrows(conds);
        end
        
        function r = GetProperty(obj, expr)
        %Calculates a property of using sk_func_tc_properties. 
        
            a = sk_func_tc_properties(obj, expr);
            
            r=a.calculate;
        end
        
        function dof = GetDegreeOfFreedom(obj)
        %Returns the Degree of Freedom in the current State

            ps = obj.GetPhaseStatus;
            np = sum(strcmpi(ps(:,2), 'FIXED'));
            conds = obj.GetConditions;
            nc=size(conds,1);
            ne = numel(obj.TCSYS.Elements);
            
            dof = ne + 3 - 1 - np - nc;
        end
        
        function [ res ] = GetValueSum( obj, elements, var )
        %GetValueSum(elements, modifier) Gets contents of given set of elements
            
            cnt = cellfun(@(c)(obj.GetValue('%s(%s)', var, c)), elements, 'UniformOutput',false);

            res = sum(cell2mat(cnt));
        end
        
        function cnt = GetBaseElementContent(obj, varargin) 
            %GetBaseElementContent(Modifier)  Gets the Content of base
            %element. Modifier defaults to 'w'
            
            mod = sk_tool_parse_varargin(varargin, 'w');
            
            be = obj.GetBaseElement;
            cnt = obj.GetValue('%s(%s)', mod, be);
        end
        
        %%
        function DeleteConditionsForElements(obj, elements )
        %Deletes all Conditions touching the given Elements

            if ~iscell(elements)
                elements={elements};
            end

            conds = obj.GetConditions;

            for ei=1:length(elements)
                for ci=1:length(conds)
                    condition=conds{ci};
                    [starti, endi] = regexpi(condition, ['^[a-z]+\(' elements{ei} '\)']);
                    if ~isempty(starti)
                        obj.DeleteCondition(condition(starti:endi));
                        break;
                    end
                end
            end
        end
        function ConvertConditions (obj, param)     
%ConvertConditions(Operator)       Converts the current conditions to the
%new operator: w(c) --> x(c)
            
            cmp = obj.GetElements;
            be = obj.GetBaseElement;
            cmp(strcmpi(cmp, be))=[];
            cont=cell(size(cmp));

            for i=1:numel(cmp)
                c=cmp{i};
                cont{i} = obj.GetValue('%s(%s)', param, c);
            end

            obj.DeleteConditionsForElements(cmp);

            for i=1:numel(cmp)
                c=cmp{i};
                obj.SetCondition('%s(%s)', param, c, cont{i});
            end
        end
        
        function Clear(obj)
%Clears the current State, deleting all Conditions and Phase Stati
            
            obj.SetPhaseStatus('*','ENTERED',0);
            obj.DeleteCondition('*');
            obj.SetMin('on');
        end
        
        %%
        function DisplayState(obj)
%Prints the current State 
           
            c=obj.Conditions';
            fprintf('---------------\n');
            fprintf('Global Minimization: %d\n', obj.Minimization);
            fprintf('---------------\n');
            fprintf('Conditions: \n');
            fprintf('---------------\n');
            fprintf('% 10s = %g\n', c{:});
            fprintf('---------------\n');
            fprintf('Phase stati:\n');
            fprintf('---------------\n');
            pk=obj.PhaseStati;
            for i=1:length(pk)
                fprintf('% 10s = % 7s(%g)\n', pk{i,1}, pk{i,2}, pk{i,3});
            end           
        end
        
        function DisplayEquilibrium(obj, varargin)
%Prints out the current equilibrium
%DisplayEquilibrium() Defaults to vpv and w
%DisplayEquilibrium(phasemod, elementmod) 
%
            
            [pmod, emod]=sk_tool_parse_varargin(varargin, 'vpv', 'w');

            elm = obj.GetElements;
            prnti=1;
            for i=1:numel(elm)
                e=elm{i};
                v=obj.GetValue('%s(%s)', emod, e);
                if v <= 1e-12
                    continue;
                end
                fprintf('%s(% 2s)=% 8f\t', emod, e, v);
                if mod(prnti,4)==0
                    fprintf('\n');
                end
                prnti=prnti+1;
            end
            
            phlist = obj.GetPhases;
            num=numel(phlist);
            t=obj.GetValue('T');

            fprintf ('\n\nT=%g K (%g °C)\n',t, t-273.15)

            for n=1:num
                ph = phlist{n};
                cont=obj.GetValue('%s(%s)', pmod, ph);
                if (cont > obj.PhaseStabilityTolerance )
                    fprintf('%s(%s): %.8g\n', pmod, ph, cont)
                    obj.DisplayPhaseContents(ph, emod);
                end
            end
            obj.checkError;
        end
        
        function DisplayPhaseContents(obj, phName, phmod)
        %Print the content of a phase
        %DisplayPhaseContents(phName, mod)
        
            elmList = obj.GetElements;
            num = length(elmList);

            C=NaN(num,1);
            output = cell(num,1);

            for n=1:num
                query = sprintf('%s(%s,%s)', phmod, phName, char(elmList{n}));
                cont = obj.GetValue(query);
                C(n)=cont;
                output{n} = sprintf('%s(% 2s): % 8.8f', phmod, char(elmList{n}), cont);
            end
            [~,I]=sort(C,'descend');

            obj.checkError;
            output = output(I);
            fprintf('\t%s\n', output{:});
        end
        
        function Flush(obj)
        %calls the flush function of the tcsys object
        
            obj.TCSYS.Flush();
        end
        
        %%
        
        function PN = ParsePhaseName(obj, phname) 
        %Parses the given string to a valid phase identifier
        
            if iscell(phname)
                PN = cellfun(@(c)(obj.ParsePhaseName(c)), phname, 'UniformOutput', false);
                return;
            end
            ph = obj.TCSYS.Phases;
            if numel(ph) == 0
                ph = obj.TCSYS.Phases;
                if numel(ph) == 0
                    error('Error getting Phases');
                end
            end
            
            %Find exact matches
            ind = find(ismember(ph, upper(phname)));
            if ~isempty(ind)
                PN=ph{ind};
                return;
            end
            
            %Find Phases beginning with the searched name
            for i=1:numel(ph)
                if strncmpi(ph{i}, phname, length(phname))
                    PN=ph{i};
                    return;
                end
            end
            
            %nothing found
            error('Phase with name %s could not be resolved', phname);
        end
    end
    
    methods(Access = private)
        function Recalc(obj, varargin)
            [force] = sk_tool_parse_varargin(varargin, 0);
            if obj.NeedRecalc
                force=1;
            end
            obj.TCSYS.Recalc(obj, force);
            obj.NeedRecalc=0;
        end
        function ApplyState(obj,force)
            obj.TCSYS.ApplyState(obj,force);
        end
        function ierr = checkError(~)
            [ierr,msg]=tc_error;
            if  ierr ~= 0
                tc_reset_error;
                error('Error in TC system:\n %s', msg);
            end
        end
       
        function nconds=local2globalCond(~, conds)
            if ~iscell(conds)
                conds={conds};
            end
            
            nconds=cellfun(@(c)(regexprep(c,'(\w*)\(\w*,(\w*)\)','$1($2)')),conds,'uniformoutput',false);
        end
        
        function ncond = NormalizeCondition(obj, cond)
            if iscell(cond)
                ncond = cellfun(@(c)(obj.NormalizeCondition(c)), cond, 'UniformOutput', false);
                return;
            end
            
            ncond = upper(cond);
            ph = regexpi(ncond, '\((\w*),\w*\)', 'tokens', 'once');
            if ~isempty(ph)
                phaseid = obj.ParsePhaseName(ph{1});
                ncond = strrep(ncond, ph, phaseid);
            end
            ncond=char(ncond);
        end
    end
end

