Readme for 3_shellScript

Description:
- Backend shell scripts.
- These scripts run on the local server.

Usage:

+ Requirements:
- ImageJ installed with customized stitching plugins
- icommands installed to connect to iRODS.
- Job scheduler(Torque)

+ Scripts:
* run_tiling.sh
	- Used to stitch the image tiles imaged by the microscope for a given sample.
	- Uses the following arguments (data read from the xlsxm file):
 
		1) experiment id

		2) plate and well number

		3) index of the first tile
 
		4) total number of tiles

		5) number of tiles in each dimension

		6) imaging direction

		7) timestamp of the first tile
	- Creates temporary directories for intermediate files.
	- Creates auxiliary ImageJ scripts and initiates a torque job to run them.
		- Convert lsm to tif.
		- Perform pre-stitch shading correction.
		- Stitch
		- Collate into 2 separate image files for the 2 different image channels
		- Downsample
	- Converts tif to ome.tif and adds metadata from the raw lsm files.
	- Uploads the stitched image onto iRODS.
	- Clears all temporary files and directories.
	
* upload.sh
	- Uploads all the files corresponding to an experiment onto iRODS.
	
* check_tiled.sh
	- Finds all the samples that are tiled that belong to a given experiment.


* check_uploaded.sh
	- Finds all the samples that are tiled and uploaded onto iRODS belonging to a givent experiment.



* del.sh

	- Deletes tiled images of a given experiment.


* del_uploaded.sh
	- Deletes tiled images of a given experiment that are uploaded onto iRODS.




