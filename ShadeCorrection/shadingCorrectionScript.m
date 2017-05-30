path = ['/mnt/data27/wisser/drmaize/image_data/',experiment,'/microimages/reconstructed/'];

rot=0;
    fname1 = [path,'exp',experiment,'p',plt,'w',well,timestamp,'rl001.ome.tif']; %input leaf channel image
    sname1 = [path,'exp',experiment,'p',plt,'w',well,timestamp,'rl001.tif']; %shade corrected leaf channel image
    fname2 = [path,'exp',experiment,'p',plt,'w',well,timestamp,'rf001.ome.tif']; %input fungal channel image
    sname2 = [path,'exp',experiment,'p',plt,'w',well,timestamp,'rf001.tif']; %shade corrected fungal channel image
    
    info = imfinfo(fname1);
    for i=1:numel(info)
        img1 = double(imread(fname1,i));
        [~, shading] = shadingCorrection(img1,10,rot,10,round(256*0.08),3.5);
        shading = padarray(shading,(size(img1)-size(shading))/2,'replicate');
        shading = imrotate(double(shading),-rot,'crop');
        imgt = max(0,log(img1));
        imgs = imgt - shading;
        imgs = exp(imgs - mean2(imgs) + mean2(imgt));
        imgs(shading==0) = img1(shading==0);
        imgs(img1>=250) = img1(img1>=250);
        imgs = uint8(min(255,imgs));
        imwrite(imgs,sname1,'tif', 'Compression', 'none', 'WriteMode', 'append');
        
        img1 = double(imread(fname2,i));
        [~, shading] = shadingCorrection(img1,5,rot,10,round(256*0.08),3.5);
        shading = padarray(shading,(size(img1)-size(shading))/2,'replicate');
        shading = imrotate(double(shading),-rot,'crop');
        imgt = max(0,log(img1));
        imgs = imgt - shading;
        imgs = exp(imgs - mean2(imgs) + mean2(imgt));
        imgs(shading==0) = img1(shading==0);
        imgs(img1>=250) = img1(img1>=250);
        imgs = uint8(min(255,imgs));
        imwrite(imgs,sname2,'tif', 'Compression', 'none', 'WriteMode', 'append');
        
    end
quit
