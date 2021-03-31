function [] = write_skeletal(skel, filename)

imwrite(skel(:,:,1), filename)
for k = 2:size(skel,3)
    imwrite(skel(:,:,k), filename, 'writemode', 'append');
end


end


