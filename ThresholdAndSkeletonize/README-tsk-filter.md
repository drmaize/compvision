# Threshold and SKeletonize Filter

The Windows Fiji scripts in this directory were used to construct a Python program that applies (hopefully!) the same transformations to a TIFF image (containing one or more layers, a *stack*).

## Prerequisites

The script makes use of the **scikit-image** package for Python, which in turn relies on **numpy** and several other large packages.  Version 0.19 or better is suggested for **scikit-image**.

On the Caviness cluster these dependencies were satisfied using an Anaconda virtual environment:

```
$ vpkg_require intel-oneapi/2022
$ mkdir -p "${WORKDIR}/sw/venv/scikit-image"
$ conda create --prefix="${WORKDIR}/sw/venv/scikit-image/0.19.2" scikit-image=0.19.2
   :
$ conda activate "${WORKDIR}/sw/venv/scikit-image/0.19.2"
```

## Usage

The program has built-in help accessible via the `-h` or `--help` flag:

```
$ python3 tsk-filter.py --help
usage: tsk-filter.py [-h] [--verbose] [--quiet] --input <filepath> [--input-info-only] [--skip-threshold]
                     [--post-threshold-output <filepath>] [--threshold-type <threshold-type>]
                     [--threshold-args key=value{,key=value,...}] [--skip-morphological-opening]
                     [--post-morphological-opening-output <filepath>] [--skip-skeletonize]
                     [--skeletonize-algorithm <algorithm>] [--output <filepath>] [--output-depth <bitdepth>]

Threshold and SKeletonize a TIFF image stack

optional arguments:
  -h, --help            show this help message and exit
  --verbose, -v         Increase the amount of output generated as the program executes
  --quiet, -q           Decrease the amount of output generated as the program executes
  --input <filepath>, -i <filepath>
                        The TIFF file containing 1 or more frames in an image stack
  --input-info-only, -I
                        Only display information about the input image file then exit
  --skip-threshold      Do not apply the threshold filter
  --post-threshold-output <filepath>, -1 <filepath>
                        Optional file to which the image should be written after threshold is applied
  --threshold-type <threshold-type>, -t <threshold-type>
                        Type of threshold filter to apply to the input images: [mean], basic, otsu, minimum, hysteresis
  --threshold-args key=value{,key=value,...}, -T key=value{,key=value,...}
                        Arguments to the select thresholding method as a comma-separated string of key-value pairs: basic:
                        cutoff=<real, required>{%} with '%' suffix = percent of native type range hysteresis: low=<real,
                        required>, high=<real, required>
  --skip-morphological-opening
                        Do not apply the morphological opening filter
  --post-morphological-opening-output <filepath>, -2 <filepath>
                        Optional file to which the image should be written after morophological opening is applied
  --skip-skeletonize    Do not apply the skeletonize filter
  --skeletonize-algorithm <algorithm>, -S <algorithm>
                        The skeletonize algorithm to use: [zhang], lee
  --output <filepath>, -o <filepath>
                        The file to which the final output image will be written
  --output-depth <bitdepth>, -d <bitdepth>
                        Bit-depth of the output TIFF image: [8], 16
```

There are three stages to the pipeline:

1. threshold:  transform the image from grayscale to black and white
2. morphological opening:  noise removal (small features, for example)
3. skeletonize:  reduce contiguous white areas of image to a 1-pixel wide representation

Any of these stages can be omitted from the pipeline, e.g. using the `--skip-morphological-opening` flag.  Intermediate images between the stages can be written to TIFF files, e.g. using the `--post-threshold-output` flag with a file name as its argument.

### Threshold Types

The program has several types of threshold algorithm selectable at runtime.

