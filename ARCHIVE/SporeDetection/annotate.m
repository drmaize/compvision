%% manually click on spores
clear;
close all;

experiment = '013SLB';
plt = '03';
well = 'B2';
path = ['Z:/image_data/',experiment,'/microimages/reconstructed/MIP/'];
timestamp = '';

img = imread([path,'exp',experiment,'p',plt,'w',well,timestamp,'rl001.tif']);
[img,~] = rotalignimage(img);
[x,y] = cropimage(img);
I2 = img(y(1)+500:y(2)-500,x(1)+500:x(2)-500);
I2 = imresize(I2,0.5);

x=[];
y=[];
for i=1:500:size(I2,1)-500
    for j=1:500:size(I2,2)-500
        imshow(I2(i:i+500,j:j+500));
        [tx,ty] = ginput();
        close;
        x = [x;tx+j-1];
        y = [y;ty+i-1];
    end
end

spore_pts = [x y];
save(strcat('spore_xy-','e',experiment,'p',plt,'w',well,'.mat'),'spore_pts');
