%Given a segmented cells image, and the row, column, and depth of the
%penetrations

%Output statistics in a structure such as average size of cells and
%distance to penetrations
function [ cell_table ] = quantifyCells(cells_image, scale )

%Make cells white and boundaries black
cells_image = ~cells_image; 

%Remove small noise
cells_image_preprocessed = bwpropfilt(cells_image, 'Area', [20, 10000], 4);

%Find connected groups of pixels as cells
CC = bwconncomp(cells_image_preprocessed,4);
stats = regionprops(CC, 'Centroid', 'Eccentricity', 'Area', 'MajorAxisLength', 'MinorAxisLength', 'BoundingBox');

ids = zeros(CC.NumObjects, 1);
centroidsx = zeros(CC.NumObjects, 1);
centroidsy = zeros(CC.NumObjects, 1);
widths = zeros(CC.NumObjects, 1);
heights = zeros(CC.NumObjects, 1);
areas = zeros(CC.NumObjects, 1);
eccentricities = zeros(CC.NumObjects, 1);


for ii = 1:CC.NumObjects
    ids(ii) = ii;
    centroidsx(ii) = round(stats(ii).Centroid(1));
    centroidsy(ii) = round(stats(ii).Centroid(2));
    widths(ii) = round(stats(ii).MajorAxisLength/scale(1));
    heights(ii) = round(stats(ii).MinorAxisLength/scale(2));
    areas(ii) = widths(ii)*heights(ii)*pi;
    eccentricities(ii) = stats(ii).Eccentricity; 
end

cell_table = table(ids, centroidsx, centroidsy, widths, heights, areas, eccentricities);
cell_table.Properties.VariableNames = {'CellID' 'Centroid_X' 'Centroid_Y' 'Width_um' 'Height_um', 'Area_um2', 'Eccentricity' };
end