- **basic**:  given a `cutoff` argument, values less than the cutoff map to black and values equal to or greater than the cutoff map to white.  The cutoff can be specified as a pixel value (e.g. `100`) or a percentage of the range of pixel values for the image's native bit depth.  For example, an 8-bit grayscale image with `--threshold-type=basic --threshold-args=cutoff=25%` would imply a cutoff value of 64.
- **mean**:  see the [documentation for this method](https://scikit-image.org/docs/dev/api/skimage.filters.html#threshold-mean)
- **otsu**:  see the [documentation for this method](https://scikit-image.org/docs/dev/api/skimage.filters.html#threshold-otsu)
- **minimum**:  see the [documentation for this method](https://scikit-image.org/docs/dev/api/skimage.filters.html#threshold-minimum)
- **hysteresis**:  see the [documentation for this method](https://scikit-image.org/docs/dev/api/skimage.filters.html#skimage.filters.apply_hysteresis_threshold); there are two required arguments, `low` and `high` expressed as pixel values, e.g. `--threshold-type=hysteresis --threshold-args=low=25,high=125`

### Skeletonize Algorithm

The skeletonize function has two algorithms selectable at runtime using the `--skeletonize-algorithm` flag (see the [documentation here](https://scikit-image.org/docs/dev/api/skimage.morphology.html#skeletonize) for more info):

- **zhang**:  works for 2D only
- **lee**:  works for 2D or 3D

## Example

We will attempt to apply the pipeline to a clear versus blurry figure of a white horse on a black background.

### Clear image

```
$ python3 tsk-filter.py -i horse.tif -o horse-skel.tif -vvv
DEBUG    : Input file `horse.tif` exists
DEBUG    : Image read from input file `horse.tif`
INFO     : Input image:  width x height = 306 x 373
INFO     : Input image:  frame count = 1
INFO     : Input image:  pixel type = uint8 (1 byte)
INFO     : Input image:  pixel value range: [0, 255]
DEBUG    : Found threshold function applyThresholdMean
DEBUG    : Threshold filter `mean` applied
DEBUG    : Morphological opening filter applied
DEBUG    : Skeletonize filter applied
DEBUG    : Final image `horse-skel.tif` saved
```

This image comes from the skeletonize example for the scikit-image package.  All defaults are used for the pipeline and a clear 1-pixel skeleton results ([horse-skel.tif](./horse-skel.tif)).

### Blurred image

The original image was blurred and 8% noise was introduced in Adobe Photoshop to produce [horse-blur.tif](./horse-blur.tif).

Again using the default options for the pipeline:

```
$ python3 tsk-filter.py -i horse-blur.tif -o horse-blur-skel-default.tif -vvv 
DEBUG    : Input file `horse-blur.tif` exists
DEBUG    : Image read from input file `horse-blur.tif`
INFO     : Input image:  width x height = 306 x 373
INFO     : Input image:  frame count = 1
INFO     : Input image:  pixel type = uint8 (1 byte)
INFO     : Input image:  pixel value range: [0, 255]
DEBUG    : Found threshold function applyThresholdMean
DEBUG    : Threshold filter `mean` applied
DEBUG    : Morphological opening filter applied
DEBUG    : Skeletonize filter applied
DEBUG    : Final image `horse-blur-skel-default.tif` saved
```

That [1-pixel skeleton](./horse-blur-skel-default.tif) is no longer as clearly horse-shaped.  The noise and blur have interfered with the edge-finding capabilities of the skeletonize.  The Lee algorithm does [slightly better](./horse-blur-skel-lee.tif) (it's at least no longer looking like a unicorn!):

```
$ python3 tsk-filter.py -i horse-blur.tif -o horse-blur-skel-lee.tif -S lee
```

Let's instead try a basic threshold limiter with a cutoff at 70% intensity:

```
$ python3 tsk-filter.py -i horse-blur.tif -o horse-blur-skel-basic.tif -vvv -t basic -T cutoff=70% 
DEBUG    : Input file `horse-blur.tif` exists
DEBUG    : Image read from input file `horse-blur.tif`
INFO     : Input image:  width x height = 306 x 373
INFO     : Input image:  frame count = 1
INFO     : Input image:  pixel type = uint8 (1 byte)
INFO     : Input image:  pixel value range: [0, 255]
DEBUG    : Found threshold function applyThresholdBasic
INFO     : Basic threshold cutoff of 178 in range [0,255] used
DEBUG    : Threshold filter `basic` applied
DEBUG    : Morphological opening filter applied
DEBUG    : Skeletonize filter applied
DEBUG    : Final image `horse-blur-skel-basic.tif` saved
```

[That result](./horse-blur-skel-basic.tif) recovered a bit more of the original character of the image.

The hysteresis threshold splits pixel values into three regimes:

- intensity < low value:  pixel is black
- intensity >= high value:  pixel is white
- low value < intensity < high value:  pixel is white if adjoins another white pixel

Giving that a try:

```
$ python3 tsk-filter.py -i horse-blur.tif -o horse-blur-skel-hysteresis.tif -vvv -t hysteresis -T low=180,high=200
```

[The result](./horse-blur-skel-hysteresis.tif) is similar to the basic threshold example.