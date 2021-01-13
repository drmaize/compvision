%Script to generate figures
%Really just copy pasted from the quantify all files script, and displays
%figures instead of outputting a table

clear; clc; close all;
addpath(genpath('skeleton_connect_code'));
addpath(genpath('../'));


%Change these paths as needed
%This was absolute path for DrMaize as mounted on my system
dir_cells = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\cell_seg_processed\';
dir_fungus = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\thresholded_skeleton_connected\';
dir_surface = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\surfacemap\';
dir_stomates = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\stomate_seg_processed\';
dir_output = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\quantified_numbers\';
files = dir([dir_cells '*image1_*.png']);

 B.textdata = {'exp', 'dis', 'plate', 'plate_row', 'plate_col', 'timestamp', ...
        'num_pens', 'avg_fun_depths', 'avg_fun_breadths', 'avg_fun_volumes',  'avg_cell_density_near_pen',...
        'avg_cell_area_near_pen', 'avg_cell_ecc_near_pen', 'avg_cell_minor_axis_near_pen','avg_cell_major_axis_near_pen' ...
        'avg_um_pen_to_cell_center',  'avg_um_pen_to_cell_boundary', 'avg_um_to_stomata' };
B.colheaders = {'exp', 'dis', 'plate', 'plate_row', 'plate_col', 'timestamp', ...
        'num_pens', 'avg_fun_depths', 'avg_fun_breadths', 'avg_fun_volumes', 'avg_cell_density_near_pen',...
        'avg_cell_area_near_pen', 'avg_cell_ecc_near_pen', 'avg_cell_minor_axis_near_pen','avg_cell_major_axis_near_pen' ...
        'avg_um_pen_to_cell_center',  'avg_um_pen_to_cell_boundary', 'avg_um_to_stomata' };
B.data = cell(length(files)+1, length(B.colheaders));

ii = 80; 
disp([num2str(ii) ' out of ' num2str(length(files))]);

try
    %Load cells
    filename = files(ii).name;
    filename_pre = filename(1:27);
    pth = [dir_cells filename];
    cells_image = imread(pth);
    %Load surface map
    pth_surface = [dir_surface filename_pre '_topsurface_optimized1.txt'];
    [ surface_map ] = readSurfaceMap(pth_surface);
    [ surface_image] = imread([dir_surface filename_pre '_topsurface_image1.png']);
    %Load Stomates
    pth_stomates = [dir_stomates filename_pre '_topsurface_image1.png'];
    stomates_image = imread(pth_stomates);
    %Load fungus
    pth_fun = [dir_fungus filename_pre 'rf001_segmented.tif'];
    [ skeleton ] = readTiffStack(pth_fun);
    skeleton = skeleton(1:2000, 1:2000, :);
    
catch
    disp('CANNOT LOAD SOMETHING');
end
[ r_pen, c_pen, z_pen, depths, breadths, volumes, mip] = findSurfacePenetrations( skeleton, surface_map, 10 );
cells_image_fat = imdilate(cells_image, strel('disk', 1));
mip_adjusted = imdilate(bwmorph(mip, 'skel', Inf), strel('disk', 1));
fungus_image_colored = convertToColor(mip_adjusted, [1 0 0]);
surface_image_colored = convertToColor(double(surface_image(1:2000, 1:2000))/255, [1 1 1]);
cells_image_colored = convertToColor(cells_image_fat, [0 0 1]);
cells_image_colored2 = convertToColor(cells_image_fat, [1 1 1]);
stomates_image_colored = convertToColor(stomates_image, [0 1 0]);
combined_image = cells_image_colored + stomates_image_colored + surface_image_colored ;
combined_image2 = cells_image_colored2 + stomates_image_colored;
combined_image3 = fungus_image_colored + cells_image_colored + stomates_image_colored + surface_image_colored ;
combined_image4 = fungus_image_colored + cells_image_colored2 + stomates_image_colored;
imshow(combined_image, []); hold on; plot(c_pen, r_pen, 'rx', 'MarkerSize', 10, 'LineWidth', 3);
figure; imshow(combined_image2, []); hold on; plot(c_pen, r_pen, 'rx', 'MarkerSize', 10, 'LineWidth', 3);
figure; imshow(combined_image3, []); hold on; plot(c_pen, r_pen, 'rx', 'MarkerSize', 10, 'LineWidth', 3);
figure; imshow(combined_image4, []); hold on; plot(c_pen, r_pen, 'rx', 'MarkerSize', 10, 'LineWidth', 3);