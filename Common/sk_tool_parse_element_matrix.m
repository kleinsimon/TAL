function [ElmNames, ElmContents] = sk_tool_parse_element_matrix
%sk_tool_parse_element_matrix Reads a bunch of CSV files and puts them into an array 
%of m x n matrices. All Files must contain the same amount of lines and rows.
%   ElmNames:       Filenames without expansion
%   ElmContents:    Raw Data from File as m x n Matrices

    [FileNames,PathName,~] = uigetfile({'*.txt','Text Files' },...
        'Select Element Matrix Files (ASCII)','MultiSelect','on');         
    if isequal(FileNames,0)
        error('User selected Cancel');
    end
    
    if not(iscell(FileNames))
       FileNames={FileNames}; 
    end
    
    ElmContents = {};
    ElmNames = {};
    
    for i=1:length(FileNames)
        ElmContents{i} = csvread(fullfile(PathName, FileNames{i}));
        [~,ElmNames{i},~] = fileparts(FileNames{i});
    end
    [m,n] = size(ElmContents{1});
    fprintf('Read %d matrices with %dx%d fields\n',length(FileNames),m,n);

end
