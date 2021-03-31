%Script to run on Dr Maize exp13

%I mounted Dr Maize on my windows as the Z drive, so this will not work on
%your system probably.

%Assumes the segmentation has already been performed and stored. 
%Will write an excel table

clear; clc; close all;
addpath(genpath('skeleton_connect_code'));
addpath(genpath('../'));

%Change if needed
dir_cells = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\cell_seg_processed\';
dir_fungus = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\thresholded_skeleton_connected\';
dir_surface = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\surfacemap\';
dir_stomates = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\stomate_seg_processed\';
dir_output = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\quantified_numbers\';
files = dir([dir_cells '*image1_*.png']);

%This is the format of the resulting table
B.textdata = {'exp', 'dis', 'plate', 'plate_row', 'plate_col', 'timestamp', ...
        'num_pens', 'avg_fun_depths', 'avg_fun_breadths', 'avg_fun_volumes',  'avg_cell_density_near_pen',...
        'avg_cell_area_near_pen', 'avg_cell_ecc_near_pen', 'avg_cell_minor_axis_near_pen','avg_cell_major_axis_near_pen' ...
        'avg_um_pen_to_cell_center',  'avg_um_pen_to_cell_boundary', 'avg_um_to_stomata',  'avg_cell_area', 'avg_cell_minor_axis', 'avg_cell_major_axis', 'avg_stomates'  };
B.colheaders = {'exp', 'dis', 'plate', 'plate_row', 'plate_col', 'timestamp', ...
        'num_pens', 'avg_fun_depths', 'avg_fun_breadths', 'avg_fun_volumes', 'avg_cell_density_near_pen',...
        'avg_cell_area_near_pen', 'avg_cell_ecc_near_pen', 'avg_cell_minor_axis_near_pen','avg_cell_major_axis_near_pen' ...
        'avg_um_pen_to_cell_center',  'avg_um_pen_to_cell_boundary', 'avg_um_to_stomata', 'avg_cell_area', 'avg_cell_minor_axis', 'avg_cell_major_axis', 'avg_stomates' };
B.data = cell(length(files)+1, length(B.colheaders));

for ii = 1:length(files)
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
       disp('CANNOT LOAD SOMETHING! BAD!');
       continue;
    end
    [ r_pen, c_pen, z_pen, depths, breadths, volumes ] = findSurfacePenetrations( skeleton, surface_map, 10 );
    [ cell_fung_results ] = quantifyCellsNearPenetrations(cells_image, r_pen,c_pen,z_pen )
    [ stomates_fung_results ] = quantifyStomataNearPenetrations(stomates_image, r_pen,c_pen,z_pen )
    
    %Write to table
    exp = filename(1:4);
    dis = filename(5:7);
    plate = filename(9:10);
    plate_row = filename(12);
    plate_col = filename(13);
    timestamp = filename(18:27);
   
    B.data(ii,1) = {exp};
    B.data(ii,2) = {dis};
    B.data(ii,3) = {plate};
    B.data(ii,4) = {plate_row};
    B.data(ii,5) = {plate_col};
    B.data(ii,6) = {timestamp};
    B.data(ii,7) = {length(z_pen)};
    B.data(ii,8) = {mean(depths)};
    B.data(ii,9) = {mean(breadths)};
    B.data(ii,10) = {mean(volumes)};
    B.data(ii,11) = {cell_fung_results.avg_cell_densities_penetrations};
    B.data(ii,12) = {cell_fung_results.near_penetrations_cell_area_mean};
    B.data(ii,13) = {cell_fung_results.near_penetrations_cell_eccentricity_mean};
    B.data(ii,14) = {cell_fung_results.near_penetrations_cell_minor_axis_mean};
    B.data(ii,15) = {cell_fung_results.near_penetrations_cell_major_axis_mean};
    B.data(ii,16) = {cell_fung_results.avg_d_to_centroids_penetration};
    B.data(ii,17) = {cell_fung_results.avg_d_to_cell_boundary_penetration};
    B.data(ii,18) = {stomates_fung_results.avg_d_to_stomata_penetrations};
    B.data(ii,19) = {cell_fung_results.whole_image_cell_area_mean};
    B.data(ii,20) = {cell_fung_results.whole_image_cell_minor_axis};
    B.data(ii,21) = {cell_fung_results.whole_image_cell_major_axis};
    B.data(ii,22) = {stomates_fung_results.num_stomates};
     
    C = cell(size(B.data,1) + 1, size(B.data,2));
    C(1,:) = B.colheaders;
    C(2:end,:) = B.data;
    T = cell2table(C);
    writetable(T, [dir_output 'average_results_with_cell_avgs2.csv']);
    
    save([dir_output filename_pre '.mat'], 'cell_fung_results', 'stomates_fung_results', 'r_pen', 'c_pen', 'z_pen', ...
        'depths', 'breadths', 'volumes');
end
