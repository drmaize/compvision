#!/bin/bash

prfx=/home/$USER/scripts/
sname="surfoptimize${1}p${2}w${3}${4}1.sh"
echo "#!/bin/bash" > ${prfx}${sname}
echo "#PBS -N surfoptimize_${1}${2}${3}1" >> ${prfx}${sname}
echo "#PBS -l nodes=biomix17:ppn=1" >> ${prfx}${sname}
echo "#PBS -l walltime=8:00:00,cput=8:00:00" >> ${prfx}${sname}

echo "experiment='${1}'; plt='${2}'; wl='${3}'; timestamp='${4}'; $(cat ${prfx}surfaceoptimization1.m) quit;" > ${prfx}surfoptimize${1}p${2}w${3}${4}1.m

echo "/opt/MATLAB/R2014a/bin/matlab -nodesktop -r \"cd /home/abhi/scripts; surfoptimize${1}p${2}w${3}${4}1\"" >> ${prfx}${sname}

qsub ${prfx}${sname}
