# Thresholding and Skeletonizing
Thresholding is the process of converting a grayscale image into a binary one. This represents the final "decision" about which pixels belong to the object, and which are part of the background. Thresholding can be performed in a myriad of ways and many tools already exist for performing thresholding. Skeletonization is the task of taking a binary image and finding the thinnest representation/skeleton belonging to the objects in that image. 

Here, we present scripts and Windows batch commands to call Fiji ImageJ thresholding and skeletonization functionality. Fiji ImageJ can be found here: https://imagej.net/Fiji/Downloads. A description of Fiji ImageJ's automatic thresholding options are here: https://imagej.net/Auto_Threshold

We tested our Fiji ImageJ scripts and batch commands on 64-bit Windows 10. 

To perform the default auto-thresholding algorithm, run the following from the command line:

```.\threshold_default.bat input_path output_path ``` 

To perform Otsu's auto-thresholding algorithm, run the following from the command line:

```.\threshold_otsu_global.bat input_path output_path ``` 

To perform a mnaual thresholding, run the following from the command line, where low and high are between [0-255]:

```.\threshold_manual.bat input_path output_path low_value high_value```

To remove small objects via Morphological Opening (noise or very tiny detections that should not be counted), run the following command:

```.\removeSmallDetections.bat input_path output_path```

Finally to perform Skeletonization, run the following commnand:

```.\skeletonize.bat input_path output_path```

Skeletonization uses the (built-in) plug-in Skeletonize3d found here: https://imagejdocu.tudor.lu/doku.php?id=plugin:morphology:skeletonize3d:start

