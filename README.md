# Overview of Computer Vision Resources for Dr Maize
The Dr. Maize project images fungal pathogens in maize for the purposes of measuring the pathogen behavior and interaction. To this end, many automatic computer vision methods were developed in a pipeline of tasks for this analysis. The CV capabilities include surface estimation, image/stack segmentation (cells, fungi, stomata, spores), skeletonization, and quantitative measurement calculations. These tools are available via source code which is freely downloadable and runnable, or via packaged releases for each component that includes an installer and necessary components to run.

# Licensing and Access
- The DrMaize CV code is released under a GNU GPLv3 open source license.
- The source code is released on GitHub: https://github.com/drmaize/compvision
- The dependencies vary for each module and are listed in their respective sections, but in a future update we will release with Docker. 
- The runable executables and installers are available on GitHub: https://github.com/drmaize/compvision/releases/tag/1.00
- The deep learning weights and models are also available on GitHub: https://github.com/drmaize/compvision/releases/tag/1.00
- Fiji ImageJ can be found: https://imagej.net/Fiji/Downloads

# Surface Estimation
Surface estimation is the process of taking a 3D stack and finding the depth of the surface for each pixel in a 2D view from above. This allows quantification of the depth of the pathogen and quantification of features that lie on the surface of the plant (e.g. stomata segmentation and locations). We use an active contour/snake optimization with uniformly initialized control points to perform this. 

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

```./SurfaceEstimation.exe myStackIn.tif out```

The program will create two files: out.png and out.txt which contains the surface image and the surface depth values.

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

The full list of parameters is given below and can be passed in any order:

-i in_path: required. Path to image or .tiff image stack to process. Image stacks will be processed slice by slice automatically

-o out_path: required. Path to save result to. Image stacks should be saved as .tiff

-a architecture_path: required. Path to model architecture in .json format from Keras. Our models are included in the release

-w weights_path: required. Path to model weights in .h5 file from Keras. Our models are included in the release.

-n normalization_factor. optional. The input image pixels are divided by this value to normalize the pixel range. Default is to use the image mean. We used 120 for cell/stomates and 1 for fungus.

-nc clip_value. optional. Will clip image pixels that lie above the clip_value. Default is 1. We use 1 for cell/stomates and 255 for fungus.

An example from our data is 

```python3 SegmentObjects.py -i D:\drmaize\FullSegmentation\test_images\e025SLBp01wA5x20_1610041600rl001_surface.png -o D:\drmaize\FullSegmentation\e025SLBp01wA5x20_1610041600rl001_surface.png -a D:\drmaize\FullSegmentation\cell_architecture.json -w D:\drmaize\FullSegmentation\cell_weights.h5```

# Thresholding and Skeletonizing
Thresholding is the process of converting a grayscale image into a binary one. This represents the final "decision" about which pixels belong to the object, and which are part of the background. Skeletonization is the task of taking a binary image and finding the thinnest representation/skeleton belonging to the objects in that image. 

Here, we present scripts and Windows batch commands to call Fiji ImageJ thresholding and skeletonization functionality. Fiji ImageJ can be found here: https://imagej.net/Fiji/Downloads. A description of Fiji ImageJ's automatic thresholding options are here: https://imagej.net/Auto_Threshold

We tested our Fiji ImageJ scripts and batch commands on 64-bit Windows 10. 

To perform the default auto-thresholding algorithm, run the following from the command line:

```.\threshold.bat input_path output_path ``` 

To perform Otsu's auto-thresholding algorithm, run the following from the command line:

```.\threshold_otsu_global.bat input_path output_path ``` 

To perform a mnaual thresholding, run the following from the command line, where low and high are between [0-255]:

```.\threshold_manual.bat input_path output_path low_value high_value```

To remove small objects via Morphological Opening (noise or very tiny detections that should not be counted), run the following command:

```.\removeSmallDetections.bat input_path output_path```

Finally to perform Skeletonization, run the following commnand:

