# Skeleton Connection
Segmentation of an object from an image or stack is not always perfect. Imperfections in the data itself (shading, non-uniform staining, occlusions, etc) or failures in the algorithm can cause small gaps when skeletonizing, and this can drastically alter quantification results (number of fungal networks, size of the networks, etc). To mitigate this, we release this Skeleton Connector that relies on a minimum spanning tree based algorithm to connect gaps in a skeleton network. This code will work on any dimensional data (1D line, 2D image, 3D stack, ..., ND, etc)

This was developed in Matlab 2017 and tested recently on Matlab 2019b on a 64-bit Windows 10 machine, as well as Matlab 2021a on Ubuntu 20.04. The stand-alone installer does not require Matlab, but does require 64-bit Windows 10 or Ubuntu. Once the program is installed it can be run by calling the .exe with an input and output file location, e.g.

For Windows: ```./SkeletonConnectCode.exe myStackIn.tif outStack.tif```  
For Linux: ```./run_ConnectSkeleton.sh /usr/local/MATLAB//MATLAB_Runtime/v910/ myStackIn.tif utStack.tif```  
where /usr/local/MATLAB/MATLAB_Runtime/v910 is the path to the Matlab Runtime installed (requirement for Linux only). 
The full list of parameters is given below and must be passed in order as strings:

-in_filename: required. path to Nd skeleton to process

-out_filename: required. path to write the results

-gap_length (optional): a single number representing
 the furthest gap the algorithm will connect in pixels. Default 50. Warning: setting this high can slow down computation

-scale (optional): a 1xN array, where N is the dimension of bw
 containing the scale in each dimension. Used to weight each dimension differently for gap length, e.g for the example below [1 1 3] means that pixels in the Z dimension cost 3x the distance and therefore a gap length of 10 will be the max in the Z dimension. . Useful for medical or
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



```.\SkeletonConnectCode.exe myStackIn.tif outStack.tif "30" "[1 1 3]" "2" "[100 100 100]"```
