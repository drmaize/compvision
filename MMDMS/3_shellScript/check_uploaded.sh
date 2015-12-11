idir="/home/$USER/iRODS/clients/icommands/bin/"
${idir}iinit < /home/$USER/scripts/pwd.txt > dump 2> dump
${idir}icd /iplant/home/drmaize/bisque_data/uploads/${1}/ > dump 2> dump
${idir}ils -l exp${1}${2}${3}rf001.tif 2> dump | grep tif | tr -s ' ' | cut -d ' ' -f5
${idir}iexit

