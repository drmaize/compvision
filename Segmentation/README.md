# Segmentation with DeepXScope
Segmentation is the process of taking an image and extracting the pixels of objects of interest. The input is an image (or stack of images), and the output is a gray-scale image (or stack of images) where the pixel intensity represents the confidence that a pixel is the object of interest. These confidence values are then thresholded and futher processed to obtain a binary image (or stack of images). 

DeepXScope is a U-net based network trained to extract cells and stomates from a surface image, and fungal hyphae networks in image stacks. It is implemented in Python 3.6 with the Keras framework version 2.0.8, built on TensorFlow 1.5 with cuDNN 11. The release contains the requirements.txt for installing the Python packages.

Python 3.6: https://www.python.org/downloads/release/python-360/

TensorFlow 1.5 can be installed via pip, which comes with Python 3.6:

```pip3 install tensorflow==1.5```

We tested on a machine with Nvidia GTX 1080, and used cuDNN version 11: 

https://developer.nvidia.com/cudnn

Finally, the required Python packages can be installed via pip and the provided requirements.txt file with 

```pip install -r requirements.txt```

Once everything is installed, DeepXScope can be used by calling the SegmentObjects.py file

```python3 SegmentObjects.py -i in_path -o out_path -a architecture_path -w weights_path -n normalization_factor -nc clip_value```

The architecture and weights files can be downloaded from the release: https://github.com/drmaize/compvision/releases/tag/1.00

The full list of parameters is given below and can be passed in any order:

-i in_path: required. Path to image or .tiff image stack to process. Image stacks will be processed slice by slice automatically

-o out_path: required. Path to save result to. Image stacks should be saved as .tiff

-a architecture_path: required. Path to model architecture in .json format from Keras. Our models are included in the release

-w weights_path: required. Path to model weights in .h5 file from Keras. Our models are included in the release.

-n normalization_factor. optional. The input image pixels are divided by this value to normalize the pixel range. Default is to use the image mean. We used 120 for cell/stomates and 1 for fungus.

-nc clip_value. optional. Will clip image pixels that lie above the clip_value. Default is 1. We use 1 for cell/stomates and 255 for fungus.

An example from our data is 

```python3 SegmentObjects.py -i D:\drmaize\FullSegmentation\test_images\e025SLBp01wA5x20_1610041600rl001_surface.png -o D:\drmaize\FullSegmentation\e025SLBp01wA5x20_1610041600rl001_surface.png -a D:\drmaize\FullSegmentation\cell_architecture.json -w D:\drmaize\FullSegmentation\cell_weights.h5```
