function binImage = customThresh( image,thresharr,varargin)
%CUSTOMTHRESH applies a custom threshold per channel to an image
%   the thresharr contains an array of channel thresholds. an a
if nargin < 3
    gl = [1,1,1];
else
    gl = varargin{1};
end

%c1
if gl(1) == 1;
    c1 = image(:,:,1)>=thresharr(1);
else
    c1 = image(:,:,1)<=thresharr(1);
end

%c2
if gl(2) == 1;
    c2 = image(:,:,2)>=thresharr(2);
else
    c2 = image(:,:,2)<=thresharr(2);
end

%c3
if gl(3) == 1;
    c3 = image(:,:,3)>=thresharr(3);
else
    c3 = image(:,:,3)<=thresharr(3);
end

binImage = and(c1,and(c2,c3));

end

