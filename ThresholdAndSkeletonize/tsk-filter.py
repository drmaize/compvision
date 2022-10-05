#
# tsk-filter.py
# Threshold and SKeletonize filter.  This Python script makes exclusive use of the
# scikit-image package to process the image frames read-in from a TIFF file.
#

import argparse
import os, sys, errno
import logging
from skimage.io import imread as sk_imread, imsave as sk_imsave
from skimage.util import img_as_bool as sk_img_as_bool, img_as_ubyte as sk_img_as_ubyte, img_as_uint as sk_img_as_uint
import numpy

def applyThresholdHysteresis(inImage, **kwargs):
    """Scikit-image 0.14 and newer include a hysteresis filter that uses a low and high threshold value to isolate connected features -- pixels valued between [low,high] are on when they are near pixels above high.  Arguments keyed by the strings 'low' and 'high' are required."""
    if 'low' not in kwargs:
        raise RuntimeError('Hysteresis threshold requires a `low` argument')
    if 'high' not in kwargs:
        raise RuntimeError('Hysteresis threshold requires a `high` argument')
    try:
        from skimage.filters import apply_hysteresis_threshold
    except:
        raise RuntimeError('your installed scikit-image does not include apply_hysteresis_threshold (0.14 required)')
    return apply_hysteresis_threshold(inImage, float(kwargs['low']), float(kwargs['high']))

def applyThresholdMean(inImage, **kwargs):
    """Apply the scikit-image mean threshold filter.  No arguments available."""
    from skimage.filters import threshold_mean
    return (inImage > threshold_mean(inImage))

def applyThresholdOtsu(inImage, **kwargs):
    """Apply the scikit-image OTSU threshold filter.  No arguments available."""
    from skimage.filters import threshold_otsu
    return (inImage > threshold_otsu(inImage))

def applyThresholdMinimum(inImage, **kwargs):
    """Apply the scikit-image minimum threshold filter.  No arguments available."""
    from skimage.filters import threshold_minimum
    return (inImage > threshold_minimum(inImage))

def applyThresholdBasic(inImage, **kwargs):
    """Basic filter that maps values below a threshold value to the pixel minimum value, otherwise to the pixel maximum value.  A 'cutoff' argument is required."""
    if 'cutoff' not in kwargs:
        raise RuntimeError('Basic threshold requires a `cutoff` argument')
    repInfo = numpy.iinfo(inImage.dtype)
    minPixel = inImage.dtype.type(repInfo.min)
    maxPixel = inImage.dtype.type(repInfo.max)
    if kwargs['cutoff'].endswith('%'):
        pct = 0.01 * float(kwargs['cutoff'][:-1])
        cutoff = inImage.dtype.type(pct * repInfo.max + (1.00 - pct) * repInfo.min)
    else:
        cutoff = inImage.dtype.type(float(kwargs['cutoff']))
    logging.info('Basic threshold cutoff of %s in range [%s,%s] used', str(cutoff), str(minPixel), str(maxPixel))
    def f(x):
        return (x >= cutoff)
    return numpy.vectorize(f)(inImage)
    

cli_parser = argparse.ArgumentParser(description='Threshold and SKeletonize a TIFF image stack')
cli_parser.add_argument('--verbose', '-v',
        dest='verbosity',
        default=0,
        action='count',
        help='Increase the amount of output generated as the program executes')
cli_parser.add_argument('--quiet', '-q',
        dest='antiVerbosity',
        default=0,
        action='count',
        help='Decrease the amount of output generated as the program executes')
cli_parser.add_argument('--input', '-i', metavar='<filepath>',
        dest='inImage',
        required=True,
        help='The TIFF file containing 1 or more frames in an image stack')

cli_parser.add_argument('--input-info-only', '-I',
        dest='shouldShowInputInfoOnly',
        default=False,
        action='store_true',
        help='Only display information about the input image file then exit')
        
cli_parser.add_argument('--skip-threshold',
        dest='shouldSkipThreshold',
        default=False,
        action='store_true',
        help='Do not apply the threshold filter')
