classdef sk_func_tc_properties < sk_funcs
%Calculates derived properties given as a set of expressions using the
%sk_tc_property_* classes
%
%The expressions can be constructed of standard matlab expressions and
%functions, which are generated from the property classes. EG.:
%sqrt(md30).
%
%Parameters can be given, either as a string, or as another expression.
%Additonally, some named parameters are available: n, p, t, t_c
%md30(t_c=1200, p=1e5)
%pren(phase="bcc",t=1400)

    properties
        BaseEq=[];      %The equilibrium on which to operate
        zNames={''};    %The header names of the calculated data columns
        Properties;     %One or more expressions which define the properties
        Objects;        %A set of initialized solvers from type sk_tc_property_*. There, advanced parameters can be set. If not given, empty objects will be created.
        ClearCache=0;   %Clear the cache after calculation
        Celsius=0;      %Return everything in celsius instead of kelvin
    end
    
    properties (Access=private)
        ClassPrefix = 'sk_tc_property_';
        CalcProp;
        CalcVals;
        PropSolvers;
        RuntimeVars=struct;
    end
    
    methods 
        function obj = sk_func_tc_properties(eq, varargin)
            %Constructor. sk_func_tc_properties(EQ, [props]). 
            %EQ is mandatory. Props may be a set of property expressions.
            
            obj.BaseEq=eq;
            if ~isa(obj.BaseEq, 'sk_tc_equilibrium')
                error('Must set BaseEQ first');
            end
            [obj.Properties] = sk_tool_parse_varargin(varargin, obj.Properties);
            if ~iscell(obj.Properties)
                obj.Properties={obj.Properties};
            end
            obj.findPropertySolvers;
        end
        
        function r = get.zNames (obj)
            if ~iscell(obj.Properties)
                obj.Properties = {obj.Properties};
            end
            
            n=numel(obj.Properties);
            r = cell(1,0);
            for i=1:n
                try
                    o = obj.getObj(obj.Properties{i});
                    r=[r o.zNames];
                catch
                    r=[r obj.Properties{i}];
                end
            end
        end
       
        function flush(obj)
        %Clear the cache.
            obj.CalcProp=cell(0,1);
            obj.CalcVals=cell(0,1);
        end
        
        function r = getExpression(obj, eq, exp)
        %Deprecated. use ParseExpression                     
            r = obj.ParseExpression(eq, exp);
        end
        
        function r = ListProperties(obj)
        %List all available solvers
        
            r = obj.PropSolvers;
        end
        
        function res = calculate(obj, varargin )
            %Calculate the properties.
            %If vars and values are given, these are set as conditions
            %before execution (for mapper).
            %calculate([vars, values])
            
            [vars, values] = sk_tool_parse_varargin(varargin, {},[]);
            
            %Reset cached results if wanted            
            if obj.ClearCache
                obj.flush;
            end

            %Clone and set conditions
            eq=obj.BaseEq.Clone;
            eq.SetConditionsForComponents(vars, values);
           
            res = cell(1,0);
            %Calculate all Properties
            n=numel(obj.Properties);
            for i=1:n
                p=obj.Properties{i};
                r=obj.getExpression(eq, p);
                if isa(r, 'sk_tc_prop_result')
                    r = r.value;
                end
                res = [res {r}];
            end
            if numel(res)==1
                res = res{1};
            end
            fprintf('----\n');
        end
    end
    
    methods (Access=private)
        function r = ParseExpression(obj, eq, exp, varargin)
            %Builds a valid Matlab expression from a String like
            %'dg("fcc","bcc",t=2000, p=100)'.  For this, all appearances of
            %Classes like sk_tc_property_* are replaced by handles to the
            %function ExecuteToken with their name as the first input argument.
            %Also, " is replaced by ''.
            %At the End, this expression is executed and the result is
            %returned.
            
            forcedConds = varargin;
            
            exp = strrep(exp, '"', '''');                                           % " Als Delimiter erlauben
            exp = regexprep(exp, '([a-z0-9A-Z_]+)=([a-z0-9A-Z_"'']+)', '$1($2)');   % t=... durch t(...) ersetzen
            
            n=numel(obj.PropSolvers);
            vars=struct;
            h = @(name, varargin)(obj.ExecuteToken(name, eq, varargin{:}, forcedConds{:}));
            
        	for i=1:n
                s = obj.PropSolvers{i};
               
                ns =  matlab.lang.makeValidName(s);
                
                oexp=exp;
                
                exp = regexprep(exp, ['(?<![.''a-z0-9A-Z_])' s '(?![.''a-z0-9A-Z_])'], ['vars.' ns]);   %% Namen durch matlab variablen ersetzen
                exp = strrep(exp, ['vars.' ns '('], ['vars.' ns '(''' s ''',']);                        %% Wenn mit (, 'name' ergänzen
                exp = regexprep(exp, ['vars.' ns '(?![\(a-zA-Z0-9_])'], ['vars.' ns '(''' s ''')']);    %% Wenn ohne (, ('name') ergänzen
                
                if ~strcmp(oexp,exp)
                    vars.(ns) = h;
                end
            end

            r=eval(exp);
        end
        
        function r = ExecuteToken(obj, name, eq, varargin) 
            %Just a relay function for GetPropVal...
            
            r = obj.GetPropVal(name, eq, varargin{:});
        end
        
        function findPropertySolvers(obj)
            %Finds all Classes beginning with sk_tc_property_ in the same
            %directory as this class
            
            [path,~,~]=fileparts(which(class(obj)));
            f = filesep;
            files = dir([path f  obj.ClassPrefix '*.m']);
            
            n=length(files);
            r = cell(1,n);
            
            for i=1:n
                name = files(i).name;
                part = regexpi(name, [obj.ClassPrefix '([^.]*).m'], 'tokens'); 
                r{i}=part{1}{1};
            end
            
            obj.PropSolvers = flip(sort(r));
        end
        
        function val = GetPropVal(obj, propertyName, eq, varargin)
            %Constructs an object by the suffix of the classname, sets conditions, passes
            %the arguments to the constructer, resolves dependecies.
            %Results are cached and used if the Hash of the input arguments
            %is the same.
            
            neweq = eq.Clone;
            
            %% Überprüfen ob schon im Cache
            hash = DataHash([{propertyName}, {eq.GetThumb}, varargin]);
            indx = ismember(obj.CalcProp, hash);
            
            if any(indx)   %Schon berechnet!
               val = obj.CalcVals{indx};
               return;
            end
            
            %% Objekt erstellen
            property = obj.getObj(propertyName, varargin);
            
            if ~isa(property, 'sk_tc_property')
                error('Class %s is not of type "sk_tc_property"!', property);
            end

            
            %% Bedingungen setzen wenn vorhanden und SetBefore==1
            % t=temperature, c=conditions, p=pressure, n=moles, h=phase
            setvars = property.SetBefore;
            if setvars == 1
                setvars = 'tpnch';
            elseif ~ischar(setvars)
                setvars = '';
            end
            
            for i=1:numel(varargin)
                io = varargin{i};
                if ~isa(io,'sk_tc_prop_result')
                    continue;
                end
                
                switch io.type
                    case 1
                        if contains(setvars, 't')
                            if strcmpi(io.unit, 'K')
                                neweq.SetCondition('t', io.value);
                            elseif strcmpi(io.unit, 'C')
                                neweq.SetCondition('t', io.value+273.15);
                            end
                        end
                    case 2
                        if contains(setvars, 'c')
                            syscond = eq.GetSystemConditions;
                            neweq.DeleteCondition('*');
                            neweq.SetConditions(syscond);
                            neweq.SetConditions(io.value);
                        end
                    case 4
                        if contains(setvars, 'h')
                            syscond = eq.GetLocalConditions(io.value);
                            neweq.DeleteCondition('*');
                            neweq.SetConditions(syscond);
                        end
                    case 8
                        if contains(setvars, 'p')
                            neweq.SetCondition('p', io.value);
                        end
                    case 9
                        if contains(setvars, 'n')
                            neweq.SetCondition('n', io.value);
                        end
                    case 11
                        neweq = io.value;
                    otherwise
                        continue;
                end
            end
            
            
            %% Abhängigkeiten auflösen
            nd=numel(property.DependsOn);
            deps = cell(1,nd);
            
            for j=1:nd
                dep = property.DependsOn{j};
                try
                    d = obj.ParseExpression(neweq.Clone, dep, varargin{:});
                catch
                    d = nan;
                end
                if (isnumeric(d) && isnan(d)) || (iscell(d) && isnumeric(d{1}) && isnan(d{1}))
                    val = nan;
                    return;
                end
                deps{j} = d;
            end
            
            %% Wert berechnen
            val = property.calculate(obj, neweq.Clone, deps);
            
            if ~isempty(varargin)
                infos = cell(size(varargin));
                for i=1:numel(varargin)
                    c=varargin{i};
                    if isa(c, 'sk_tc_prop_result')
                        infos{i} = c.tostring;
                    elseif isnumeric(c)
                        infos{i} = sprintf('%g', c);
                    elseif ischar(c)
                        infos{i} = c;
                    else
                        try
                            infos{i} = char(c);
                        catch
                            infos{i} = '...';
                        end
                    end
                end
                
                s = sprintf('\t%s(%s)', propertyName, strjoin(infos,','));
            else
                s = sprintf('\t%s', propertyName);
            end
            
            fprintf(sk_tool_padstr(s, 35));
            
            try
                fprintf('= %s\n',val.tostring);
            catch
                fprintf('= ...\n');
            end
            
            obj.CalcProp=[obj.CalcProp {hash}];
            obj.CalcVals=[obj.CalcVals {val}];
        end
        
        function o = getObj(obj, name, varargin)
            fn = [obj.ClassPrefix name];
                        
            for i=1:numel(obj.Objects)
                if strcmpi(class(obj.Objects{i}), fn)
                    o=obj.Objects{i};
                    return;
                end
            end
            if exist(fn,'class')==0
                error('function %s does not exist', fn);
            end
            try
                oc = str2func(fn);
            catch
                error('function %s does not exist', fn);
            end
            if isempty(varargin)
                o=oc();
            else
                o=oc(varargin{:});
            end
        end
    end

    methods (Static)
        function res = get(TCEQ, Properties, varargin)
            %get the properties of a given equilibrium.
            %get(EQ, Properties, [Objects])
            %Objects can be a set of initialized solvers to set advanced
            %options for them
            
            [objects] = sk_tool_parse_varargin(varargin, {});
            if ~iscell(objects)
                objects = {objects};
            end
            if ~iscell(Properties)
                Properties = {Properties};
            end
            slv = sk_func_tc_properties(TCEQ);
            slv.Properties = Properties;
            slv.Objects=objects;
            res = slv.calculate({},[]);
        end
    end
end