%Function that takes in a 3D binary skeleton volume, binary segmented volume, and a surface map
%image, along with a penetration threshold as a number of slices

%Outputs a list of row,col,Z of penetrations
%Along with the depth, breadth, and voxel volumn of those networks

function [fungus_table, r_pen, c_pen, z_pen, depths, breadths, volumes, mip ] = QuanitfyFungus( skeleton, fungus_seg, surface_map, penetration_thresh,scale )
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
surface_areas = [];
mip_areas = [];
surface_only_areas = [];
num_tripleses = [];
num_quadses = [];
num_terminals = [];

skeleton = bwareaopen(skeleton,50);
skeleton = logical(skeleton);
fungus_seg = logical(fungus_seg);
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
    else
        ids = [ids; curr_id];
        r_pen = [r_pen; -1];
        c_pen = [c_pen; -1];
        z_pen = [z_pen; -1]; 
    end
        depths = [depths; scale(3)*abs(min(diff))];
        breadths = [breadths; max(scale(1)*abs(max(r) - min(r)), scale(2)*abs(max(c) - min(c)))];
        volumes = [volumes; scale(1)*scale(2)*scale(3)*length(z)]; %2.6*2.6*1.2
        
        %Turn the network into a graph and analyze the graph (branch
        %lengths, number of branches, etc)
        skeleton_tmp = zeros(size(skeleton)); 
        skeleton_tmp(voxels) = 1;
        skeleton_tmp = skeleton_tmp(min(r):max(r), min(c):max(c), min(z):max(z));
        [avg_branch_length,num_branches,max_branch_length,  num_triples, num_quads, num_terminal] = analyzeSkeleton(skeleton_tmp, scale);
        avg_branch_lengths = [avg_branch_lengths; avg_branch_length ];
        num_brancheses = [num_brancheses; num_branches];
        max_branch_lengths = [max_branch_lengths; max_branch_length];
        num_tripleses = [num_tripleses; num_triples];
        num_quadses = [num_quadses; num_quads];
        num_terminals = [num_terminals; num_terminal];
        
        %Calculate area of the network on the surface (both MIP-wise and
        %actual spread above surface
        
        %Calculate which part of the segmented image belongs to the current
        %skeletonized network
        fungus_seg_tmp = zeros(size(fungus_seg));
        min_r = max(1, round(min(r)-size(fungus_seg,1)/20));
        max_r = min(size(fungus_seg,1), round(max(r)+size(fungus_seg,1)/20));
        min_c = max(1, round(min(c)-size(fungus_seg,2)/20));
        max_c = min(size(fungus_seg,1), round(max(c)+size(fungus_seg,2)/20));
        min_z = max(1, round(min(z)-size(fungus_seg,3)/20));
        max_z = min(size(fungus_seg,1), round(max(z)+size(fungus_seg,3)/20));
        fungus_seg_tmp(min_r:max_r, min_c:max_c, min_z:max_z) = fungus_seg(min_r:max_r, min_c:max_c, min_z:max_z);
        
        %Calculate MIP area of the segmented,non-skeleton fungus
        fungus_seg_mip = max(fungus_seg_tmp, [], 3);
        mip_area = length(find(fungus_seg_mip)).*scale(1).*scale(2);
        mip_areas = [mip_areas; mip_area];
       
        
        %Calculate actual area of the segmented,non-skeleton fungus above
        %surface
        voxels = find(fungus_seg_tmp);
        [r, c, z] = ind2sub(size(fungus_seg_tmp), voxels);
        surface_pixels_inds = sub2ind(size(surface_map), r,c);
        surface_zs = surface_map(surface_pixels_inds);
        diff = surface_zs - z;
        surface_area = length(find(diff>=0)).*scale(1).*scale(2);
        surface_areas = [surface_areas; surface_area];
        
        curr_id = curr_id + 1;
end

for ii = 1:length(CC.PixelIdxList)
   if(flags(ii) == 1) 
      skeleton2( CC.PixelIdxList{ii}) = 1;
   end
end
mip = max(skeleton2, [], 3);


fungus_table = table(ids, c_pen, r_pen, z_pen, depths, breadths, volumes, avg_branch_lengths, num_brancheses, max_branch_lengths, num_tripleses, num_quadses, num_terminals, surface_areas, mip_areas);
fungus_table.Properties.VariableNames = {'FungalHyphaeID' 'Penetration_X' 'Penetration_Y' 'Penetration_Z' 'Depth_um', 'Breadth_um', 'Volume_um3' 'Avg_Branch_Length_um' 'Num_Branches' 'Max_Branch_Length' 'Num_Triples' 'Num_Quads' 'Num_Terminal' 'Above_Surface_Area_um2' 'MIP_Area_um2'};

end

