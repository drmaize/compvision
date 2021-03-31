%Tajes a 3D binary skeleton and a matlab plotstr that describes the
%color/marker type and makes a 3D plot

function [  ] = visualizeSkeleton( skeletal ,plotstr )
inds = find(skeletal); 
[r c z] = ind2sub(size(skeletal), inds);
plot3(c, r, z, plotstr);
ax = gca; 
ax.Clipping = 'off';
end

