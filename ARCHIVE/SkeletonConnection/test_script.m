clear; close all; clc;

%Read the 3D stack containing a skeleton
pth = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\test_skel_connected\xy_yz_xz_combine_tests/skeletonize/';
img_name = 'e013SLBp03wA1x20_1505041720rf001_LAS3.tif';
stack = readStack(img_name,pth);
stack_temp = zeros(size(stack));
stack = stack(30:end-30, 30:end-30, 5:end-5);
stack_temp(30:end-30, 30:end-30, 5:end-5) = stack;
stack = stack_temp;
stack = bwareaopen(stack,10);

out_pth = 'Z:\image_data\e013SLB\microimages\reconstructed\HS\phil_results\test_skel_connected\xy_yz_xz_combine_tests\skeleton_connected_30_1_1_3\';

%Set up parameters
gap_length = 30;
endpointsOnly = 2;
% scale = [2.6 2.6 1.2]; %x y z
scale = [1 1 3];
window_sz = round(scale*100);
Verbose = 1;

%Cal the MST algorithm on the skeleton
skeleton = logical(stack);
skeleton = bwareaopen(skeleton,5);
tic;
bw_conn = Connect_MST_ND(skeleton, gap_length, scale, endpointsOnly, window_sz, Verbose);
t = toc();
disp(['The MST algorithm took ' num2str(t) 's to process the ' num2str(size(skeleton)) ' size array']);

%Display results
if(length(size(skeleton)) == 3)
    figure;
    l = find(skeleton); [r c z] = ind2sub(size(skeleton), l); plot3(r*2.6, c*2.6, z*1.2, 'r.');
    hold on;
    l2 = find(bw_conn & ~skeleton); [r c z] = ind2sub(size(bw_conn), l2);plot3(r*2.6, c*2.6, z*1.2, 'b.');
    ax = gca; 
    ax.Clipping = 'off';
else
    figure;
    l = find(skeleton); [r c] = ind2sub(size(skeleton), l); plot(r*2.6, c*2.6, 'r.');
    hold on;
    l2 = find(bw_conn & ~skeleton); [r c] = ind2sub(size(bw_conn), l2);plot(r*2.6, c*2.6, 'b.');
    ax = gca; 
    ax.Clipping = 'off';
end

write_skeletal(double(bw_conn), [out_pth img_name]);
write_skeletal(double(bw_conn & ~skeleton), [out_pth img_name(1:end-4) '_new_connects.tif']);

