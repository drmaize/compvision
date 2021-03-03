# Overview of Computer Vision Resources for Dr Maize
The Dr. Maize project images fungal pathogens in maize for the purposes of measuring the pathogen behavior and interaction. To this end, many automatic computer vision methods were developed in a pipeline of tasks for this analysis. The CV capabilities include surface estimation, image/stack segmentation (cells, fungi, stomata, spores), skeletonization, and quantitative measurement calculations. These tools are available via source code which is freely downloadable and runnable, or via packaged releases for each component that includes an installer and necessary components to run.

# Licensing and Access
- The DrMaize CV code is released under a GNU GPLv3 open source license.
- The source code is released on GitHub: https://github.com/drmaize/compvision
- The dependencies vary for each module and are listed in their respective sections, but in a future update we will release with Docker. 
- The runable executables and installers are available on GitHub: https://github.com/drmaize/compvision/releases/tag/1.00
- The deep learning weights and models are also available on GitHub: https://github.com/drmaize/compvision/releases/tag/1.00

# Surface Estimation

# Segmentation with DeepXScope

# Skeleton Connection
Segmentation of an object from an image or stack is not always perfect. Imperfections in the data itself (shading, non-uniform staining, occlusions, etc) or failures in the algorithm can cause small gaps when skeletonizing, and this can drastically alter quantification results (number of fungal networks, size of the networks, etc). To mitigate this, we release this Skeleton Connector that relies on a minimum spanning tree based algorithm to connect gaps in a skeleton network. This code will work on any dimensional data (1D line, 2D image, 3D stack, ..., ND, etc)

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

```./SkeletonConnectCode.exe myStackIn.tif outStack.tif```

 
The full list of parameters is given below and must be passed in order:

ConnectSkeleton(in_filename, out_filename, gap_length, scale, endpointsOnly, window_sz, Verbose)
-in_filename: required. path to Nd skeleton to process

-out_filename: required. path to write the results

-gap_length (optional): a single number representing
 the furthest gap the algorithm will connect. Default 50

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

-verbose (optional): a logical flag (0 or 1) that determines if the
 program prints to the screen its progress. Default 1


# Citations of our work
1) [P. Saponaro et al., "DeepXScope: Segmenting Microscopy Images with a Deep Neural Network," 2017 IEEE Conference on Computer Vision and Pattern Recognition Workshops (CVPRW), Honolulu, HI, 2017, pp. 843-850, doi: 10.1109/CVPRW.2017.117.](http://openaccess.thecvf.com/content_cvpr_2017_workshops/w8/papers/Saponaro_DeepXScope_Segmenting_Microscopy_CVPR_2017_paper.pdf)

2) [P. Saponaro et al., "Three-dimensional segmentation of vesicular networks of fungal hyphae in macroscopic microscopy image stacks," 2017 IEEE International Conference on Image Processing (ICIP), Beijing, China, 2017, pp. 3285-3289, doi: 10.1109/ICIP.2017.8296890.](https://ieeexplore.ieee.org/iel7/8267582/8296222/08296890.pdf)

## Bibtex 
1) 
 ``` @INPROCEEDINGS{8014851,
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
 ```@INPROCEEDINGS{8296890,
  author={P. {Saponaro} and W. {Treible} and A. {Kolagunda} and S. {Rhein} and J. {Caplan} and C. {Kambhamettu} and R. {Wisser}},
  booktitle={2017 IEEE International Conference on Image Processing (ICIP)}, 
  title={Three-dimensional segmentation of vesicular networks of fungal hyphae in macroscopic microscopy image stacks}, 
  year={2017},
  volume={},
  number={},
  pages={3285-3289},
  doi={10.1109/ICIP.2017.8296890}}
  ```

  


