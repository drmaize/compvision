Readme for 4_customUI
Description:
- Front end VBA scripts and UI

Usage:

+ Requirements:
- 32 bit Microsoft Excel 2007 and above (tested on excel 2013)
- plink.exe (command line interface to PuTTY telnet/SSH client) to execute backend shell scripts on server. It can be downloaded at http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html

+ UI:
* customUI.xml
	- Adds an additional TAB and buttons to the xlsm file (macro enabled Microsoft Excel file)
	- Specifies the scripts to execute for each button

	usage:
	- Create and save a new .xlsm file
	- Go to the saved location and rename the .xlsm to .zip
	- Open the zip archive
	- Add folder "CustomUI"
	- Add the provided "customUI.xml" file into the folder "CustomUI"
	- Close the archive and rename it back to .xlsm

+ Scripts:
* MacroMicro_MngmntSystUI_VBscript.txt
	- Scripts to call backend scripts for
		- Stitching image tiles
		- Terminate stitching
		- Update status of Stitching

	usage:
	- Open the saved xlsm file ( this will now have the custom UI tab and buttons ).
	- Go to 'Developer' tab and click on the 'Visual Basic' button to open VBA editor.
	- Select 'ThisWorkbook' and click 'view code' to open the code for the current workbook.
	- Copy the content of 'MacroMicro_MngmntSystUI_VBscript.txt' to the code for current workbook.


+ Sample:
* Sample.xlsm 


----------------------------------------------------------------------------------------------------------------------
Update: 03/18/2016

- MacroMicro_MngmntSystUI_VBscript.txt has been updated to reflec the changes in the directory structure.
----------------------------------------------------------------------------------------------------------------------

