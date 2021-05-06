function [avg_branch_length,num_branches,max_branch_length, num_triples, num_quads] = analyzeSkeleton(skeleton, scale)
% Turns the skeleton into a graph and analyze the features of the graph
% such as branch lengths, amount of branching, etc. 
[adjacency,nodes,edges] = Skel2Graph3D(skeleton,0);

num_branches = size(edges, 2);
branch_lengths = zeros(num_branches, 1);

%To calculate the length of a branch in um
%a straight line needs to be calculated between centers of neighboring
%points in each branch. 
%a^2 + b^2 + c^2 = d^2
for ii = 1:num_branches
    voxels = edges(ii).point;
    if(length(voxels) < 5)
       continue; 
    end
    branch_length = 0;
    for jj = 2:length(voxels)
        prev_idx = voxels(jj-1);
        [prev_r, prev_c,prev_z] = ind2sub(size(skeleton), prev_idx );
        curr_idx = voxels(jj);
        [curr_r, curr_c, curr_z] = ind2sub(size(skeleton), curr_idx);
        
        branch_length = branch_length + sqrt( (scale(1)*(curr_c - prev_c)).^2 + ...
            (scale(2)*(curr_r - prev_r)).^2  + ...
            (scale(3)*(curr_z - prev_z)).^2); 
    end
    branch_lengths(ii) = branch_length;
end

branch_lengths(branch_lengths < 1) = [];
max_branch_length = max(branch_lengths);
avg_branch_length = mean(branch_lengths);

conns = cellfun(@length, {nodes.conn}); 
num_triples = length(find(conns == 3));
num_quads = length(find(conns == 4));

end

