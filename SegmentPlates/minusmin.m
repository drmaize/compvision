function subMin = minusmin( image )
%This function takes an image and computes the minimum color channel and
%then subtracts every channel from this minimum
minpic = min(image,[],3);
subMin = image - cat(3,minpic,minpic,minpic);

end

