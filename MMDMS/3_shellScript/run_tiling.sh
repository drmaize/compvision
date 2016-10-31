#!/bin/bash

sample="NULL"
experiment="NULL"
plate="NULL"
well="NULL"
tissue="NULL"
disease="NULL"
pathogenStrain="NULL"
hostAccession="NULL"
hpi="NULL"
replication="NULL"
treatment="NULL"
inventory_comments="NULL"
microImage_id="NULL"
microImageStart="NULL"
microImageStop="NULL"
microImage="NULL"
microMIP="NULL"
imageDimensions="NULL"
imageDirection="NULL"
magnification="NULL"
microImage_comments="NULL"
leafNumber="NULL"
receivedWhen="NULL"
receivedFrom="NULL"

TEMP=`getopt -o -- --long inventory_id:,slide:,sample:,experiment:,plate:,well:,tissue:,disease:,pathogenStrain:,hostAccession:,hpi:,replication:,treatment:,inventory_comments:,microImage_id:,microImageStart:,microImageStop:,microImage:,microMIP:,imagingDimensions:,imagingDirection:,magnification:,microImage_comments:,tilingStatus:,leafNumber:,receivedWhen:,receivedFrom: -- "$@"`

echo ${TEMP}

eval set -- "$TEMP"

while true ; do
	
	tempString=$(echo "$2" | sed -e 's/^ *//g;s/ *$//g')
	[ -z "$tempString" ] && tempString="NULL"
	
	case "$1" in

#while getopts :sample:experiment:plate:well:tissue:disease:pathogenStrain:hostAccession:hpi:replication:treatment:inventory_comments:microImage_id:microImageStart:microImageStop:microImage:microMIP:imageDimensions:imageDirection:magnification:microImage_comments:tilingStatus:leafNumber:receivedWhen:receivedFrom: opt; do
	
	#tempString=$(echo "${OPTARG}" | sed -e 's/^ *//g;s/ *$//g')
	#[ -z "$tempString" ] && tempString="NULL" 
	
	#case $opt in
		--sample)
			sample=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${sample}
			;;
		--experiment)
			experiment=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${experiment}
			;;
		--plate)
			plate=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${plate}
			;;
		--well)
			well=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${well}
			;;
		--tissue)
			tissue=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${tissue}
			;;
		--disease)
			disease=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${disease}
			;;
		--pathogenStrain)
			pathogenStrain=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${pathogenStrain}
			;;
		--hostAccession)
			hostAccession=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${hostAccession}
			;;
		--hpi)
			hpi=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${hpi}
			;;
		--replication)
			replication=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${replication}
			;;
		--treatment)
			treatment=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${treatment}
			;;
		--inventory_comments)
			inventory_comments=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${inventory_comments}
			;;
		--microImage_id)
			microImage_id=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microImage}
			;;
		--microImageStart)
			microImageStart=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microImageStart}
			;;
		--microImageStop)
			microImageStop=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microImageStop}
			;;
		--microImage)
			microImage=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microImage}
			;;
		--microMIP)
			microMIP=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microMIP}
			;;
		--imagingDimensions)
			imageDimensions=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${imageDimensions}
			;;
		--imagingDirection)
			imageDirection=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${imageDirection}
			;;
		--magnification)
			magnification=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${magnification}
			;;
		--microImage_comments)
			microImage_comments=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${microImage_comments}
			;;
		--receivedWhen)
			receivedWhen=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${receivedWhen}
			;;
		--receivedFrom)
			receivedFrom=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${receivedFrom}
			;;
		--leafNumber)
			leafNumber=$(echo ${tempString} | tr -d ' ' | tr -d "'" | tr -d '"')
			echo ${leafNumber}
			;;
		--slide)
			;;
		--inventory_id)
			;;
		--tilingStatus)
			;;
		--)
			shift; break ;;
		#:)
			#eval ${OPTARG}="NULL"
			#;;
		#\?)
			#;;
		*)
			echo "Error: ${1}"; exit 1 ;;
	esac
	shift 2
done
#shift $((OPTIND-1))
		 