```.\skeletonize.bat input_path output_path```

Skeletonization uses the (built-in) plug-in Skeletonize3d found here: https://imagejdocu.tudor.lu/doku.php?id=plugin:morphology:skeletonize3d:start

# Skeleton Connection
Segmentation of an object from an image or stack is not always perfect. Imperfections in the data itself (shading, non-uniform staining, occlusions, etc) or failures in the algorithm can cause small gaps when skeletonizing, and this can drastically alter quantification results (number of fungal networks, size of the networks, etc). To mitigate this, we release this Skeleton Connector that relies on a minimum spanning tree based algorithm to connect gaps in a skeleton network. This code will work on any dimensional data (1D line, 2D image, 3D stack, ..., ND, etc)

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

```./SkeletonConnectCode.exe myStackIn.tif outStack.tif```

The full list of parameters is given below and must be passed in order as strings:

-in_filename: required. path to Nd skeleton to process

-out_filename: required. path to write the results

-gap_length (optional): a single number representing
 the furthest gap the algorithm will connect in pixels. Default 50. Warning: setting this high can slow down computation

-scale (optional): a 1xN array, where N is the dimension of bw
 containing the scale in each dimension. Useful for medical or
 biological data where the scan resolution is different in the z
 dimension. Default all 1s

-endpointsOnly (optional): a (nonlogical) flag. If the flag is set to 1,
 only endpoints can be connected -- fast. If set to 0, the algorithm will
 connect any points, slower, especially on large skeletons.
 If the flag is set to 2, connections between points must include at
 at least 1 endpoint, also slower. Default 2

-window_sz (optional): a 1xN array, where N is the dimension of bw,
 containing a window size of how to break up the original bw array.
 Useful if the original bw array is very large in memory.
 Set all values <= 1 to run on the entire array. Default is all 30s

# Quantification of Phenotypes
The final goal of this software package is to provide statistics, numbers, and counts of physical features for each structure. The code in this section reads as input the segmented and thresholded skeletons from previous sections, and as output generates both a Microsoft Excel spreadsheet and images. The spreadsheet contains a section for each structure of interest and uses a user-provided ID to append new detected structures and their attributes. 

This was developed and tested in Matlab 2019b on Windows 10 64 bit.  The stand-alone installer does not require Matlab, but does require 64-bit Windows 10. Once the program is installed it can be run by calling the .exe with the following command


```.\QuantifyPhenotypes.exe "sample_identifier_string" "path_to_cells_skeleton.png" "path_to_stomates_skeleton.png" "path_to_fungus_skeleton.tif" "path_to_surface_map.txt" "path_to_surface_image.png" "penetration_depth_threshold" "[scalex scaley scalez]" "output_results.xlsx" "output_results_visualization.png"   ```

where 

--sample_identifier_string is a string to uniquely identify the sample. This is used in the Excel Spreadsheet to distinguish numbers from different samples. E.G "e013SLBp03wA1x20_1505041720rf001"

--path_to_cells_skeleton.png is the path to the segmented and skeletonized cell image generated from a previous section

--path_to_stomates_skeleton.png is the path to the segmented and skeletonized stomata image generated from a previous section

--path_to_fungal_skeleton.tif is the path to the segmented and skeletonized fungal 3D stack generated from a previous section

--path_to_surface_map.txt is the path to the surace map generated from a previous section

--path_to_surface_image.png is the path to the surace image generated from a previous section

--penetration_depth_threshold is the number of slices beneath a surface the fungus must penetrate to be considered a true penetration event. To eliminate noise and mis-labelings.

--[scalex scaley scalez] is the pixels per um scalings. e.g we used [2.6 2.6 1.2] since 2.6 pixels make up 1um in the x,y directions and 1.2 in the depth/z direction

--output_results.xlsx is the path to store the Excel Worksheet

--output_results_visualization.png is the path to store overlay images created by the program.

