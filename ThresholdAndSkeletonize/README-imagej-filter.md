# ImageJ Filter Pipeline for Linux

The ImageJ and Fiji software are available for Linux, Mac, and Windows.  For the Linux version of the compvision project the compiled Fiji application must be installed and the "ImageJ-linux64" executable that is part of it is used in headless (no GUI) batch execution mode.  A file of commands (a *macro*) is read and executed by ImageJ.

The macro is constructed on-the-fly and executed by the [imagej-filter](./imagej-filter) Bash script.

## Installation

When `make` is executed without a target in this directory, the default recipe simply downloads the latest release of Fiji for Linux.  The product is a .zip file in this directory.

When `make install` is executed, the .zip file is unpacked within the installation prefix directory ($PREFIX).  A symbolic link to the "ImageJ-linux64" executable inside the installed application is created in the installation binary directory ($BINDIR) and the [imagej-filter](./imagej-filter) script is also copied to $BINDIR.  When $BINDIR is added to the PATH, both programs become available without entering a full path.

## Usage

The script has built-in help:

```
$ imagej-filter --help
usage:

    imagej-filter {options}

  options:
  
    -h/--help                           show this information
    -v/--verbose                        show a trace of actions as the script
                                        executes
    
    -i/--input <filepath>               read the input image from this TIFF file
    -o/--output <filepath>              write the filtered image to this TIFF file
    
    -d/--save-macro-file                by default the macro file is deleted if the
                                        run is successful; use this flag to retain
                                        the file no matter the outcome
    -m/--macro-file <filepath>          file to which the generated macro should be
                                        written; if not provided, a temporary file
                                        will be used
    
    --imagej <filepath>                 provide a specific path to an ImageJ-linux64
                                        executable; by default the bare command
                                        'ImageJ-linux64' is used, which will resolve
                                        against the current PATH
    
    --disable-threshold                 do NOT perform the threshold step
    -t/--threshold-method <method>      threshold algorithm
    
            <method>        description
            -------------   ----------------------------------------------------------
            default         ISO two-level
            manual          ISO two-level with explicit low,high
                            (see --threshold-arg)
            otsu-global     Otsu with automatic global thresholds
            otsu-local      Otsu with localized thresholds
                                    
    -a/--threshold-arg <arg>            add positional arguments associated with the
                                        threshold method
                                    
            <method>        example
            --------------  ----------------------------------------------------------
            manual          -a <low-value> -a <high-value>

    -1/--output-threshold <filepath>    after applying the threshold filter, write the
                                        intermediate image to a TIFF file
    
    --disable-opening                   do NOT perform the morphological opening step
    -2/--output-opening <filepath>      after applying the morphological opening filter, write
                                        the intermediate image to a TIFF file
    
    --disable-skeletonize               do NOT perform the skeletonize step


```

Each of the stages of the pipeline can be disabled using the appropriate `--disable-*` flag; for example, to only apply the skeletonize operation, `--disable-threshold --disable-opening` would be used on the command line.

Each of the intermediate stages includes an option to request output of the image to a TIFF file.  This allows the result of all stages of the pipeline to be captured.  The destination of the final image is communicated using the `--output` option.

By default, the script creates a temporary file to contain the ImageJ macro it writes.  This file is normally removed after ImageJ is executed, but the macro can be retained by use of the `--save-macro-file` option.

### Threshold

The original Windows workflow had multiple options for the threshold phase of the pipeline.  Each of these methods has been included in [imagej-filter](./imagej-filter).  The `default`, `otsu-global`, and `otsu-local` methods require no addtional options; however, the `manual` method requires two gray level values.  These are communicated to the macro using the `--threshold-arg` option.  Arguments are provided to the macro in the order they appear on the command line.  Thus, for a manual threshold with low threshold of 50 and high threshold of 200:

```
$ imagej-filter ... \
    --threshold-method=manual --threshold-arg=50 --threshold-arg=50 \
    ...
```

or using short form of the flags:

```
$ imagej-filter ... \
    -t manual -a 50 -a 50 \
    ...
```

## Example

Usimg the horse TIFFs as an example:

```
$ pwd
...../ThresholdAndSkeletonize

$ imagej-filter --verbose --input=horse.tif --output=horse-skel.tif
INFO:   input file horse.tif exists
INFO:   threshold method default is ok
INFO:   generating macro file /tmp/tmp.zsNnpBj69u with content:
INFO:       args = split(getArgument()," ");
INFO:       open(args[0]);
INFO:       print("IMAGEJ: Read initial image from ....../ThresholdAndSkeletonize/horse.tif");
INFO:       print("IMAGEJ: Applying threshold filter default");
INFO:       run("Make Binary", "method=Default background=Default calculate black");
INFO:       print("IMAGEJ: Applying morphological opening filter");
INFO:       run("Open", "stack");
INFO:       print("IMAGEJ: Forcing to 8-bit pixel format");
INFO:       run("8-bit");
INFO:       print("IMAGEJ: Applying skeletonize filter");
INFO:       run("Skeletonize (2D/3D)");
INFO:       print("IMAGEJ: Saving final output to ....../ThresholdAndSkeletonize/horse-skel.tif");
INFO:       saveAs("Tiff", args[1]);
INFO:       eval("script", "System.exit(0);");
INFO:       
INFO:   executing ImageJ macro command:
INFO:       ImageJ-linux64 --headless -macro "/tmp/tmp.zsNnpBj69u" ....../ThresholdAndSkeletonize/horse.tif ....../ThresholdAndSkeletonize/horse-skel.tif 
OpenJDK 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
OpenJDK 64-Bit Server VM warning: Using incremental CMS is deprecated and will likely be removed in a future release
IMAGEJ: Read initial image from ....../ThresholdAndSkeletonize/horse.tif
IMAGEJ: Applying threshold filter default
IMAGEJ: Applying morphological opening filter
IMAGEJ: Forcing to 8-bit pixel format
IMAGEJ: Applying skeletonize filter
IMAGEJ: Saving final output to ....../ThresholdAndSkeletonize/horse-skel.tif
INFO:   removed macro file /tmp/tmp.zsNnpBj69u
INFO:   execution complete

$ ls -l
total 25
-rw-r--r-- 1 frey it_nss 114672 Oct  6 21:58 horse-skel.tif
-rw-r--r-- 1 frey it_nss 119362 Oct  6 21:58 horse.tif
```

All of the phases of the pipeline were applied in sequence, and the default threshold method was used.
