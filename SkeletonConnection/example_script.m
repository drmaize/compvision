clear; close all; clc;

%Read the 3D stack containing a skeleton

in_pth = './example_stack/example_skel.tif';
out_pth = 'D:\drmaize\quantitative_analysis\skeleton_connect_code\example_output\example_skeleton.tif';

%Set up parameters
gap_length = '30';
endpointsOnly = '2';
% scale = [2.6 2.6 1.2]; %x y z
scale = '[1 1 3]';
window_sz = '[100 100 300]';
Verbose = '1';

%Cal the MST algorithm on the skeleton
ConnectSkeleton(in_pth, out_pth, gap_length, scale, endpointsOnly, window_sz, Verbose);
