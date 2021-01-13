%Given a segmented stomata image, and the row, column, and depth of the
%penetrations

%Output statistics in a structure such as average distance betwen stomata
%and penetrations
function [ stomate_results ] = quantifyStomataNearPenetrations(stomata_image, r_pen,c_pen,z_pen )

%Filter out small noise
stomata_image_preprocessed = bwpropfilt(stomata_image, 'Area', [15, 200], 8);

%Compute connected components
CC = bwconncomp(stomata_image_preprocessed);

%Find locations of the penetrations on the surface
pens_inds = sub2ind(size(stomata_image_preprocessed), r_pen, c_pen);

%Distance from every pixel to nearest stomata
dists_to_stomata = bwdist(stomata_image_preprocessed);

%Average distance between stomata
avg_d_to_stomata = mean(dists_to_stomata(dists_to_stomata > 0));

%Distance from all penetrations to stomata
dists_to_stomata_penetrations = dists_to_stomata(pens_inds);

%Average distance from penetrations to stomata
avg_d_to_stomata_penetrations = mean(dists_to_stomata_penetrations);

%Store the result and scale correctly: 2.6x2.6 in x,y 
stomate_results.avg_d_to_stomata = avg_d_to_stomata*2.6;
stomate_results.dists_to_stomata_penetrations = dists_to_stomata_penetrations*2.6;
stomate_results.avg_d_to_stomata_penetrations = avg_d_to_stomata_penetrations*2.6;
stomate_results.num_stomates = CC.NumObjects;

end

