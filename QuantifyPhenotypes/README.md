# Quantification of Phenotypes
The final goal of this software package is to provide statistics, numbers, and counts of physical features for each structure. The code in this section reads as input the segmented and thresholded skeletons from previous sections, and as output generates both a Microsoft Excel spreadsheet and images. The spreadsheet contains a section for each structure of interest and uses a user-provided ID to append new detected structures and their attributes. 


This was developed in Matlab 2019b on a 64-bit Windows 10 machine, as well as Matlab 2021a on Ubuntu 20.04. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10 or Ubuntu. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

For Windows: 
```.\QuantifyPhenotypes.exe "sample_identifier_string" "path_to_cells_skeleton.png" "path_to_stomates_skeleton.png" "path_to_fungus_skeleton.tif" "path_to_fungus_segmentation.tif"  "path_to_surface_map.txt" "path_to_surface_image.png" "penetration_depth_threshold" "[scalex scaley scalez]" "output_results.xlsx" "output_results_visualization.png"   ```   
For Linux: ```./run_QuantifyPhenotypes.sh /usr/local/MATLAB//MATLAB_Runtime/v910/ "sample_identifier_string" "path_to_cells_skeleton.png" "path_to_stomates_skeleton.png" "path_to_fungus_skeleton.tif" "path_to_fungus_segmentation.tif"  "path_to_surface_map.txt" "path_to_surface_image.png" "penetration_depth_threshold" "[scalex scaley scalez]" "output_results.xlsx" "output_results_visualization.png" ```
where /usr/local/MATLAB/MATLAB_Runtime/v910 is the path to the Matlab Runtime installed (requirement for Linux only). The full list of parameters is given below and must be passed in order as strings:

where 

--sample_identifier_string is a string to uniquely identify the sample. This is used in the Excel Spreadsheet to distinguish numbers from different samples. E.G "e013SLBp03wA1x20_1505041720rf001"

--path_to_cells_skeleton.png is the path to the segmented and skeletonized cell image generated from a previous section

--path_to_stomates_skeleton.png is the path to the segmented and skeletonized stomata image generated from a previous section

--path_to_fungal_skeleton.tif is the path to the segmented and skeletonized fungal 3D stack generated from a previous section

--path_to_fungal_segmentation.tif is the path to the segmented and NOT skeletonized fungal 3D stack generated from a previous section

--path_to_surface_map.txt is the path to the surace map generated from a previous section

--path_to_surface_image.png is the path to the surace image generated from a previous section

--penetration_depth_threshold is the number of slices beneath a surface the fungus must penetrate to be considered a true penetration event. To eliminate noise and mis-labelings.

--[scalex scaley scalez] is the pixels per um scalings. e.g we used [2.6 2.6 1.2] since 2.6 pixels make up 1um in the x,y directions and 1.2 in the depth/z direction

--output_results.xlsx is the path to store the Excel Worksheet

--output_results_visualization.png is the path to store overlay images created by the program.

All inputs are required. However, if a structure is missing in your application, leave the string blank. I.E instead of "path_to_stomates_skeleton.png" give "". If not all structures are given, only the Microsoft Worksheet will be created. This is because the overlay images require all the structures to be generated. 

