ls -l /mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed/Down_Sampled/ 2> err.log | grep -e exp${1}${2}[A-Za-z0-9]*.tif | tr -s ' ' | cut -d ' ' -f3,9,5
