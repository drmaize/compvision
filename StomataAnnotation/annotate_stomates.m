lst = dir('F:\stomate_annotated_data\e025SLB\*surface.png');
num_blocks = 3;
for i=1:numel(lst)
    img = imread(['F:\stomate_annotated_data\e025SLB\',lst(i).name]);
    name = strsplit(lst(i).name,'_');
    name = [name{1},'_',name{2}];
    B_size = blockproc(img,floor(size(img)/num_blocks),@(block)size(block.data));
    B_location = blockproc(img,floor(size(img)/num_blocks),@(block)block.location);
    xs=[]; ys=[];
    for j=1:num_blocks
        for k=1:num_blocks
            imshow(img(B_location(j,2*(k-1)+1): B_location(j,2*(k-1)+1)+B_size(j,2*(k-1)+1)-1,...
                B_location(j,2*(k-1)+2):B_location(j,2*(k-1)+2)+B_size(j,2*(k-1)+2)-1));
            [x,y] = ginput(3);
            xs = [xs;x+B_location(j,2*(k-1)+2)-1]; ys = [ys;y+B_location(j,2*(k-1)+1)-1];
        end
    end
    close all;
    %     imshow(img); hold on; plot(xs,ys,'*'); pause;
    %     close all;
    
    patches=[];
    for j=1:numel(xs)
        patches = cat(3,patches,img(ys(j)-12:ys(j)+12,xs(j)-12:xs(j)+12));
    end
    
    res = normxcorr2(im2double(patches(:,:,1)),im2double(img));
    for j=2:size(patches,3)
        res = max(res,normxcorr2(im2double(patches(:,:,j)),im2double(img)));
    end
    
    rp = regionprops(imclose(bwareaopen(res>0.75,3),ones(3)),'centroid');
    centroids = cat(1,rp.Centroid);
    mask = false(size(img));
    mask(sub2ind(size(mask),round(centroids(:,2)-12),round(centroids(:,1)-12)))=true;
    mask = imdilate(mask,strel('disk',7));
    
    imwrite(mask,['F:\stomate_annotated_data\stomates5\',name,'_mask.png']);
end
%%

lst = dir('F:\stomate_annotated_data\stomates\images\*.png');

mask = false(48);
mask(24,24)=true;
mask = imdilate(mask,strel('disk',10));

for i=1:numel(lst)
    imwrite(mask,['F:\stomate_annotated_data\stomates\masks\',lst(i).name]);
end
%%

lst = dir('F:\stomate_annotated_data\*.png');

for i=1:numel(lst)
    img = imread(['F:\stomate_annotated_data\',lst(i).name]);
    name = strsplit(lst(i).name,'_');
    mname = [name{1},'_',name{2}];
    name = [name{1},name{2}];
    mask = false(size(img));
    msk = false(48);
    msk(24,24)=true;
    msk = imdilate(msk,strel('disk',10));
    
    lst2 =  dir(['F:\stomate_annotated_data\stomates\masks\',name,'*.png']);
    for j=1:numel(lst2)
        name2 = strsplit(lst2(j).name,'.');
        name2 = strsplit(name2{1},'_');
        x = str2double(name2{2});
        y = str2double(name2{3});
        mask(y-23:y+24,x-23:x+24) = msk;
    end
    imwrite(mask,['F:\stomate_annotated_data\',mname,'_mask.png']);
end

%%
lst = dir('F:\stomate_annotated_data\stomates5\*mask.png');
bg_mask = zeros(48);
for i=1:numel(lst)
    mask = im2double(imread(['F:\stomate_annotated_data\stomates5\',lst(i).name]));
    name = strsplit(lst(i).name,'.');
    name = strsplit(name{1},'_');
    fname = [name{1},'_',name{2}];
    name = [name{1},'_',name{2},'_surface.png'];
    img = im2double(imread(['F:\stomate_annotated_data\e025SLB\',name]));
    B_size = blockproc(img,[48,48],@(block)size(block.data));
    B_location = blockproc(img,[48,48],@(block)block.location);
    for j=1:floor(size(img,1)/48)
        for k=1:floor(size(img,2)/48)
            patch = img(B_location(j,2*(k-1)+1): B_location(j,2*(k-1)+1)+B_size(j,2*(k-1)+1)-1,...
                B_location(j,2*(k-1)+2):B_location(j,2*(k-1)+2)+B_size(j,2*(k-1)+2)-1);
            msk = mask(B_location(j,2*(k-1)+1): B_location(j,2*(k-1)+1)+B_size(j,2*(k-1)+1)-1,...
                B_location(j,2*(k-1)+2):B_location(j,2*(k-1)+2)+B_size(j,2*(k-1)+2)-1);
            if sum(sum(msk))>75
                imwrite(patch,['F:\stomate_annotated_data\stomates5\images\',fname,'_',num2str(B_location(j,2*(k-1)+2)),'_',num2str(B_location(j,2*(k-1)+1)),'.png']);
                imwrite(msk,['F:\stomate_annotated_data\stomates5\masks\',fname,'_',num2str(B_location(j,2*(k-1)+2)),'_',num2str(B_location(j,2*(k-1)+1)),'.png']);
            elseif sum(sum(msk))==0
                imwrite(patch,['F:\stomate_annotated_data\stomates5\images\',fname,'_',num2str(B_location(j,2*(k-1)+2)),'_',num2str(B_location(j,2*(k-1)+1)),'.png']);
                imwrite(bg_mask,['F:\stomate_annotated_data\stomates5\masks\',fname,'_',num2str(B_location(j,2*(k-1)+2)),'_',num2str(B_location(j,2*(k-1)+1)),'.png']);   
            end
        end
    end
end


