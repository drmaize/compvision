%Given a segmented cells image, and the row, column, and depth of the
%penetrations

%Output statistics in a structure such as average size of cells and
%distance to penetrations
function [ cell_fun_result ] = quantifyCellsNearPenetrations(cells_image, r_pen,c_pen,z_pen )

%Make cells white and boundaries black
cells_image = ~cells_image; 

%Remove small noise
cells_image_preprocessed = bwpropfilt(cells_image, 'Area', [20, 10000], 4);

mask_radius = 65; %25um

mask = zeros(size(cells_image_preprocessed));

%Locate penetration events on the surface
pens_inds = sub2ind(size(cells_image_preprocessed), r_pen, c_pen);
mask(pens_inds) = 1;

%Mask a radius around each penetration event
mask = bwdist(mask) < mask_radius;

%Find connected groups of pixels as cells
cc_whole_image = bwconncomp(cells_image_preprocessed,4);

%Update mask from simple pixel-based radius around a pixel to include any cells within
%that radius
%That is -- don't cut off half a cell, this will mess up area/size/distance
%calculations
L = labelmatrix(cc_whole_image);
L_masked = double(mask).*double(L); 
L_masked_labels = unique(L_masked); L_masked_labels(L_masked_labels==0)=[];
cells_image_preprocessed_masked = zeros(size(L));
for ii = 1:length(L_masked_labels)
    cells_image_preprocessed_masked = cells_image_preprocessed_masked | (L == L_masked_labels(ii));
end
mask = imfill(cells_image_preprocessed_masked,'holes');


cc_masked = bwconncomp(cells_image_preprocessed_masked,4);

%Compute statistics on the radially masked image and the original segmented
%image
stats_whole_image = regionprops(cc_whole_image, 'Centroid', 'Eccentricity', 'Area', 'MajorAxisLength', 'MinorAxisLength');
stats_masked = regionprops(cc_masked, 'Centroid', 'Eccentricity', 'Area', 'MajorAxisLength', 'MinorAxisLength');
centroids = zeros(length(stats_whole_image),2);
for jj = 1:length(stats_whole_image)
    centroids(jj,:) = stats_whole_image(jj).Centroid; %x, y
end
%Compute statistics based on the centroids of the cells
centroids = round(centroids);
centroid_mask = zeros(size(cells_image_preprocessed_masked));
centroid_inds = sub2ind(size(centroid_mask), centroids(:,2), centroids(:,1));
centroid_mask(centroid_inds) = 1;
centroids_d = bwdist(centroid_mask);
centroids_d_masked = centroids_d.*mask;

%%%too slow for whole image
% cell_densities = zeros(size(cells_image));
% for ii = 1:size(cells_image, 1)
%     for jj = 1:size(cells_image,2)
%         mask_density = zeros(size(cells_image)); mask_density(ii,jj) = 1;
%         mask_density = bwdist(mask_density) < mask_radius;
%         L_local = double(L).*double(mask_density);
%         cell_densities(ii,jj) = length(unique(L_local)-1)/mask_radius;
%     end
% end

%Compute how many cells are around each penetration within a radius -- cell density
cell_densities = zeros(size(pens_inds));
for jj = 1:size(pens_inds)
    mask_density = zeros(size(cells_image)); mask_density(pens_inds(jj)) = 1;
    mask_density = bwdist(mask_density) < mask_radius;
    L_local = double(L).*double(mask_density);
    cell_densities(jj) = length(unique(L_local)-1)/mask_radius;
end


%Compute averages and for all these metrics
avg_cell_densities_penetrations = mean(cell_densities);

avg_d_to_centroids = mean(centroids_d(centroids_d > 0));
dists_to_centroids_penetrations = centroids_d(pens_inds);
avg_d_to_centroids_penetration = mean(dists_to_centroids_penetrations);

dists_to_cell_boundary = bwdist(~cells_image);
avg_d_to_cell_boundary = mean(dists_to_cell_boundary(dists_to_cell_boundary > 0));
dists_to_cell_boundary_penetrations = dists_to_cell_boundary(pens_inds);
avg_d_to_cell_boundary_penetration = mean(dists_to_cell_boundary_penetrations);


whole_image_cell_area_mean = mean([stats_whole_image.Area]);
whole_image_cell_major_axis = mean([stats_whole_image.MajorAxisLength]);
whole_image_cell_minor_axis = mean([stats_whole_image.MinorAxisLength]);
near_penetrations_cell_area_mean = mean([stats_masked.Area]);
near_penetrations_cell_major_axis = mean([stats_masked.MajorAxisLength]);
near_penetrations_cell_minor_axis = mean([stats_masked.MinorAxisLength]);

whole_image_cell_eccentricity_mean = mean([stats_whole_image.Eccentricity]);
near_penetrations_cell_eccentricity_mean = mean([stats_masked.Eccentricity]);

cell_fun_result.avg_cell_densities_penetrations = avg_cell_densities_penetrations;

%Store the results in the structure and scale by the pixel->um scaling
cell_fun_result.avg_d_to_centroids = avg_d_to_centroids*2.6;
cell_fun_result.dists_to_centroids_penetrations = dists_to_centroids_penetrations*2.6;
cell_fun_result.avg_d_to_centroids_penetration = avg_d_to_centroids_penetration*2.6;
cell_fun_result.avg_d_to_cell_boundary = avg_d_to_cell_boundary*2.6;
cell_fun_result.dists_to_cell_boundary_penetrations = dists_to_cell_boundary_penetrations*2.6;
cell_fun_result.avg_d_to_cell_boundary_penetration = avg_d_to_cell_boundary_penetration*2.6;
cell_fun_result.whole_image_cell_area_mean = whole_image_cell_area_mean*6.76;
cell_fun_result.whole_image_cell_major_axis = whole_image_cell_major_axis*2.6;
cell_fun_result.whole_image_cell_minor_axis = whole_image_cell_minor_axis*2.6;
cell_fun_result.near_penetrations_cell_area_mean = near_penetrations_cell_area_mean*6.76;
cell_fun_result.whole_image_cell_eccentricity_mean = whole_image_cell_eccentricity_mean;
cell_fun_result.near_penetrations_cell_eccentricity_mean = near_penetrations_cell_eccentricity_mean;
cell_fun_result.near_penetrations_cell_major_axis_mean = near_penetrations_cell_major_axis*2.6;
cell_fun_result.near_penetrations_cell_minor_axis_mean = near_penetrations_cell_minor_axis*2.6;



end

