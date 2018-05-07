function [ h ] = sk_tool_plot3d_scatter( M, varargin )
    if istable(M)
        n=M.Properties.VariableNames;
        lx=n{1};
        ly=n{2};
        lz=n{3};
        M=table2array(M);
    else
        lx='X';
        lx='Y';
        lx='Z';
    end

    x=M(:,1);
    y=M(:,2);
    z=M(:,3);

    tri = delaunay(x,y);
    plot(x,y,'.')

    if size(M,2)==4
        h = trisurf(tri, x, y, z, M(:,4),varargin{:});
    else
        h = trisurf(tri, x, y, z,varargin{:});
    end
    
    xlabel(lx);
    ylabel(ly);
    zlabel(lz);
    
    axis vis3d
end

