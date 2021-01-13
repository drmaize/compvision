Everything should have already been run on Exp13. 
image_data\e013SLB\microimages\reconstructed\HS\phil_results\quantified_numbers\


For the scripts, the paths are hard-coded from my machine as I mounted DrMaize, so these will need to be changed.


quanitfy_example_script is an example script to run the algorithms on an example data from Exp13

overlay_figures is a script to pick a certain data point and generate overlays including visualizations of penetration events on the cell segmentation images, etc

quantify_all_files_all_features runs a script that calculates metrics and outputs table

Everything else is a function that these scripts use:
quantifyCells/StomataNearPenetrations calculates metrics based on the penetration events on the cell/stomata segmentations. 
