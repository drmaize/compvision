%Given a segmented stomata image, and the row, column, and depth of the
%penetrations

%Output statistics in a structure such as average distance betwen stomata
%and penetrations
function [ stomate_table] = quantifyStomata(stomata_image )

%Filter out small noise
stomata_image_preprocessed = bwpropfilt(stomata_image, 'Area', [15, 200], 8);

%Compute connected components
CC = bwconncomp(stomata_image_preprocessed);
stats = regionprops(CC, 'Centroid');
ids = zeros(CC.NumObjects, 1);
centroidsx = zeros(CC.NumObjects, 1);
centroidsy = zeros(CC.NumObjects, 1);
for ii = 1:CC.NumObjects
    ids(ii) = ii;
    centroidsx(ii,1) = round(stats(ii).Centroid(1));
    centroidsy(ii,1) = round(stats(ii).Centroid(2));
end

stomate_table = table(ids, centroidsx, centroidsy);
stomate_table.Properties.VariableNames = {'StomateID' 'Centroid_X' 'Centroid_Y'};
end

