%Function that takes in a 3D binary skeleton volume and a surface map
%image, along with a penetration threshold as a number of slices

%Outputs a list of row,col,Z of penetrations
%Along with the depth, breadth, and voxel volumn of those networks

function [fungus_table, r_pen, c_pen, z_pen, depths, breadths, volumes, mip ] = QuanitfyFungus( skeleton, surface_map, penetration_thresh,scale )
%Penetration Thresh = number of slices down the fungus must go to be
%considered an event
ids = [];
r_pen = [];
c_pen = [];
z_pen = [];
depths = [];
z_pen_from_surface = [];
avg_branch_lengths = [];
num_brancheses = [];
max_branch_lengths = [];
breadths = [];
volumes = [];
num_tripleses = [];
num_quadses = [];

skeleton = logical(skeleton);
skeleton2 = zeros(size(skeleton));
%Compute connected networks (groups of voxel that all touch eachother)
CC = bwconncomp(skeleton, 26);
flags = zeros(1, length(CC.PixelIdxList)); 

curr_id = 1;
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
        ids = [ids; curr_id];
        r_pen = [r_pen; r(mind)];
        c_pen = [c_pen; c(mind)];
        z_pen = [z_pen; z(mind)];
        
        depths = [depths; scale(3)*abs(min(diff))];
        breadths = [breadths; max(scale(1)*abs(max(r) - min(r)), scale(2)*abs(max(c) - min(c)))];
        volumes = [volumes; scale(1)*scale(2)*scale(3)*length(z)]; %2.6*2.6*1.2
        
        %Turn the network into a graph and analyze the graph (branch
        %lengths, number of branches, etc)
        skeleton_tmp = zeros(size(skeleton)); 
        skeleton_tmp(voxels) = 1;
        [avg_branch_length,num_branches,max_branch_length,  num_triples, num_quads] = analyzeSkeleton(skeleton_tmp, scale);
        avg_branch_lengths = [avg_branch_lengths; avg_branch_length ];
        num_brancheses = [num_brancheses; num_branches];
        max_branch_lengths = [max_branch_lengths; max_branch_length];
        num_tripleses = [num_tripleses; num_triples];
        num_quadses = [num_quadses; num_quads];
        
        
        curr_id = curr_id + 1;
    end
end

for ii = 1:length(CC.PixelIdxList)
   if(flags(ii) == 1) 
      skeleton2( CC.PixelIdxList{ii}) = 1;
   end
end
mip = max(skeleton2, [], 3);


fungus_table = table(ids, c_pen, r_pen, z_pen, depths, breadths, volumes, avg_branch_lengths, num_brancheses, max_branch_lengths, num_tripleses, num_quadses);
fungus_table.Properties.VariableNames = {'FungalHyphaeID' 'Penetration_X' 'Penetration_Y' 'Penetration_Z' 'Depth_um', 'Breadth_um', 'Volume_um3' 'Avg_Branch_Length_um' 'Num_Branches' 'Max_Branch_Length' 'Num_Triples' 'Num_Quads'};

end

