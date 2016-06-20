
% Only change this 
%combined_file = 'e025SLB_P1_001';
%suffix = 3; % (i.e. 001 at the end of the combined_file name)
%rows = 3;

% To label samples...
well_letters = {'A' 'B' 'C' 'D'};
well_numbers = {'1' '2' '3' '4' '5' '6'};
well_numbers = well_numbers(1:rows);

%Check that command line args have been passed
if exist('combined_file') == 0
   fprintf('No combined file name entered. Exiting... \n')
   return
end
if exist('suffix') == 0
   fprintf('No file suffix (for removal) entered. Exiting... \n')
   return
end

% Build filename
filename = [combined_file '.tif'];

% Read in original image and scale down for processing
im_orig = imread(filename);
scale_factor = 0.1;
im = imresize(im_orig, scale_factor);

% Padding for the bounding box
bbox_padding = [-10 -10 10 10];

% Use Scott's RGBi to segment leaves
rthresh = 9.9;
gthresh = 8.5;
bthresh = 0;
mimage = minusmin(im);
mask = filterBW(customThresh(mimage,[rthresh,gthresh,bthresh]));

% Generate Region properties
props = regionprops(mask, 'BoundingBox', 'Centroid');

% Generate Centroid Matrix
centers = [];
for ii=1:size(props,1)
    centers = [centers; props(ii).Centroid];
end

% Sort Centers
cx = centers(:,1);
[~,idx] = sort(cx);
cx = cx(idx,:);
cy = centers(:,2);
[~,idy] = sort(cy);
cy = cy(idy,:);

for ii=1:size(props,1)
    
    % Calculate bounding box and give it some padding
    bbox = props(ii).BoundingBox + bbox_padding;
    
    % Calculate well position via centroid
    centroid = props(ii).Centroid;
    
    % Generate Label string
    [~,x] = ismember(centroid(1), cx);
    [~,y] = ismember(centroid(2), cy);
    well_letter = well_letters{ceil(x/size(well_numbers,2))};
    well_number = well_numbers{ceil(y/size(well_letters,2))};
    
    fprintf('Well: %s%s\n', well_letter, well_number);
    
    % Calculate angle of tilt w/hough tform
    cim = imcrop(im, bbox);
    Igray = double(rgb2gray(cim));
    BW = edge(Igray,'canny');
    [H, theta, rho] = hough(BW);
    peak = houghpeaks(H);
    barAngle = theta(peak(2));
    
    % Correct if trying to rotate too much
    if barAngle > 45
       barAngle = 90-barAngle; 
    elseif barAngle < -45
        barAngle = 90+barAngle; 
    end
    
    fprintf('Estimated angle of tilt: %d\n', barAngle);

    %Crop and rotate original image
    bbox_orig = (1/scale_factor).*bbox;
    cim_orig = imcrop(im_orig, bbox_orig);
    rim_orig = imrotate(cim_orig,barAngle,'bilinear');

    % Make imrotate background white
    Mrot = ~imrotate(true(size(cim_orig)),barAngle);
    rim_orig(Mrot&~imclearborder(Mrot)) = 255;
    
    % Build filename and write file
    fn = [combined_file(1:end-suffix) '_W_' well_letter well_number '.tif'];
    fn = strrep(fn, '_', '');
    imwrite(rim_orig, fn);
    fprintf('Wrote file: %s\n\n', fn);

end
