classdef sk_tc_condition_set < handle
    %sk_tc_condition_set
    
    properties (Access=private)
        StaticConditions;
        DynConditions;
        DynValues;
        DynSize;
        DynNumel;
        Pointer;
    end
    
    methods
        function obj = sk_tc_condition_set(Conditions, Values, varargin)
            %sk_tc_condition_set(Conditions, Values, Static)
            %
            %Stores a Set of Condions.
            %   Conditions:     Cellarray of Strings containing the
            %       Conditions to be altered. One Condition per Value Set.
            %   Values:         Cellarray of Arrays. Each Cell represents
            %      the Value Set for one Condition. All Arrays need to have
            %      the same size and dimension.
            %   Modifier:       Optional: Modifier to add to all Conditions. EG: 'w' or 'x'
            
            if numel(Conditions) ~= numel(Values)
                error('Conditions and Value need to be cellarrays of the same Size');
            end
            
            if ~isempty(varargin)
                obj.StaticConditions = varargin{1};
            end
            
            obj.DynSize = size(Values{1});
            obj.DynNumel = numel(Values{1});
            obj.DynValues = Values;
            obj.DynConditions = Conditions;
            obj.Pointer = 1;
        end
        
        function s = GetConditions(obj, index)
            %Conditions = GetConditions(index)
            %
            %Returns the Conditions in the location of index
            %   index:      Array of the indices to look up, eg. [x,y].
            %       The length must match the dimension of the values.
            %   Conditions: Cellarray with two columns. The Conditions are
            %       in the first, the corresponding value in the second.
            
            ind = num2cell(index);
            
            if numel(index) ~= numel(obj.DynSize) && numel(index) > 1
                error('Dimension of index is %d, must match that of values: %d', numel(index), numel(obj.DynSize));
            end
            
            nd = numel(obj.DynConditions);
            %ns = numel(obj.StaticConditions);
            
            s = cell(nd, 2);
            
            s(:,1)=obj.DynConditions';
            
            for i=1:nd
                s{i,2} = obj.DynValues{i}(ind{:});
            end
            
            s = [obj.StaticConditions ; s];
        end
        
        function Reset(obj)
            %Resets the Pointer
            
            obj.Pointer = 1;
        end
        
        function s = GetNextCondition(obj, varargin)
            %Condtitions = GetNextCondition([Index])
            %
            %Returns the next set of conditions, incrementing the pointer by 1 and
            %starting at the first one. If Index is given, the Pointer is
            %fist set to this value. 
            %If pointer exceeds the dataset, 0 is returned.
            
            if ~isempty(varargin)
                obj.Pointer = varargin{1};
            end
            
            if obj.Pointer > obj.DynNumel
                s = 0;
                return;
            end
            
            s = obj.GetConditions(obj.Pointer);
            obj.Pointer = obj.Pointer + 1;
        end
    end
end