cli_parser.add_argument('--post-threshold-output', '-1', metavar='<filepath>',
        dest='outImagePostThreshold',
        help='Optional file to which the image should be written after threshold is applied')
cli_parser.add_argument('--threshold-type', '-t', metavar='<threshold-type>',
        dest='thresholdType',
        default='mean',
        choices=('basic', 'mean', 'otsu', 'minimum', 'hysteresis'),
        help='Type of threshold filter to apply to the input images:  [mean], basic, otsu, minimum, hysteresis')
cli_parser.add_argument('--threshold-args', '-T', metavar='key=value{,key=value,...}',
        dest='thresholdArgsString',
        default='',
        help="""Arguments to the select thresholding method as a comma-separated string of key-value pairs:

basic:         cutoff=<real, required>{%%}  with '%%' suffix = percent of native type range
hysteresis:    low=<real, required>, high=<real, required>
""")

cli_parser.add_argument('--skip-morphological-opening',
        dest='shouldSkipMorphologicalOpening',
        default=False,
        action='store_true',
        help='Do not apply the morphological opening filter')
cli_parser.add_argument('--post-morphological-opening-output', '-2', metavar='<filepath>',
        dest='outImagePostMorphologicalOpening',
        help='Optional file to which the image should be written after morophological opening is applied')
        
cli_parser.add_argument('--skip-skeletonize',
        dest='shouldSkipSkeletonize',
        default=False,
        action='store_true',
        help='Do not apply the skeletonize filter')
cli_parser.add_argument('--skeletonize-algorithm', '-S', metavar='<algorithm>',
        dest='skeletonizeAlgorithm',
        default=None,
        choices=('zhang', 'lee'),
        help='The skeletonize algorithm to use:  [zhang], lee')
        
cli_parser.add_argument('--output', '-o', metavar='<filepath>',
        dest='outImage',
        help='The file to which the final output image will be written')
cli_parser.add_argument('--output-depth', '-d', metavar='<bitdepth>',
        dest='outBitDepth',
        type=int,
        default=8,
        choices=(8, 16),
        help='Bit-depth of the output TIFF image: [8], 16')

cli_args = cli_parser.parse_args()

# Initilialize logging:
loggingLevel = max(0, min(1 - cli_args.antiVerbosity + cli_args.verbosity, 4))
logging.basicConfig(
        format='%(levelname)-8s : %(message)s',
        level=[logging.CRITICAL, logging.ERROR, logging.WARNING, logging.INFO, logging.DEBUG][loggingLevel])

# Does the input file exist?
if not os.path.isfile(cli_args.inImage):
    logging.error('ERROR:  input image file `%s` does not exist', cli_args.inImage)
    sys.exit(errno.EEXIST)
logging.debug('Input file `%s` exists', cli_args.inImage)

# Try to load the image:
try:
    inputImage = sk_imread(cli_args.inImage, plugin='tifffile')
    logging.debug('Image read from input file `%s`', cli_args.inImage)
except Exception as E:
    logging.error('ERROR:  unable to read image file `%s`: %s', cli_args.inImage, str(E))
    sys.exit(errno.EINVAL)

if cli_args.shouldShowInputInfoOnly:
    # Only summarize the input image then exit:
    sys.stdout.write('Input image:  width x height = {:d} x {:d}\n'.format(inputImage.shape[-2], inputImage.shape[-1]))
    sys.stdout.write('Input image:  frame count = {:d}\n'.format(1 if inputImage.ndim < 3 else inputImage.shape[0]))
    sys.stdout.write('Input image:  pixel type = {:s} ({:d} byte{:s})\n'.format(str(inputImage.dtype), inputImage.itemsize, '' if (inputImage.itemsize == 1) else 's'))
    sys.stdout.write('Input image:  pixel value range: [{:s}, {:s}]\n'.format(str(inputImage.min()), str(inputImage.max())))
    sys.exit(0)

# Summarize the input image if necessary:
logging.info('Input image:  width x height = %d x %d', inputImage.shape[-2], inputImage.shape[-1])
logging.info('Input image:  frame count = %d', 1 if inputImage.ndim < 3 else inputImage.shape[0])
logging.info('Input image:  pixel type = %s (%d byte%s)', str(inputImage.dtype), inputImage.itemsize, '' if (inputImage.itemsize == 1) else 's')
logging.info('Input image:  pixel value range: [%s, %s]', str(inputImage.min()), str(inputImage.max()))

