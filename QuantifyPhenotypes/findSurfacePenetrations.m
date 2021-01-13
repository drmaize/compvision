%Function that takes in a 3D binary skeleton volume and a surface map
%image, along with a penetration threshold as a number of slices

%Outputs a list of row,col,Z of penetrations
%Along with the depth, breadth, and voxel volumn of those networks

function [ r_pen, c_pen, z_pen, depths, breadths, volumes, mip ] = findSurfacePenetrations( skeleton, surface_map, penetration_thresh )
%Penetration Thresh = number of slices down the fungus must go to be
%considered an event
r_pen = [];
c_pen = [];
z_pen = [];
depths = [];
breadths = [];
volumes = [];

skeleton = logical(skeleton);
skeleton2 = zeros(size(skeleton));
%Compute connected networks (groups of voxel that all touch eachother)
CC = bwconncomp(skeleton, 26);
flags = zeros(1, length(CC.PixelIdxList)); 

%For each connected network
for ii = 1:length(CC.PixelIdxList)
    voxels = CC.PixelIdxList{ii};
    %Calculate the distance from each voxel in network to surface (straight
    %up) 
    [r, c, z] = ind2sub(size(skeleton), voxels);
    surface_pixels_inds = sub2ind(size(surface_map), r,c);
    surface_zs = surface_map(surface_pixels_inds);
    diff = surface_zs - z;
    %If the network has voxels both at/above surface and below, and exceeds the penetration threshold 
    if(max(diff) > 0 && min(diff) < 0 && abs(min(diff)) > penetration_thresh)
        %Calculate the penetration point (voxel closes to the surface)
        %And add it to the list 
        %Also calculate depth and breadth of the network for good measure
        flags(ii) = 1;
        [mn,mind] = min(abs(diff));
        mn = mn(1); mind = mind(1);
        r_pen = [r_pen; r(mind)];
        c_pen = [c_pen; c(mind)];
        z_pen = [z_pen; z(mind)];
        depths = [depths; 1.2*abs(min(diff))];
        breadths = [breadths; 2.6*max(abs(max(r) - min(r)), abs(max(c) - min(c)))];
        volumes = [volumes; 8.112*length(z)]; %2.6*2.6*1.2
    end
end

for ii = 1:length(CC.PixelIdxList)
   if(flags(ii) == 1) 
      skeleton2( CC.PixelIdxList{ii}) = 1;
   end
end
mip = max(skeleton2, [], 3);

end

