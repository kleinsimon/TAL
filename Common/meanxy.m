function [ XYmean, STdevs ] = meanxy( XY, classes, range )
%[ XYmean, STdevs ] = meanxy( XY, classes, range )
%   Calculates the mean and std of one X (first Column) and all following
%   Columns. Rows are classified matching the given classes and a range.
%
%   XY:         Matrix with at least one X-Column or one X and multiple Y- Columns
%   classes:    Vector of numbers, which represent the center of valid ranges
%   range:      Either a scalar or a vector with ranges around which the
%               classes are matched

    if classes ~= sort(classes)
        error("Classes must be ascending");
    end
    
    nc = numel(classes);
    
    XYmean = nan(nc, size(XY,2));
    STdevs = XYmean;
    
    if numel(range)==1
        range = ones(nc,1)*range;
    end
    
    for i=1:nc
        tmp = XY(abs(classes(i) - XY(:,1)) <= range(i),:);
        XYmean(i,:) = mean(tmp);
        STdevs(i,:) = std(tmp);
    end
end

