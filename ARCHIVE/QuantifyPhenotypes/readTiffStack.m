%Takes a filename of a .tif and reads in the slices to a 3D matrix.

function [ slices ] = readTiffStack(filename)

fname = filename;
info = imfinfo(fname);
num_images = numel(info);
slice_one = imread(fname, 1, 'Info', info);
slices = zeros(size(slice_one,1), size(slice_one, 2), num_images);
slices(:,:,1) = slice_one;
for k = 2:num_images
    slices(:,:,k) = imread(fname, k, 'Info', info);
end
slices = uint8(slices);

end

