
%Given the filename of a surface map, read it into a matrix. 
function [ surface_map ] = readSurfaceMap( filename )

surface_map = dlmread(filename);


end

