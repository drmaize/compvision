%Given a grayscale image, convert to a color image
%Color is a [r g b] 1D vector

function [colorImage] = convertToColor(img, color)

colorImage = zeros(size(img,1), size(img,2), 3);
colorImage(:,:,1) = img*color(1);
colorImage(:,:,2) = img*color(2);
colorImage(:,:,3) = img*color(3);

end

