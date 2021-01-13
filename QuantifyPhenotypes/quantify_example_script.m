%Script showing how to run the code

clear; close all; clc;

base_path = './e013SLBp03wA1x20_1505041720rf001/';
fungus_name = 'fungus.tif';
surface_name = 'surface.txt';
cell_name = 'cells.png';
stomates_name = 'stomates.png';

%Read in the skeleton, surface map, cell segmentation, and stomates
%segmentation
skeleton = logical(readTiffStack([base_path fungus_name]));
surface_map = readSurfaceMap([base_path surface_name]);
cells_image = logical(imread([base_path cell_name]));
stomates_image = logical(imread([base_path stomates_name]));

%Crop so that all are the same size
%Note surface image and fungus is larger, but cropped in the top left corner matches
%the other images
%This is an artifact of the deep learning we did
skeleton = skeleton(1:size(cells_image,1), 1:size(cells_image,2), :);
surface_map = surface_map(1:size(cells_image,1), 1:size(cells_image,2));
cells_image = cells_image(1:size(cells_image,1), 1:size(cells_image,2));
stomates_image = stomates_image(1:size(cells_image,1), 1:size(cells_image,2));

cells_image = cells_image | stomates_image;

%Find the fungal penetrations
[r_pen,c_pen,z_pen] = findSurfacePenetrations(skeleton, surface_map, 6);
visualizeSkeleton( skeleton , 'r.' ); hold on; plot3(c_pen, r_pen, z_pen, 'gx', 'MarkerSize', 50, 'LineWidth', 3);
% surf(surface_map, 'FaceLighting', 'none', 'EdgeColor', [0 0 1]); camup([0 0 -1]);

%Quantify stomata and cell numbers
quantifyStomataNearPenetrations(stomates_image, r_pen, c_pen, z_pen);
quantifyCellsNearPenetrations(cells_image, r_pen, c_pen, z_pen);