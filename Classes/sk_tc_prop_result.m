classdef sk_tc_prop_result < handle
    %Represents a result of a sk_tc_property module. 
    %sk_tc_prop_result(name, type, content, unit)
    %Types: 0: None, 1: Temparature, 2: Contents, 3:Content Range, 
    %4: Phase, 5: String, 6: Numeric, 7: Bool, 8: Pressure, 9: System Size,
    %10: Scheil Object
    
    properties
        name = '';
        type = 0;
        value = [];
        unit = '';
    end
    
    methods (Static)
        function prop = getByType(objs, type, varargin)
            %prop = getByType(objs, type, varargin)
            %Types: 0: None, 1: Temparature, 2: Contents, 3:Content Range, 
            %4: Phase, 5: String, 6: Numeric, 7: Bool, 8: Pressure, 9: System Size,
            %10: Scheil Object, 11: Equilibrium object
            
            cast = sk_tool_parse_varargin(varargin, {});
            prop = {};
            prim = {};
            for oi=1:numel(objs)
                o=objs{oi};
                if isempty(o)
                    continue;
                end
                if iscell(o)
                    o=o{1};
                end
                if ~isa(o,'sk_tc_prop_result')
%                     if type == 0
%                         prop{end+1} = o{1};
%                         
%                     end
                    prim{end+1} = o;
                    continue;
                end
                
                if o.type == type
                    prop{end+1} = o;
                    return;
                end
            end
            
            %Look for primitives, for which one of the handles in cast is
            %true, then cast to this type
            for i=1:numel(cast)
                check = cast{i};
                for j=1:numel(prim)
                    o = prim{j};
                    if check(o)
                        prop{end+1} = sk_tc_prop_result('unknown', type, o);
                    end
                end
            end
        end
    end
    
    methods
        function obj=sk_tc_prop_result(varargin)
            [obj.name, obj.type, obj.value, obj.unit] = sk_tool_parse_varargin(varargin, [], [], [], []);
            
            if obj.type == 1 && isempty(obj.unit)
                obj.unit = 'K';
            end
        end
        
        function set.name(obj, val)
            if iscell(val)
                obj.name=val{1};
            else
                obj.name=val;
            end
        end
        
        function s = tostring(obj)
            switch obj.type
                case 0
                    s='';
                case {1 6 7 8 9}
                    s=sprintf('%g %s', obj.value, obj.unit);
                case {4 5}
                    s=obj.value;
                case 2
                    %a = obj.value';
                    %s=sprintf('%s=%g\t', a{:});
                    s=obj.name;
                case 3
                    %a = obj.value{1}';
                    %b = obj.value{2}';
                    %s=[sprintf('%s=%g\t', a{:}) sprintf('\n') sprintf('%s=%g\t', b{:})];
                    s=obj.name;
                case 10
                    s=obj.name;
                case 11
                    s=obj.name;
            end
        end
        
        function d = double(obj)
            d = obj.value;
        end
        
        function c = Clone(obj)
            c = sk_tc_prop_result(obj.name, obj.type, obj.value, obj.unit);
        end
        
        function o = newval(obj, val)
            o = obj.Clone;
            o.value = val;
        end
        
        function b = isNum(obj)
            b = any(obj.type == [1 6 7 8 9]);
        end
        
        %% Operatoren
        
        function r = plus(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a + b);
        end
        
        function r = minus(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a - b);
        end
        
        function r = uminus(obj1)
            a = double(obj1);
            r = obj1.newval(-a);
        end
        
        function r = uplus(obj1)
            a = double(obj1);
            r = obj1.newval(+a);
        end
        
        function r = times(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj2.newval(a .* b);
        end
        
        function r = mtimes(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a * b);
        end
        
        function r = rdivide(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a ./ b);
        end
        
        function r = ldivide(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a .\ b);
        end
        
        function r = mrdivide(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a / b);
        end
        
        function r = mldivide(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a \ b);
        end
        
        function r = power(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a .^ b);
        end
        
        function r = mpower(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a ^ b);
        end
        
        function r = lt(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a < b);
            r.type=7;
        end
        
        function r = gt(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a > b);
            r.type=7;
        end
        
        function r = le(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a <= b);
            r.type=7;
        end
        
        function r = ge(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a >= b);
            r.type=7;
        end
        
        function r = ne(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a ~= b);
            r.type=7;
        end
        
        function r = eq(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a == b);
            r.type=7;
        end
        
        function r = and(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a & b);
            r.type=7;
        end
        
        function r = or(obj1,obj2)
            a = double(obj1);
            b = double(obj2);
            r = obj1.newval(a | b);
            r.type=7;
        end
        
        function r = not(obj1)
            a = double(obj1);
            r = obj1.newval(~a);
            r.type=7;
        end
        
        function r = colon(varargin)
            if nargin == 3
                a = double(varargin{1});
                d = double(varargin{2});
                b = double(varargin{3});
                r = varargin{1}.newval(a:d:b);
            else
                a = double(varargin{1});
                b = double(varargin{2});
                r = varargin{1}.newval(a:b);
            end
            
            r.type=7;
        end
        
        function r = ctranspose(obj1)
            a = double(obj1);
            r = obj1.newval(a');
        end
        
        function r = transpose(obj1)
            a = double(obj1);
            r = obj1.newval(a.');
        end
        
        function r = horzcat(varargin)
            if varargin{1}.isNum
                a = cellfun(@double, varargin);
                r = a;
            else
                r = varargin;
            end
        end
        
        function r = vertcat(varargin)
            if varargin{1}.isNum
                a = cellfun(@double, varargin);
                r = a';
            else
                r = varargin';
            end
        end
        
        function r = abs(obj1)
            a = double(obj1);
            r = obj1.newval(abs(a));
        end
        
        function r = sum(obj1, dim)
            a = double(obj1);
            r = obj1.newval(sum(a,dim));
        end
        
        function r = mean(obj1)
            a = double(obj1);
            r = obj1.newval(mean(a));
        end
    end
end


