Macroscopic Microscopy Data Management System
This readme provides a general overview of the system. Further details can be found in a readme file for each component.

Content:
1) imageJFiles
2) shellScripts
3) convOMETIFF
4) customUI
5) videocasts

Components:
* Macro enabled microsoft excel file: 
	- Meta data on experiments
	- UI for the system
* Local Linux server:
	- Local storage for images from microscope
	- Services to process images (shell scripts and customized ImageJ)
* iPlant (iRODS)
	- Online data store for image data
	- For sharing and collaboration (BISQUE)
	
Files in the package:
- Macro enabled microsoft excel file (xlsxm).
- Shell scripts (run_tiling.sh, upload.sh, check_uploaded.sh, check_tiled.sh, del_uploaded.sh)
- ImageJ files (source code for customized stitching plugin and compiled jars).
- Directory structure used by the system.

Setup:
1) Copy the macro enabled excel file onto your local computer.
2) Install ImageJ on your local server.
3) Replace the installed plugin with the ones provided in the package (jar files)
4) Copy the shell scripts to user's home directory on the local server. Set necessary permissions to execute scripts.
5) Create the prescribed/required folder structure for storing files on the server.
6) Create an account on iRODS for online data storage and replicate the local directory structure.
7) Install iCommands on the local server.
7) Update the shell scripts to suit your directory structure.
8) Setup the microscope to save files on the local server in the appropriate directory.

Usage:
1) Populate the macro enabled excel file with metadata.
2) Save the images from the microscope in the appropriate directory on the local server.
3) In the excel file, select the row[s] you want to process.
4) Use the processing options in the "Tiling" tab and follow prompts.