# Ensure an output file was provided:
if not cli_args.outImage:
    logging.error('No output file was provided with -o/--output')
    sys.exit(errno.EINVAL)

if not cli_args.shouldSkipThreshold:
    # Step 1:  apply the threshold function
    fnName = 'applyThreshold' + cli_args.thresholdType.capitalize()
    import __main__
    thresholdFn = getattr(__main__, fnName)
    logging.debug('Found threshold function %s', fnName)

    # Attempt to parse any threshold arguments:
    if cli_args.thresholdArgsString:
        try:
            thresholdArgs = { parsedKey: parsedValue for (parsedKey, parsedValue) in
                                [ parsedKeyPair.split('=', 1) for parsedKeyPair in cli_args.thresholdArgsString.split(',') ]
                            }
        except Exception as E:
            logging.error('Unable to parse threshold argument string `%s`: %s', cli_args.thresholdArgsString, str(E))
            sys.exit(errno.EINVAL)
    else:
        thresholdArgs = {}

    try:
        inputImage = thresholdFn(inputImage, **thresholdArgs)
        logging.debug('Threshold filter `%s` applied', cli_args.thresholdType)
    except Exception as E:
        logging.error('Unable to apply threshold filter `%s`: %s', cli_args.thresholdType, str(E))
        sys.exit(errno.EINVAL)

    # If a snapshot is requested, write it out:
    if cli_args.outImagePostThreshold:
        try:
            sk_imsave(cli_args.outImagePostThreshold, sk_img_as_ubyte(inputImage), plugin='tifffile', check_contrast=False)
            logging.debug('Intermediate post-threshold image `%s` saved', cli_args.outImagePostThreshold)
        except Exception as E:
            logging.error('Failed to save intermediate post-threshold image file `%s`: %s', cli_args.outImagePostThreshold, str(E))
            sys.exit(errno.EINVAL)

if not cli_args.shouldSkipMorphologicalOpening:
    # Step 2:  perform "opening" morphology filter on the frames:
    try:
        from skimage.morphology import opening as sk_opening
        inputImage = sk_opening(inputImage)
    except Exception as E:
        logging.error('Failed to apply skeletonize filter: %s', str(E))
        sys.exit(EINVAL)
    logging.debug('Morphological opening filter applied')

    # If a snapshot is requested, write it out:
    if cli_args.outImagePostMorphologicalOpening:
        try:
            sk_imsave(cli_args.outImagePostMorphologicalOpening, sk_img_as_ubyte(inputImage), plugin='tifffile', check_contrast=False)
            logging.debug('Intermediate post-morphological opening image `%s` saved', cli_args.outImagePostMorphologicalOpening)
        except Exception as E:
            logging.error('Failed to save intermediate post-morphological opening image file `%s`: %s', cli_args.outImagePostMorphologicalOpening, str(E))
            sys.exit(errno.EINVAL)

if not cli_args.shouldSkipSkeletonize:
    # Step 3:  skeletonize the image
    try:
        from skimage.morphology import skeletonize
        # Skeletonize requires a boolean image:
        inputImage = skeletonize(sk_img_as_bool(inputImage), method=cli_args.skeletonizeAlgorithm)
    except Exception as E:
        logging.error('Failed to apply skeletonize filter: %s', str(E))
        sys.exit(errno.EINVAL)
    logging.debug('Skeletonize filter applied')

# Write final image to output file:
sk_img_as = { 8: sk_img_as_ubyte, 16: sk_img_as_uint }
try:
    sk_imsave(cli_args.outImage, sk_img_as[cli_args.outBitDepth](inputImage), plugin='tifffile', check_contrast=False)
    logging.debug('Final image `%s` saved', cli_args.outImage)
except Exception as E:
    logging.error('Failed to save final image file `%s`: %s', cli_args.outImage, str(E))
    sys.exit(errno.EINVAL)

