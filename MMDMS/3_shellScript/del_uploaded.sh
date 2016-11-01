idir="/home/$USER/iRODS/clients/icommands/bin/"
${idir}iinit < /home/$USER/scripts/pwd.txt > dump 2> dump
${idir}icd /iplant/home/drmaize/bisque_data/${1}/ > dump 2> dump
${idir}irm exp${1}${2}${3}rf001.ome.tif > dump 2> dump
${idir}irm exp${1}${2}${3}rl001.ome.tif > dump 2> dump
${idir}icd /iplant/home/drmaize/bisque_data/uploads/${1}/ > dump 2> dump
${idir}irm exp${1}${2}${3}rf001.tif > dump 2> dump
${idir}iexit
