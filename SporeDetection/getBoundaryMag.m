function [mag,orx,ory] = getBoundaryMag(img,norm)
if norm    
    [imgs,inds] = sort(img(:));
    x=[(1:numel(imgs))' , ones(size(imgs))];
    y = x*(x\imgs);
    err = imgs-y;
    imgs = smooth(y + max(-0.05,min(0.05,err)));
    img(inds) = imgs;
    img = img-min(img(:));
    img = img/max(img(:));
end
mag = zeros(size(img));
orient = zeros(size(img))-1;
% filters = [];
for i=3:2:5
    smag = zeros(size(img));
    sorient = zeros(size(img))-1;
    for a=0:30:180-1
        filter = getgaborfilter(i,deg2rad(a));
        %         filters{end+1} = filter;
        magt = max(0,imfilter(img,filter));
        [smag,idx] = max(cat(3,smag,magt),[],3);
        sorient(idx==2)=a+90;
    end
    [mag, idx] = max(cat(3,mag,smag),[],3);
    orient(idx==2) = sorient(idx==2);
end
mag = mag.*(1-img);
orient(orient>180) = orient(orient>180)-180;
angles = unique(orient(orient>0));
msk = false(9);
msk(round(9/2),round(9/2))=true;
for i=1:numel(angles)
    inds = imdilate(msk,strel('line',9,angles(i)));
    ii = find(orient==angles(i) & mag < 0.5*imdilate(mag,inds));
    mag(ii)=0;
    orient(ii)=-1;
end
mag = mag/max(mag(:));
orx = cosd(orient); ory = -sind(orient);
orx(orient==-1)=0; ory(orient==-1)=0;

[hn,hc]=hist(orient(orient>=0),0:30:180);
[~,ii] = max(hn);
da = hc(ii);
mask = bwareaopen(orient==da,50);
mag(mask)=0;
orx(mask)=0; ory(mask)=0;
mag = mag/max(mag(:));
end