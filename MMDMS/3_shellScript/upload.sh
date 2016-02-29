idir="/home/$USER/iRODS/clients/icommands/bin/"
${idir}iinit < /home/$USER/scripts/pwd.txt > dump 2> dump
${idir}icd /iplant/home/drmaize/bisque_data/${1}/ > dump 2> dump
echo "Uploading ${1} ${2}..."
${idir}iput /mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed/exp${1}${2}rf001.ome.tif > dump 2> dump
${idir}iput /mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed/exp${1}${2}rl001.ome.tif > dump 2> dump
${idir}icd /iplant/home/drmaize/bisque_data/uploads/${1}/ > dump 2> dump
${idir}iput /mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed/Down_Sampled/exp${1}${2}rf001.tif > dump 2> dump
${idir}iexit
echo "Done."