All inputs are required. However, if a structure is missing in your application, leave the string blank. I.E instead of "path_to_stomates_skeleton.png" give "". If not all structures are given, only the Microsoft Worksheet will be created. This is because the overlay images require all the structures to be generated. 

# Citations of our work
1) [P. Saponaro et al., "DeepXScope: Segmenting Microscopy Images with a Deep Neural Network," 2017 IEEE Conference on Computer Vision and Pattern Recognition Workshops (CVPRW), Honolulu, HI, 2017, pp. 843-850, doi: 10.1109/CVPRW.2017.117.](http://openaccess.thecvf.com/content_cvpr_2017_workshops/w8/papers/Saponaro_DeepXScope_Segmenting_Microscopy_CVPR_2017_paper.pdf)

2) [P. Saponaro et al., "Three-dimensional segmentation of vesicular networks of fungal hyphae in macroscopic microscopy image stacks," 2017 IEEE International Conference on Image Processing (ICIP), Beijing, China, 2017, pp. 3285-3289, doi: 10.1109/ICIP.2017.8296890.](https://ieeexplore.ieee.org/iel7/8267582/8296222/08296890.pdf)

3) [Minker, K. R. et al. “Semiautomated confocal imaging of fungal pathogenesis on plants: Microscopic analysis of macroscopic specimens.” Microscopy Research and Technique 81 (2018): n. pag.](https://analyticalsciencejournals.onlinelibrary.wiley.com/doi/full/10.1002/jemt.22709)

4) [Kolagunda, Abhishek et al. “Detection of fungal spores in 3D microscopy images of macroscopic areas of host tissue.” 2016 IEEE International Conference on Bioinformatics and Biomedicine (BIBM) (2016): 479-483.](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7822564&tag=1)

## Bibtex 
1) 
 ``` 
 @INPROCEEDINGS{8014851,
  author={P. {Saponaro} and W. {Treible} and A. {Kolagunda} and T. {Chaya} and J. {Caplan} and C. {Kambhamettu} and R. {Wisser}},
  booktitle={2017 IEEE Conference on Computer Vision and Pattern Recognition Workshops (CVPRW)}, 
  title={DeepXScope: Segmenting Microscopy Images with a Deep Neural Network}, 
  year={2017},
  volume={},
  number={},
  pages={843-850},
  doi={10.1109/CVPRW.2017.117}}
  ```
2)
 ```
 @INPROCEEDINGS{8296890,
  author={P. {Saponaro} and W. {Treible} and A. {Kolagunda} and S. {Rhein} and J. {Caplan} and C. {Kambhamettu} and R. {Wisser}},
  booktitle={2017 IEEE International Conference on Image Processing (ICIP)}, 
  title={Three-dimensional segmentation of vesicular networks of fungal hyphae in macroscopic microscopy image stacks}, 
  year={2017},
  volume={},
  number={},
  pages={3285-3289},
  doi={10.1109/ICIP.2017.8296890}}
  ```
3)
```
@article{Minker2018SemiautomatedCI,
  title={Semiautomated confocal imaging of fungal pathogenesis on plants: Microscopic analysis of macroscopic specimens},
  author={K. R. Minker and M. Biedrzycki and Abhishek Kolagunda and Stephen Rhein and F. J. Perina and Samuel S. Jacobs and M. Moore and T. Jamann and Q. Yang and R. Nelson and P. Balint-Kurti and C. Kambhamettu and R. Wisser and J. Caplan},
  journal={Microscopy Research and Technique},
  year={2018},
  volume={81}}
  ```
4)
```
@article{Kolagunda2016DetectionOF,
  title={Detection of fungal spores in 3D microscopy images of macroscopic areas of host tissue},
  author={Abhishek Kolagunda and Randall Wisser and Timothy Chaya and J. Caplan and C. Kambhamettu},
  journal={2016 IEEE International Conference on Bioinformatics and Biomedicine (BIBM)},
  year={2016},
  pages={479-483}}
  ```