exp=$(echo ${microImageStart} | sed -e 's/[a-z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | cut -f1 -d_) 
plt=$(echo ${microImageStart} | sed -e 's/[a-z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | cut -f2 -d_) 
slide=$(echo ${microImageStart} | sed -e 's/[a-z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | cut -f3 -d_) 
timestamp=$(echo ${microImageStart} | sed -e 's/[a-z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | cut -f4 -d_) 
start=$(echo ${microImageStart} | cut -f1 -d. | sed -e 's/[a-zA-Z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | rev | cut -f1 -d_ | rev) 
stop=$(echo ${microImageStop} | cut -f1 -d. | sed -e 's/[a-zA-Z]/_/g' | tr -s '_' | sed -e 's/^_//g;s/_$//g' | rev | cut -f1 -d_ | rev) 

Xgrid=$(echo ${imageDimensions} | sed -e 's/[a-zA-Z]/_/g' | cut -f1 -d_)
Ygrid=$(echo ${imageDimensions} | sed -e 's/[a-zA-Z]/_/g' | cut -f2 -d_)
Zgrid=$(echo ${imageDimensions} | sed -e 's/[a-zA-Z]/_/g' | cut -f3 -d_)

ord=$(echo "${imageDirection}:" | cut -f2 -d:)

npfx=""
k=${#Zgrid}
while [ $k -gt 1 ]
do
        npfx="${npfx}0"
        k=$[$k-1]
done


prfx=/home/$USER/scripts/
tname="temp_${exp}p${plt}w${well}${timestamp}.sh"
cname="clean_${exp}p${plt}w${well}${timestamp}.sh"
mname="tiling_macro_${exp}p${plt}w${well}${timestamp}.txt"
gname="combine_${exp}p${plt}w${well}${timestamp}.txt"
sname="tiling_${exp}p${plt}w${well}${timestamp}.sh"
fname="convert_${exp}p${plt}w${well}${timestamp}.txt"
lname="shading_${exp}p${plt}w${well}${timestamp}.js"
logname="tiledlog"
dname="scale_${exp}p${plt}w${well}${timestamp}.js"
stname="start_${exp}p${plt}w${well}${timestamp}.txt"


wkdir="/mnt/data27/wisser/drmaize/image_data/e${exp}/microimages/reconstructed/p${plt}w${well}${timestamp}"
srcdir="/mnt/data27/wisser/drmaize/image_data/e${exp}/microimages/raw/p${plt}/s${slide}/HS"
dstdir="/mnt/data27/wisser/drmaize/image_data/e${exp}/microimages/reconstructed/HS"

if [[ -d "${srcdir}/temp_1" && "$(ls -A ${srcdir}/temp_1/*.lsm)" ]]; then
	mv ${srcdir}/temp_1/*.lsm ${srcdir} 2>/dev/null
fi
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L*.lsm
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L*.lsm
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L*.lsm
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L*.lsm
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L*.lsm
rename _L0 _L ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L*.lsm


#convert format to tiff
if [[ -f ${srcdir}/lightprofile_red_${timestamp}.lsm && -f ${srcdir}/lightprofile_blue_${timestamp}.lsm ]]; then
	echo "open(\"${wkdir}/Shading_correction_red.lsm\");" > ${prfx}${fname}
	echo "saveAs(\"${wkdir}/Shading_correction_red.tif\");" >> ${prfx}${fname}
	echo "open(\"${wkdir}/Shading_correction_blue.lsm\");" >> ${prfx}${fname}
	echo "saveAs(\"${wkdir}/Shading_correction_blue.tif\");" >> ${prfx}${fname}
	if [[ -f ${srcdir}/lightprofile_white_${timestamp}.lsm ]]; then
		echo "open(\"${wkdir}/Shading_correction_white.lsm\");" >> ${prfx}${fname}
		echo "saveAs(\"${wkdir}/Shading_correction_white.tif\");" >> ${prfx}${fname}
	fi
	echo "for(i=${start}; i<$((${start}+${Xgrid}*${Ygrid})); i++){" >> ${prfx}${fname}
elif [[ -f ${srcdir}/lightprofile_white_${timestamp}.lsm ]]; then
	echo "open(\"${wkdir}/Shading_correction_white.lsm\");" > ${prfx}${fname}
	echo "saveAs(\"${wkdir}/Shading_correction_white.tif\");" >> ${prfx}${fname}
	echo "for(i=${start}; i<$((${start}+${Xgrid}*${Ygrid})); i++){" >> ${prfx}${fname}
else
	echo "for(i=${start}; i<$((${start}+${Xgrid}*${Ygrid})); i++){" > ${prfx}${fname}
fi
echo "print(i);" >> ${prfx}${fname}

if [[ -f ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L1.lsm ]]; then
	
#	echo "open(\"${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L\" + ${start} + \".lsm\");" >> ${prfx}${fname}
#	echo "Stack.getStatistics(area, mean, min, max, std, histogram);" >> ${prfx}${fname}
#	echo "base = mean;" >> ${prfx}${fname}
#	echo "rpos = Array.rankPositions(histogram);" >> ${prfx}${fname}
#	echo "base = rpos[histogram.length-1];" >> ${prfx}${fname}
#	echo "close();" >> ${prfx}${fname}
	echo "open(\"${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L\" + i + \".lsm\");" >> ${prfx}${fname}
#	echo "run(\"Gamma...\", \"value=0.50 stack\");" >> ${prfx}${fname}
#	echo "Stack.getStatistics(area, mean, min, max, std, histogram);" >> ${prfx}${fname}
#	echo "shift = base-mean;" >> ${prfx}${fname}
#	echo "rpos = Array.rankPositions(histogram);" >> ${prfx}${fname}
#	echo "shift = base-rpos[histogram.length-1];" >> ${prfx}${fname}
#	echo "run(\"Add...\", \"value=\" + shift + \" stack\");" >> ${prfx}${fname}
	echo "getDimensions(w, h, channels, slices, frames);" >> ${prfx}${fname}
	echo "setSlice(channels*slices);" >> ${prfx}${fname}
	echo "for(j=0; j<${Zgrid}-slices; j++){" >> ${prfx}${fname}
	echo "	run(\"Add Slice\",\"add=slice\");}" >> ${prfx}${fname}

	echo "open(\"${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L\" + i + \".lsm\");" >> ${prfx}${fname}
	echo "getDimensions(w, h, channels, slices, frames);" >> ${prfx}${fname}
	echo "setSlice(channels*slices);" >> ${prfx}${fname}
	echo "for(j=0; j<${Zgrid}-slices; j++){" >> ${prfx}${fname}
	echo "	run(\"Add Slice\",\"add=slice\");}" >> ${prfx}${fname}

	echo "run(\"Split Channels\");" >> ${prfx}${fname}
	echo "run(\"Merge Channels...\", \"c1=C1-e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L\" + i + \".lsm c2=C2-e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L\" + i + \".lsm c3=e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B2_L\" + i + \".lsm create\");" >> ${prfx}${fname}
	echo "run(\"Make Composite\");" >> ${prfx}${fname}

else

	echo "open(\"${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L\" + i + \".lsm\");" >> ${prfx}${fname}

fi

echo "ti=i-${start};" >> ${prfx}${fname}
echo "x=ti%${Xgrid};" >> ${prfx}${fname}
echo "y=(ti-x)/${Xgrid};" >> ${prfx}${fname}

if [ "${ord}" == "R" ] || [ "${ord}" == "r" ] || [ "${ord}" == "" ] ; then
	echo "ni=y*${Xgrid}+x+${start};" >> ${prfx}${fname}
else
	echo "ni=x*${Xgrid}+y+${start};" >> ${prfx}${fname}
fi

echo "saveAs(\"${wkdir}/exp${exp}p${plt}s${slide}_R1_GR1_B1_L\" + ni + \".tif\");" >> ${prfx}${fname}
echo "close(); }" >> ${prfx}${fname}

# perform shading correction
echo "IJ.runMacroFile(\"${prfx}${fname}\");" > ${prfx}${lname}
echo "var shading = IJ.openImage(\"${wkdir}/Shading_correction_red.tif\");" >> ${prfx}${lname}
echo "var sp = shading.getProcessor();" >> ${prfx}${lname}
echo "var fsp = sp.convertToFloat();" >> ${prfx}${lname}
echo "var stats = fsp.getStatistics();" >> ${prfx}${lname}
echo "fsp.multiply(1.0/stats.max);" >> ${prfx}${lname}
echo "var simg1 = new ImagePlus(\"shade1\",fsp);" >> ${prfx}${lname}
echo "shading.close();" >> ${prfx}${lname}
echo "var shading = IJ.openImage(\"${wkdir}/Shading_correction_blue.tif\");" >> ${prfx}${lname}
echo "var sp = shading.getProcessor();" >> ${prfx}${lname}
echo "var fsp = sp.convertToFloat();" >> ${prfx}${lname}
echo "var stats = fsp.getStatistics();" >> ${prfx}${lname}
echo "fsp.multiply(1.0/stats.max);" >> ${prfx}${lname}
echo "var simg2 = new ImagePlus(\"shade2\",fsp);" >> ${prfx}${lname}
echo "shading.close();" >> ${prfx}${lname}
echo "var shading = IJ.openImage(\"${wkdir}/Shading_correction_white.tif\");" >> ${prfx}${lname}
echo "var sp = shading.getProcessor();" >> ${prfx}${lname}
echo "var fsp = sp.convertToFloat();" >> ${prfx}${lname}
echo "var stats = fsp.getStatistics();" >> ${prfx}${lname}
echo "fsp.multiply(1.0/stats.max);" >> ${prfx}${lname}
echo "var simg3 = new ImagePlus(\"shade3\",fsp);" >> ${prfx}${lname}
echo "shading.close();" >> ${prfx}${lname}
echo "var ic = new ImageCalculator();" >> ${prfx}${lname}

echo "for(var i=${start}; i<$((${start}+${Xgrid}*${Ygrid})); i++){" >> ${prfx}${lname}
echo "	var img = IJ.openImage(\"${wkdir}/exp${exp}p${plt}s${slide}_R1_GR1_B1_L\" + i + \".tif\");" >> ${prfx}${lname}
echo "	var imgr= ic.run(\"Divide create 32-bit stack\", img, simg1);" >> ${prfx}${lname}
echo "	var imgs1 = imgr.getStack();" >> ${prfx}${lname}
echo "	var imgr= ic.run(\"Divide create 32-bit stack\", img, simg2);" >> ${prfx}${lname}
echo "	var imgs2 = imgr.getStack();" >> ${prfx}${lname}
echo "	var imgr= ic.run(\"Divide create 32-bit stack\", img, simg3);" >> ${prfx}${lname}
echo "	var imgs3 = imgr.getStack();" >> ${prfx}${lname}
echo "	var n = imgs1.getSize();" >> ${prfx}${lname}
echo "	var nimgs = new ImageStack(imgs1.getWidth(),imgs1.getHeight(),imgs1.getSize());" >> ${prfx}${lname}
echo "	var pfx=\"\";" >> ${prfx}${lname}
echo "	var k=1000; while(i < k){pfx=pfx+\"0\"; k=k/10;}" >> ${prfx}${lname}
echo "	for(var j=1; j<=n; j=j+n/${Zgrid}){" >> ${prfx}${lname}
echo "      if(n/${Zgrid} == 1){" >> ${prfx}${lname}
echo "		var fimp = imgs3.getProcessor(j);" >> ${prfx}${lname}
#echo "          var tempimp = new ImagePlus(\"temporary_image\",imgs3.getProcessor(j));" >> ${prfx}${lname}
#echo "          IJ.run(tempimp, \"Enhance Contrast...\", \"saturated=0.3 equalize\");" >> ${prfx}${lname}
#echo "          var fimp = tempimp.getProcessor();" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j);" >> ${prfx}${lname}
echo "          }" >> ${prfx}${lname}
echo "      else if(n/${Zgrid}==2){" >> ${prfx}${lname}
echo "		var fimp = imgs1.getProcessor(j);" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j);" >> ${prfx}${lname}
echo "		var fimp = imgs2.getProcessor(j+1);" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j+1);}" >> ${prfx}${lname}
echo "      else if(n/${Zgrid}==3){" >> ${prfx}${lname}
echo "		var fimp = imgs1.getProcessor(j);" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j);" >> ${prfx}${lname}
echo "		var fimp = imgs2.getProcessor(j+1);" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j+1);" >> ${prfx}${lname}
echo "		var fimp = imgs3.getProcessor(j+2);" >> ${prfx}${lname}
#echo "          var tempimp = new ImagePlus(\"temporary_image\",imgs3.getProcessor(j+2));" >> ${prfx}${lname}
#echo "          IJ.run(tempimp, \"Enhance Contrast...\", \"saturated=0.3 equalize\");" >> ${prfx}${lname}
#echo "          var fimp = tempimp.getProcessor();" >> ${prfx}${lname}
echo "		fimp.setInterpolationMethod(1);" >> ${prfx}${lname}
echo "		fimp.setBackgroundValue(0);" >> ${prfx}${lname}
echo "		fimp.rotate(-0.7);" >> ${prfx}${lname}
echo "		var bimgp = fimp.convertToByte(false);" >> ${prfx}${lname}
echo "		nimgs.setProcessor(bimgp,j+2);" >> ${prfx}${lname}
echo "          }}" >> ${prfx}${lname}
echo "	var imgsr = new ImagePlus(\"res\",nimgs);" >> ${prfx}${lname}
echo "	IJ.saveAs(imgsr, \"Tiff\",\"${wkdir}/exp${exp}p${plt}s${slide}_R1_GR1_B1_L\" + pfx + i + \".tif\");" >> ${prfx}${lname}
echo "	img.close();" >> ${prfx}${lname}
echo "	imgsr.close();" >> ${prfx}${lname}
echo "	imgr.close();" >> ${prfx}${lname}
echo "	IJ.run(\"Collect Garbage\");}" >> ${prfx}${lname}
echo "simg1.close();" >> ${prfx}${lname}
echo "simg2.close();" >> ${prfx}${lname}
echo "simg3.close();" >> ${prfx}${lname}
echo "IJ.run(\"Collect Garbage\");" >> ${prfx}${lname}

#tile the images
echo "runMacro(\"${prfx}${lname}\");" > ${prfx}${mname}
echo "run(\"Grid/Collection stitching\", \"type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x=${Xgrid} grid_size_y=${Ygrid} tile_overlap=8 first_file_index_i=${start} directory=${wkdir} file_names=exp${exp}p${plt}s${slide}_R1_GR1_B1_L{iiii}.tif output_textfile_name=exp${exp}p${plt}w${well}${timestamp}Configuration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] output_directory=${wkdir}/tiled/\");" >> ${prfx}${mname}

#combine all tiled slices into 2 tifs for fungal and leaf
echo "runMacro(\"${prfx}${mname}\");" > ${prfx}${gname}
echo "open(\"${wkdir}/exp${exp}p${plt}s${slide}_R1_GR1_B1_L${start}.tif\");" >> ${prfx}${gname}
echo "getDimensions(w, h, channels, slices, frames);" >> ${prfx}${gname}
echo "close();" >> ${prfx}${gname}
echo "if(channels*slices*frames/${Zgrid} == 2){" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=1 increment=2 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=2 increment=2 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "  open(\"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif\");" >> ${prfx}${gname}
echo "  open(\"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif\");" >> ${prfx}${gname}
echo "  run(\"Merge Channels...\", \"c1=exp${exp}p${plt}w${well}${timestamp}rf001.tif c2=exp${exp}p${plt}w${well}${timestamp}rl001.tif create\");" >> ${prfx}${gname}
echo "  saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rc001.tif\");" >> ${prfx}${gname}
echo "  close();" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rf001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rl001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rc001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rc001.ome.tif\");}" >> ${prfx}${gname}
echo "else if(channels*slices*frames/${Zgrid} == 1){" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=1 increment=1 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rb001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rc001.ome.tif\");}" >> ${prfx}${gname}
echo "else if(channels*slices*frames/${Zgrid} == 3){" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=1 increment=3 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=2 increment=3 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "	run(\"Image Sequence...\", \"open=${wkdir}/tiled/img_t1_z${npfx}1_c1 number=${Zgrid} starting=3 increment=3 scale=100 file=img sort\");" >> ${prfx}${gname}
echo "	saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif\");" >> ${prfx}${gname}
echo "	close();" >> ${prfx}${gname}
echo "  open(\"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif\");" >> ${prfx}${gname}
echo "  open(\"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif\");" >> ${prfx}${gname}
echo "  open(\"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif\");" >> ${prfx}${gname}
echo "  run(\"Merge Channels...\", \"c1=exp${exp}p${plt}w${well}${timestamp}rf001.tif c2=exp${exp}p${plt}w${well}${timestamp}rl001.tif c3=exp${exp}p${plt}w${well}${timestamp}rb001.tif create\");" >> ${prfx}${gname}
echo "  saveAs(\"Tiff\", \"${dstdir}/exp${exp}p${plt}w${well}${timestamp}rc001.tif\");" >> ${prfx}${gname}
echo "  close();" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rf001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rl001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rb001.ome.tif\");" >> ${prfx}${gname}
echo "	exec(\"java -jar ${prfx}ImageConverter.jar ${srcdir}/e${exp}p${plt}s${slide}_${timestamp}_R1_GR1_B1_L${start}.lsm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rc001.tif ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rc001.ome.tif\");}" >> ${prfx}${gname}

#downsample
echo "importClass(Packages.java.io.File);" > ${prfx}${dname}
echo "IJ.runMacroFile(\"${prfx}${gname}\");" >> ${prfx}${dname}
echo "var img = IJ.openImage(\"${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rf001.ome.tif\");" >> ${prfx}${dname}
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
echo "IJ.saveAs(imgsr, \"Tiff\", \"${dstdir}/downsampled/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rf001d8.tif\");" >> ${prfx}${dname}
echo "img.close();" >> ${prfx}${dname}
echo "imgsr.close();" >> ${prfx}${dname}

#startscript
echo "exec(\"python /mnt/data27/wisser/drmaize/compvision/Bisque/TweetUpdate.py e${exp}p${plt}w${well}x${magnification::-1}_${timestamp} began stitching.\")" > ${prfx}${stname}
echo "exec(\"mkdir -p ${wkdir}\");" >> ${prfx}${stname}
echo "exec(\"mkdir -p ${wkdir}/tiled\");" >> ${prfx}${stname}
echo "exec(\"mkdir -p ${dstdir}/downsampled\");" >> ${prfx}${stname}
echo "exec(\"${prfx}${tname}\");" >> ${prfx}${stname}
echo "runMacro(\"${prfx}${dname}\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rf001.tif\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rl001.tif\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rb001.tif\");" >> ${prfx}${stname}
echo "exec(\"rm ${dstdir}/exp${exp}p${plt}w${well}${timestamp}rc001.tif\");" >> ${prfx}${stname}
echo "exec(\"python /mnt/data27/wisser/drmaize/compvision/Bisque/TweetUpdate.py e${exp}p${plt}w${well}x${magnification::-1}_${timestamp} has been stitched.\")" >> ${prfx}${stname}

echo "exec(\"python /mnt/data27/wisser/drmaize/compvision/Bisque/UploadToBisque.py '${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rc001.ome.tif' 'TEST_DATASET' sample '${sample}' experiment '${experiment}' plate '${plate}' well '${well}' tissue '${tissue}' receivedWhen '${receivedWhen}' receivedFrom '${receivedFrom}' disease '${disease}' pathogenStrain '${pathogenStrain}' hostAccession '${hostAccession}' hpi '${hpi}' leafNumber '${leafNumber}' replication '${replication}' treatment '${treatment}' inventory_comments '${inventory_comments}' microImage_id '${microImage_id}'  microImageStart  '${microImageStart}' microImageStop '${microImageStop}' microImage '${microImage}' microMIP '${microMIP}' imagingDimensions '${imageDimensions}' imagingDirection '${imageDirection}' magnification '${magnification}' microImage_comments '${microImage_comments}' tilingStatus 'complete!' macroImage_comments 'NULL' cameraImage 'NULL' macroImage 'NULL'\")" >> ${prfx}${stname}

echo "exec(\"rm ${dstdir}/e${exp}p${plt}w${well}x${magnification::-1}_${timestamp}rc001.ome.tif\");" >> ${prfx}${stname}
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
echo "eval(\"script\", \"System.exit(0);\");" >> ${prfx}${stname}


#get shading correction file
echo "if [[ -f ${srcdir}/lightprofile_red_${timestamp}.tif && -f ${srcdir}/lightprofile_blue_${timestamp}.tif ]]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_red_${timestamp}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_red_${timestamp}.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_blue_${timestamp}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_blue_${timestamp}.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
echo "elif [[ -f ${srcdir}/lightprofile_red_${timestamp}.lsm && -f ${srcdir}/lightprofile_blue_${timestamp}.lsm ]]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_red_${timestamp}.lsm ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_red_${timestamp}.lsm ${wkdir}/Shading_correction_red.lsm" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_blue_${timestamp}.lsm ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_blue_${timestamp}.lsm ${wkdir}/Shading_correction_blue.lsm" >> ${prfx}${tname}
echo "else" >> ${prfx}${tname}
	echo "cp ${prfx}Shading_correction_red.tif ${wkdir}" >> ${prfx}${tname}
	#echo "mv ${wkdir}/Shading_correction_red.tif ${wkdir}/Shading_correction_red.tif" >> ${prfx}${tname}
	echo "cp ${prfx}Shading_correction_blue.tif ${wkdir}" >> ${prfx}${tname}
	#echo "mv ${wkdir}/Shading_correction.tif ${wkdir}/Shading_correction_blue.tif" >> ${prfx}${tname}
echo "fi" >> ${prfx}${tname}
echo "if [[ -f ${srcdir}/lightprofile_white_${timestamp}.tif ]]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_white_${timestamp}.tif ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_white_${timestamp}.tif ${wkdir}/Shading_correction_white.tif" >> ${prfx}${tname}
echo "elif [[ -f ${srcdir}/lightprofile_white_${timestamp}.lsm ]]; then" >> ${prfx}${tname}
	echo "cp ${srcdir}/lightprofile_white_${timestamp}.lsm ${wkdir}" >> ${prfx}${tname}
	echo "mv ${wkdir}/lightprofile_white_${timestamp}.lsm ${wkdir}/Shading_correction_white.lsm" >> ${prfx}${tname}
echo "else" >> ${prfx}${tname}
	echo "cp ${prfx}Shading_correction_white.tif ${wkdir}" >> ${prfx}${tname}
echo "fi" >> ${prfx}${tname}
chmod 777 ${prfx}${tname}

#clean all temporary files
echo "rm -rf ${wkdir}" > ${prfx}${cname}
echo "rm ${prfx}${tname}" >> ${prfx}${cname}
echo "rm ${prfx}${gname}" >> ${prfx}${cname}
echo "rm ${prfx}${mname}" >> ${prfx}${cname}
echo "rm ${prfx}${lname}" >> ${prfx}${cname}
echo "rm ${prfx}${fname}" >> ${prfx}${cname}
echo "rm ${prfx}${stname}" >> ${prfx}${cname}
echo "rm ${prfx}${sname}" >> ${prfx}${cname}
echo "rm ${prfx}${cname}" >> ${prfx}${cname}
chmod 777 ${prfx}${cname}

#torque script
echo "#!/bin/bash" > ${prfx}${sname}
echo "#PBS -N tiling_${exp}p${plt}w${well}${timestamp}" >> ${prfx}${sname}
echo "#PBS -l nodes=biomix17:ppn=1" >> ${prfx}${sname}
echo "#PBS -l walltime=10:00:00,cput=10:00:00" >> ${prfx}${sname}

echo "/usr/local/Fiji.app/ImageJ-linux64 -batch ${prfx}${stname}" >> ${prfx}${sname}
chmod 777 ${prfx}${sname}
qsub ${prfx}${sname}

#${prfx}${sname}