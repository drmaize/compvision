#!/bin/bash

#set up names for ImageJ scripts.
prfx=/home/$USER/scripts/
tname="temp_${1}${2}${7}.sh"
mname="tiling_macro_${1}${2}${7}.txt"
gname="combine_${1}${2}${7}.txt"
sname="tiling_${1}${2}${7}.sh"
fname="convert_${1}${2}${7}.txt"
lname="shading_${1}${2}${7}.js"
logname="tiledlog"
dname="scale_${1}${2}${7}.js"
stname="start_${1}${2}${7}.txt"
npfx=""
k=${#6}
while [ $k -gt 1 ]
do
npfx="${npfx}0"
k=$[$k-1]
done

#get slide number from well number
slide="s2"
plate=${2:0:3}
well=${2: -1}
if [ "$well" -lt 4 ]
then
slide="s1"
fi

#setup directories
wkdir="/mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed/${2}${7}"
srcdir="/mnt/data27/wisser/drmaize/image_data/${1}/microimages/raw/P${plate:1:2}/S${slide: -1}/temp_1"
dstdir="/mnt/data27/wisser/drmaize/image_data/${1}/microimages/reconstructed"
icomdir="/home/$USER/iRODS/clients/icommands/bin"

#convert format from lsm to tiff
echo "for(i=${3}; i<$((${3}+${4}*${5})); i++){" > ${prfx}${fname}
echo "open(\"${srcdir}/exp${1}${plate}${slide}${7}_R1_GR1_B1_L\" + i + \".lsm\");" >> ${prfx}${fname}
echo "ti=i-${3};" >> ${prfx}${fname}
echo "x=ti%${4};" >> ${prfx}${fname}
echo "y=(ti-x)/${4};" >> ${prfx}${fname}
if [ "$8" == "R" ] || [ "$8" == "r" ] || [ "$8" == "" ] ; then
echo "ni=y*${4}+x+${3};" >> ${prfx}${fname}
else
echo "ni=x*${4}+y+${3};" >> ${prfx}${fname}
fi
echo "saveAs(\"${wkdir}/exp${1}${plate}${slide}_R1_GR1_B1_L\" + ni + \".tif\");" >> ${prfx}${fname}
echo "close(); }" >> ${prfx}${fname}

#perform shading correction using the shading image captured
echo "IJ.runMacroFile(\"${prfx}${fname}\");" > ${prfx}${lname}
echo "var shading = IJ.openImage(\"${wkdir}/Shading_correction_red.tif\");" >> ${prfx}${lname}
echo "var sp = shading.getProcessor();" >> ${prfx}${lname}
echo "var fsp = sp.convertToFloat();" >> ${prfx}${lname}
echo "var stats = fsp.getStatistics();" >> ${prfx}${lname}
echo "fsp.multiply(1.0/stats.mean);" >> ${prfx}${lname}
echo "var simg1 = new ImagePlus(\"shade1\",fsp);" >> ${prfx}${lname}
echo "shading.close();" >> ${prfx}${lname}
echo "var shading = IJ.openImage(\"${wkdir}/Shading_correction_blue.tif\");" >> ${prfx}${lname}
echo "var sp = shading.getProcessor();" >> ${prfx}${lname}
echo "var fsp = sp.convertToFloat();" >> ${prfx}${lname}
echo "var stats = fsp.getStatistics();" >> ${prfx}${lname}
echo "fsp.multiply(1.0/stats.mean);" >> ${prfx}${lname}
echo "var simg2 = new ImagePlus(\"shade2\",fsp);" >> ${prfx}${lname}
echo "shading.close();" >> ${prfx}${lname}
echo "var ic = new ImageCalculator();" >> ${prfx}${lname}

echo "for(var i=${3}; i<$((${3}+${4}*${5})); i++){" >> ${prfx}${lname}
echo "	var img = IJ.openImage(\"${wkdir}/exp${1}${plate}${slide}_R1_GR1_B1_L\" + i + \".tif\");" >> ${prfx}${lname}
echo "	var imgr= ic.run(\"Divide create 32-bit stack\", img, simg1);" >> ${prfx}${lname}
echo "	var imgs1 = imgr.getStack();" >> ${prfx}${lname}
echo "	var imgr= ic.run(\"Divide create 32-bit stack\", img, simg2);" >> ${prfx}${lname}
echo "	var imgs2 = imgr.getStack();" >> ${prfx}${lname}
echo "	var n = imgs1.getSize();" >> ${prfx}${lname}
echo "	var nimgs = new ImageStack(imgs1.getWidth(),imgs1.getHeight(),imgs1.getSize());" >> ${prfx}${lname}
echo "	var pfx=\"\";" >> ${prfx}${lname}
echo "	var k=1000; while(i < k){pfx=pfx+\"0\"; k=k/10;}" >> ${prfx}${lname}
echo "	for(var j=1; j<=n; j=j+2){" >> ${prfx}${lname}
echo "		var fimp = imgs1.getProcessor(j);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j);" >> ${prfx}${lname}
echo "		var fimp = imgs2.getProcessor(j+1);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j+1);}" >> ${prfx}${lname}
echo "	var imgsr = new ImagePlus(\"res\",nimgs);" >> ${prfx}${lname}
echo "	IJ.saveAs(imgsr, \"Tiff\",\"${wkdir}/exp${1}${plate}${slide}_R1_GR1_B1_L\" + pfx + i + \".tif\");" >> ${prfx}${lname}
echo "	img.close();" >> ${prfx}${lname}
echo "	imgsr.close();" >> ${prfx}${lname}
echo "	imgr.close();" >> ${prfx}${lname}
echo "	IJ.run(\"Collect Garbage\");}" >> ${prfx}${lname}
echo "simg.close();" >> ${prfx}${lname}
echo "IJ.run(\"Collect Garbage\");" >> ${prfx}${lname}
#echo "return;" >> ${prfx}${lname}

#tile the images
echo "runMacro(\"${prfx}${lname}\");" > ${prfx}${mname}
echo "run(\"Grid/Collection stitching\", \"type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x=${4} grid_size_y=${5} tile_overlap=10 first_file_index_i=${3} directory=${wkdir} file_names=exp${1}${plate}${slide}_R1_GR1_B1_L{iiii}.tif output_textfile_name=exp${1}${2}${7}Configuration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=${wkdir}/tiled/\");" >> ${prfx}${mname}

#combine all tiled slices into 2 separate tifs for fungal and leaf
echo "runMacro(\"${prfx}${mname}\");" > ${prfx}${gname}
echo "run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${6} starting=1 increment=2 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "saveAs(\"Tiff\", \"${dstdir}/exp${1}${2}${7}rf001.tif\");" >> ${prfx}${gname}
echo "close();" >> ${prfx}${gname}
echo "run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${6} starting=2 increment=2 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "saveAs(\"Tiff\", \"${dstdir}/exp${1}${2}${7}rl001.tif\");" >> ${prfx}${gname}
echo "close();" >> ${prfx}${gname}
echo "exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/exp${1}${plate}${slide}${7}_R1_GR1_B1_L${3}.lsm ${dstdir}/exp${1}${2}${7}rf001.tif ${dstdir}/exp${1}${2}${7}rf001.ome.tif\");" >> ${prfx}${gname}
echo "exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/exp${1}${plate}${slide}${7}_R1_GR1_B1_L${3}.lsm ${dstdir}/exp${1}${2}${7}rl001.tif ${dstdir}/exp${1}${2}${7}rl001.ome.tif\");" >> ${prfx}${gname}

#downsample
echo "importClass(Packages.java.io.File);" > ${prfx}${dname}
echo "IJ.runMacroFile(\"${prfx}${gname}\");" >> ${prfx}${dname}
echo "var img = IJ.openImage(\"${dstdir}/exp${1}${2}${7}rf001.ome.tif\");" >> ${prfx}${dname}
echo "var imgs = img.getStack();" >> ${prfx}${dname}
echo "var n = imgs.getSize();" >> ${prfx}${dname}
echo "var width = Math.round(imgs.getWidth()*0.125);" >> ${prfx}${dname}
echo "var height = Math.round(imgs.getHeight()*0.125);" >> ${prfx}${dname}
echo "var nimgs = new ImageStack(width,height,imgs.getSize());" >> ${prfx}${dname}
echo "for(var j=1; j<=n; j++){" >> ${prfx}${dname}
echo "        var fimp = imgs.getProcessor(j);" >> ${prfx}${dname}
echo "        var bimgp = fimp.resize(width,height);" >> ${prfx}${dname}
echo "        nimgs.setProcessor(bimgp,j);" >> ${prfx}${dname}
echo "        }" >> ${prfx}${dname}
echo "var imgsr = new ImagePlus(\"res\",nimgs);" >> ${prfx}${dname}
echo "IJ.saveAs(imgsr, \"Tiff\", \"${dstdir}/Down_Sampled/exp${1}${2}${7}rf001.tif\");" >> ${prfx}${dname}
echo "img.close();" >> ${prfx}${dname}
echo "imgsr.close();" >> ${prfx}${dname}

#startscript
echo "exec(\"mkdir -p ${wkdir}\");" > ${prfx}${stname}
echo "exec(\"mkdir -p ${wkdir}/tiled\");" >> ${prfx}${stname}
echo "exec(\"mkdir -p ${dstdir}/Down_Sampled\");" >> ${prfx}${stname}
echo "exec(\"${prfx}${tname}\");" >> ${prfx}${stname}
echo "runMacro(\"${prfx}${dname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${1}${2}${7}rf001.tif\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${1}${2}${7}rl001.tif\");" >> ${prfx}${stname}
echo "exec(\"echo \"${1}${2}:${USER}\" >> ${prfx}${logname}\");" >> ${prfx}${stname}
echo "exec(\"uniq ${prfx}${logname} > ${prfx}${logname}\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/iinit < ${prfx}pwd.txt\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/icd /iplant/home/drmaize/bisque_data/${1}/\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/iput -f ${dstdir}/exp${1}${2}${7}rf001.ome.tif\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/iput -f ${dstdir}/exp${1}${2}${7}rl001.ome.tif\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/icd /iplant/home/drmaize/bisque_data/uploads/${1}/\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/iput -f ${dstdir}/Down_Sampled/exp${1}${2}${7}rf001.tif\");" >> ${prfx}${stname}
echo "exec(\"${icomdir}/iexit\");" >> ${prfx}${stname}
echo "exec(\"rm -rf ${wkdir}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${tname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${mname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${lname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${fname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${sname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${cname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${gname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${dname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${prfx}${stname}\");" >> ${prfx}${stname}
echo "run(\"Quit\");" >> ${prfx}${stname}


#make temporary folders
echo "if [[ -f ${srcdir}/Shading_correction_red${7}.tif && -f ${srcdir}/Shading_correction_blue${7}.tif ]]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_red${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_red${7}.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_blue${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_blue${7}.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
echo "elif [ -f ${srcdir}/Shading_correction_red${7}.tif ]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_red${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_red${7}.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_red${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_red${7}.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
echo "elif [ -f ${srcdir}/Shading_correction_blue${7}.tif ]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_blue${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_blue${7}.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
	echo "cp ${srcdir}/Shading_correction_blue${7}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction_blue${7}.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
echo "else" >> ${prfx}${tname}
	echo "cp ${prfx}Shading_correction.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
	echo "cp ${prfx}Shading_correction.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/Shading_correction.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
echo "fi" >> ${prfx}${tname}
chmod 777 ${prfx}${tname}

#torque script to run tiling
echo "#!/bin/bash" > ${prfx}${sname}
echo "#PBS -N tiling_${1}${2}${7}" >> ${prfx}${sname}
echo "#PBS -l nodes=biohen27:ppn=1" >> ${prfx}${sname}
echo "#PBS -l walltime=2:00:00,cput=2:00:00" >> ${prfx}${sname}

echo "ImageJ -batch ${prfx}${stname}" >> ${prfx}${sname}

#submit Torgue job
chmod 777 ${prfx}${sname}
qsub ${prfx}${sname}