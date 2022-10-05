#
# Use of this Makfile requires Apache Ant to be present in the user's
# environment.
#
# Additional plugins can be retrieved from a binary build of Fiji and
# installed in a directory named 'plugins' in the working directory.
#

default: ij.jar
	
ij.jar: src src/ij.jar
	cp src/ij.jar ./ij.jar

src:
	git clone https://github.com/imagej/ImageJ src
	# Patch the build.xml to skip the "run" target:
	( cd src ; sed -i 's/\(<project .*default="\)run/\1build/' build.xml )

src/ij.jar:
	( cd src ; ant -buildfile build.xml )
