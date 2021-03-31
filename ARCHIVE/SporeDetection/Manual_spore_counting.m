%% Manual spore detection
exp = '013SLB';
plt = '03';
wl = ['A1';'A2';'A3';'B1';'B2';'B3';'C1';'C2';'C3';'D1';'D2';'D3'];
timestamp = '1505041720';
% path = ['Z:/image_data/',exp,'/microimages/reconstructed/'];
path = 'D:/test_data/exp013SLB/LeafSurfaceImage/';
savepath = 'D:/test_data/exp013SLB/Spores/Manual/';
for jj=1:size(wl,1)
    fname = [path,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_surfimg.png'];
    savefname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporeloc.mat'];
    if exist(savefname,'file')
        load(savefname);
        spore_locs_old = spore_locs;
    else
        spore_locs_old=[];
    end
    try
        if exist(fname,'file')
            img = imread(fname);
            spore_locs=[];
            for i = 1:500:size(img,1)
                for j = 1:500:size(img,2)
                    imshow(img(i:min(i+499,size(img,1)),j:min(j+499,size(img,2))));
                    if ~isempty(spore_locs_old)
                        hold on; plot(spore_locs_old(:,1)-j+1,spore_locs_old(:,2)-i+1,'*');
                        hold off;
                    end
                    [x,y] = getpts(1);
                    spore_locs=[spore_locs;[x+j-1,y+i-1]];
                end
            end
            spore_locs = [spore_locs_old;spore_locs];
            spore_locs = unique(spore_locs,'rows');
            save(savefname,'spore_locs');
        end
    catch ME
        close all;
        spore_locs = [spore_locs_old;spore_locs];
        spore_locs = unique(spore_locs,'rows');
        imshow(img);
        hold on;
        plot(spore_locs(:,1),spore_locs(:,2),'*');
        hold off;
        break;
    end
end
%%  Manual spore boundary detection
exp = '013SLB';
plt = '03';
wl = ['A1';'A2';'A3';'B1';'B2';'B3';'C1';'C2';'C3';'D1';'D2';'D3'];
timestamp = '1505041720';
% path = ['Z:/image_data/',exp,'/microimages/reconstructed/'];
path = 'D:/test_data/exp013SLB/LeafSurfaceImage/';
savepath = 'D:/test_data/exp013SLB/Spores/Manual/';
for jj=1:size(wl,1)
    fname = [path,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_surfimg.png'];
    sporefname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporeloc.mat'];
    savefname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporebound.mat'];
    if exist(fname,'file') && exist(sporefname,'file')
        img = imread(fname);
        [ht,wd] = size(img);
        load(sporefname);
        spore_bounds = [];
        for i = 1:size(spore_locs,1)
            if prod(spore_locs(i,:)>40) && ...
                    spore_locs(i,1) <= wd-40 && ...
                    spore_locs(i,2) <= ht-40
                % using roipoly to draw boundary
                [~,xi,yi] = roipoly(img(spore_locs(i,2)-40:spore_locs(i,2)+40,...
                    spore_locs(i,1)-40:spore_locs(i,1)+40));
                if ~isempty(xi)
                    spore_bounds{end+1} = [xi,yi];
                end
                % using imfreehand to draw boundary
                %             w = 1;
                %             while w % press 'esc' to not draw, 'enter' to reset drawn boundary and finally mouse button to continue to next spore
                %                 imshow(img(spore_locs(i,2)-40:spore_locs(i,2)+40,...
                %                     spore_locs(i,1)-40:spore_locs(i,1)+40));
                %                 h = imfreehand;
                %                 w = waitforbuttonpress;
                %             end
                %             if ~isempty(h)
                %                 spore_bounds{end+1} = getPosition(h);
                %             end
                %             close all;
                
            end
        end
        save(savefname,'spore_bounds');
    end
end
%% Test Spore Detection
clc;
% clear;

%%Create spore shape filters
disp('Creating Spore Shape Filters...');
tic;
% clear;
exp = '013SLB';
plt = '03';
wl = ['A1';'A2';'A3';'B1';'B2';'B3';'C1';'C2';'C3';'D1';'D2';'D3'];
timestamp = '1505041720';
path = 'D:/test_data/exp013SLB/LeafSurfaceImage/';
serverpath = ['Z:/image_data/',exp,'/microimages/reconstructed/'];
savepath = 'D:/test_data/exp013SLB/Spores/Manual/';
shape_params=[];
Rf=[];
for jj=1:size(wl,1)
    fname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporebound.mat'];
    if exist(fname,'file')
        load(fname);
        bpts = spore_bounds;
        for i = 1:size(bpts,2)
            pts = bpts{i};
            if size(pts,1)>15
                pts = pts';
                [e1,e2,e3,e4,p1,p2,sizx,~,tr,rt] = extenergy( pts, false, false );
                %                 ginput();
                %                 close all;
                
                flip=false;
                if sign(p1(1)) == -1
                    p=p1;
                    p1=p2;
                    p2=p;
                    flip=true;
                end
                p1=sign(p1(1))*p1;
                p2=sign(p2(1))*p2;
                
                %                 % fft shape feature
                %                 pts = pts-repmat(tr,1,size(pts,2));
                %                 pts = pts'*rt;
                %                 bw = poly2mask(pts(:,1)+25,pts(:,2)+25,50,50);
                %                 B = bwboundaries(bw);
                %                 pts = B{1,1};
                %                 my=round(mean(find(bw(:,25))));
                %                 pts(:,1)=pts(:,1)-25; pts(:,2)=pts(:,2)-my;
                %                 [th,rad] = cart2pol(pts(:,2),pts(:,1));
                %                 th = rad2deg(th);
                %                 R=[];
                %                 for ang = -180:15:179
                %                     dd = [cosd(th) sind(th)] * [cosd(ang); sind(ang)];
                %                     rads = rad(dd==(max(dd)));
                %                     if ~isempty(rads)
                %                         R = [R, mean(rads)];
                %                     end
                %                 end
                %                 Rf = [Rf; abs(fftshift(fft(R)))];
                
                stp = sizx/100;
                x = -sizx/2:stp:sizx/2;
                y = [(x.*x)' x' ones(size(x,2),1)]*p1;
                npts1 = [x',y];
                y = [(x.*x)' x' ones(size(x,2),1)]*p2;
                npts2 = [x',y];
                pts = [npts1(:,1), mean([npts2(:,2),npts1(:,2)],2)]';
                %     pts = [npts1;npts2]';
                pp = CircleFitByPratt(pts');
                
                %                 w = abs(p1(end)-p2(end))/2;
                r = pp(3);
                ex = pts(1,end);%sizx/2;
                ey = pts(2,end);%[ex*ex ex 1] * p1;
                v1 = [0 -1];
                v2 = [ex ey-r]/norm([ex ey-r]);
                l = acos(abs(dot(v1,v2)))*r;
                ix = (p2(2)-p1(2))/(2*(p1(1)-p2(1)));
                w = [ix*ix ix 1]*p1 - [ix*ix ix 1]*p2;
                %                 [w,ix] = max(abs(npts2(:,2)-npts1(:,2)));
                w=(w)/2;
                ex = ix;
                ey = [ix*ix ix 1]*p1-w;
                v2 = [ex ey-r]/norm([ex ey-r]);
                o = sign(ix)*acos(abs(dot(v1,v2)))*r;
                if w>=1
                    shape_params = [shape_params; ([r w l o])];
                end
                
                %                 [~,b1] = banana2(w,l/r,[r 90 ],false);
                %                 b2 = banana6(w,l/r,[r 90 ],o/r,50);
                %                 nnpts = bpts{i};%[npts1;npts2];
                %                 nnpts = nnpts - repmat(tr',size(nnpts,1),1);
                %                 nnpts = nnpts * rt;
                %                 if flip
                %                     nnpts(:,2) = -nnpts(:,2);
                %                 end
                %                 nnpts = round(nnpts);
                %                 nnpts = unique(nnpts,'rows');
                %                 im = zeros(50,50);
                %                 im(sub2ind(size(im),nnpts(:,2)+26,nnpts(:,1)+26)) = 1;
                %                 msk = bwmorph(b1>0.8*max(b1(:)),'thin',Inf);
                %                 b1(b1>0.8*max(b1(:)))=0.8*max(b1(:));
                %                 wt1 = sum(b1(msk));
                %                 res1 = (imfilter(im,b1/wt1)/size(nnpts,1))/max(b1(:)/wt1);
                %                 msk = bwmorph(b2>0.8*max(b2(:)),'thin',Inf);
                %                 b2(b2>0.9*max(b2(:)))=0.9*max(b2(:));
                %                 wt2 = sum(b2(msk));
                %                 res2 = (imfilter(im,b2/wt2)/size(nnpts,1))/max(b2(:)/wt2);
                %
                %                 subplot(2,2,1);
                %                 imshow(b1,[]); hold on;
                %                 plot(nnpts(:,1)+26,nnpts(:,2)+26,'*'); hold off;
                %
                %                 subplot(2,2,2);
                %                 imshow(b2,[]); hold on;
                %                 plot(nnpts(:,1)+26,nnpts(:,2)+26,'*'); hold off;
                %
                %                 subplot(2,2,3);
                %                 imshow(res1,[]); hold on;
                %                 plot(nnpts(:,1)+26,nnpts(:,2)+26,'*'); hold off;
                %                 title(num2str(max(res1(:))));
                %
                %                 subplot(2,2,4);
                %                 imshow(res2,[]);
                %                 hold on;
                %                 plot(nnpts(:,1)+26,nnpts(:,2)+26,'*'); hold off;
                %                 title(num2str(max(res2(:))));
                %
                %                 ginput();
%                 plot(npts1(:,1),npts1(:,2),'*'); hold on;
%                 plot(npts2(:,1),npts2(:,2),'r*'); plot([ex;0],[ey,r],'g*');ginput();
            end
        end
    end
end

% %Use all training spore shapes
% spts = unique(shape_params,'rows');

%PCA to select cases
[coeffs, scrs, latent, tsqrd, explnd, msp] = pca(shape_params);
% msp(end)=0;
nsmp = [7 5 5 3];
cs = createcombos(nsmp);
av = [2 2.5 2 2.5];
w=[];
for n=1:size(nsmp,2)
    if nsmp(n)==1
        w = [w zeros(size(cs,1),1)];
    else
        tw = min(-av(n)+([0:(nsmp(n)-1)]*((2*av(n))/(nsmp(n)-1))),av(n));
        w = [w tw(cs(:,n))'];
    end
end
nscrs = w.*repmat(sqrt(latent'),size(w,1),1);
% nscrs(:,end) = max(0,nscrs(:,end));
io = (nscrs.*nscrs)*(1./(av'.*av'.*latent));
nscrs = nscrs(io<=1.1,:);
nscrs = unique(nscrs,'rows');
spts = (coeffs*nscrs')' + repmat(msp,size(nscrs,1),1);

%%Clustering to select cases
% n=30;
% idx = kmeans(shape_params,n);
% spts=[];
% for i=1:n
%     med=round(numel(find(idx==i))/2);
%     if med>1
%         sp = sort(shape_params(idx==i,:));
%         spts = [spts; mean(sp)];
%     end
% end

% plot3(shape_params(:,1),shape_params(:,4),shape_params(:,3),'*'); hold on;
% xlabel('Radius of Curvature');
% ylabel('Width');
% zlabel('Arc Length');
% hold all;
% % uvw = [sqrt(latent(1))*coeffs(:,1),sqrt(latent(4))*coeffs(:,4),sqrt(latent(3))*coeffs(:,3)];
% % for q=1:3
% %     quiver3(msp(1), msp(4), msp(3),uvw(1,q),uvw(2,q),uvw(3,q),1,'LineWidth',2);
% % end
% plot3(spts(:,1),spts(:,4),spts(:,3),'ro'); axis equal; hold off;
% axis equal;
% hold off;

angs = 0:15:359;
angs = repmat(angs,size(spts,1),1);
bparams = [repmat(spts',1,size(angs,2)); angs(:)'];

bananas=[];

for i = 1:size(bparams,2)
    [b,gb] = banana5(bparams(2,i),bparams(3,i)/bparams(1,i),[bparams(1,i) bparams(5,i) ],bparams(4,i)/bparams(1,i), false,50);
%     %     b = banana6(bparams(2,i),bparams(3,i)/bparams(1,i),[bparams(1,i) bparams(5,i) ],bparams(4,i)/bparams(1,i),100);
%     %     b = imresize(b,0.5);
%     %     msk = bwmorph(bwmorph(abs(b)<0.2,'thin',Inf),'spur');
%     %     msk = imresize(imfilter(double(msk),fspecial('gaussian'))>0,0.5);
%     %     msk = bwmorph(bwmorph(msk,'thin',Inf),'spur');
% %             msk = bwmorph(b>0.875*max(b(:)),'thin',Inf);
%     %         b = min(b,0.85*max(b(:)));
%     %         wt = sum(b(msk));



%     b(b<0.5)=-1;
%     b(b>0.9*max(b(:))) = 0.9*max(b(:));
%     b(b>0)=b(b>0)/sum(b(b>0));
%     msk = imdilate(b>0,ones(5));
%     b(~msk)=0;
%     b(b<0)=b(b<0)/sum(abs(b(b<0)));

%     msk = abs(gb)>0.001;
%     gb = gb - 0.67*max(gb(:));
%     gb(~msk)=0;
    
%     b(b<0.6)=0;
%     b = b/sum(b(:));

    bananas = cat(3,bananas,gb);
        
end

% num_p = 3;
% blank = zeros(50);
% n = size(bananas,3);
% while mod(n,num_p) > 0
%     bananas = cat(3,bananas,blank);
%     n=n+1;
% end
% n = size(bananas,3);
% pn = n/num_p;
% bananas1 = reshape(bananas,50,50,pn,num_p);

% save('bananas.mat','bananas');
figure;
filts=[];
blank = zeros(50);
k=0;
filt=[];
for i=1:size(spts,1)
    if k==10
        filts = cat(1,filts,filt);
        k=0;
        filt=[];
    end
        filt = cat(2,filt,bananas(:,:,i));
        k=k+1;
end
while k<10
    filt = cat(2,filt,blank);
    k=k+1;
end
filts = cat(1,filts,filt);
imshow(filts,[]);
%% 
 

%%Extract Filter shape Normals.
% load('bananas.mat');
gbananasx=[];
gbananasy=[];
for i = 1:size(bananas,3)
    im = bananas(:,:,i);
    %     mask = im>0.8*max(im(:));
    msk = bwmorph(im>0.875*max(im(:)),'thin',Inf);
    mask = imdilate(msk,ones(3));
    tim = min(im,0.9*max(im(:)));
    wt = sum(tim(msk));
    wt = tim/wt;
    
    %     mask = abs(im)<0.5;
    %     massk = imresize(abs(im)<0.6,0.5);
    %     msk = bwmorph(bwmorph(msk,'thin',Inf),'spur');
    % %     msk = imresize(imfilter(double(msk),fspecial('gaussian'))>0,0.5);
    % %     msk = bwmorph(bwmorph(msk,'thin',Inf),'spur');
    %     tim = max(abs(im),0.2);
    %     tim = imresize(tim,0.5,'nearest');
    %     im = imresize(abs(im),0.5);
    %     wt = sum(1-abs(tim(msk)));
    %     wt = (1-tim)/wt;
    
    [gx,gy] = gradient(im);
    %     mag = sqrt(gx.*gx + gy.*gy);
    %     gx = gx./mag;
    %     gy = gy./mag;
    %     gx(~mask) = 0;
    %     gy(~mask)= 0;
    %     orx = round(gx*10)/(wt*10);
    %     ory = round(gy*10)/(wt*10);
    [gxx,gxy] = gradient(gx);
    [gyx,gyy] = gradient(gy);
    
    gorx = zeros(size(gxx));
    gory = zeros(size(gxx));
    gnorx = zeros(size(find(msk)));
    gnory = zeros(size(find(msk)));
    
    ngxx = gxx(msk);
    ngyy = gyy(msk);
    ngxy = gxy(msk);
    ngyx = gyx(msk);
    
    for j=1:numel(ngxx)
        A = [ngxx(j), ngxy(j); ngyx(j), ngyy(j)];
        [v,d] = eig(A);
        [~,ix] = max(abs(diag(d)));
        dir = v(:,ix);
        vor = [0 1]*dir;
        if vor<0
            dir = -dir;
        elseif vor==0
            dir = abs(dir);
        end
                da = acosd(dir(1));
                da = floor(da/15)*15;
                dir = [cosd(da), sind(da)];
        gnorx(j) = dir(1);
        gnory(j) = dir(2);
        
    end
    
    gorx(msk) = gnorx;
    gorx(~msk)=-100; gorx = imdilate(gorx,ones(3)); gorx(gorx==-100 | ~mask)=0;
    gorx(mask)=gorx(mask).*wt(mask);
    gory(msk) = gnory;
    gory(~msk)=-100; gory = imdilate(gory,ones(3)); gory(gory==-100 | ~mask)=0;
    gory(mask)=gory(mask).*wt(mask);
    %
    %         subplot(1,3,1); imshow(gxx,[]);
    %         subplot(1,3,2); imshow(gyy,[]);
    %         subplot(1,3,3);
%             imshow(wt.*mask,[]); hold on;
%             [r,c] = find(mask);
%             quiver(c,r,gorx(mask),gory(mask));
%             hold off;
%             ginput();
    
    gbananasx = cat(3,gbananasx,gorx);
    gbananasy = cat(3,gbananasy,gory);
end
% save('gbananasx.mat','gbananasx');
% save('gbananasy.mat','gbananasy');

% for paralellization
num_p = 3;
blank = zeros(50);
n = size(gbananasx,3);
while mod(n,num_p) > 0
    gbananasx = cat(3,gbananasx,blank);
    gbananasy = cat(3,gbananasy,blank);
    n=n+1;
end
n = size(gbananasx,3);
pn = n/num_p;
gbananasx = reshape(gbananasx,50,50,pn,num_p);
gbananasy = reshape(gbananasy,50,50,pn,num_p);
toc;
disp('done')   
%% 

%%Extract Image Candidate Boundary points and Normals
disp('Testing Spore Detection...');
for jj=8:8%size(wl,1)
    tic;
    disp('------------------------------');
    disp(['exp',exp,'p',plt,'w',wl(jj,:),timestamp]);
    disp('Pre-processing Image...');
    path = 'D:/test_data/exp013SLB/';
    fname = [path,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'rl001.ome.tif'];
    %     surfname = [path,'LeafSurfaceImage/','exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_surfloc.mat'];
    surfname = [serverpath,'LeafSurfaceImage/','exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_surfloc_new.txt'];
    sporefname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporeloc.mat'];
    resfname = [savepath,'exp',exp,'p',plt,'w',wl(jj,:),timestamp,'_sporedetection_test_v2.mat'];
    
    surfloc = dlmread(surfname);
    info=imfinfo(fname);
%     [x,y] = meshgrid(0:info(1).Width-1,0:info(1).Height-1);
%     z = surfloc(sub2ind(size(surfloc),y(:)+1,x(:)+1))*1.2;
%     x = x(:)*2.6;
%     y = y(:)*2.6;
%     
%     plane = [x,y,ones(numel(x),1)]\-z;
%     vix = abs([x,y,ones(numel(x),1),z]*[plane;1]) < 30;
%     
%     p = polyfitn([x(vix),y(vix)],z(vix),3);
%     surfloc = polyvaln(p,[x,y])/1.2;
%     surfloc = reshape(surfloc,info(1).Height,info(1).Width);
    %     load(surfname);
    imgc = getSurfaceImage(fname,info,surfloc,7,'min',1,0)/255;
    % %     imgc = imread(fname);
    % %     imgc = im2double(imgc);
    %     imgc = max(0.05,imgc);
    %     info = imfinfo(fname);
    %     imgc = zeros(info(1).Height,info(1).Width)-255;
    %     for i=-2:2
    %         imgc = max(imgc,(getSurfaceImage(fname,imfinfo(fname),surfloc-7+i,9,'log',1,0)));
    %     end
    %     imgc = imgc - min(imgc(:));
    %     imgc = imgc/max(imgc(:));
    %     imgc = imresize(imresize(imgc,0.75),size(imgc));
%     imgc = imfilter(imgc,fspecial('gaussian',5));
%     imgc = medfilt2(imgc,[5,5]);
%                     imgc = anisodiff2D(imerode(imgc,ones(3)),15,1/7,0.005,1);
%                     imgc=imdilate(imgc,ones(3));
%                     imgc(isnan(imgc))=0;
%     imgc = max(0.05,imgc);
    
    %     imgc = imresize(imgc,2);
    %     imgc = imfilter(imgc,fspecial('gaussian',5));
    [height,width] = size(imgc);
    [~,r_angle] = rotalignimage(imgc);
    %     imgc = adapthisteq(imgc);
    filt1 = [0.25 0.5 0.25 0 -0.25 -0.5 -0.25];
    filt2 = [1 0 -1];
    filt3 = fspecial('log',[1,5]);
    % compute hessian

%         gx = conv2(imgc,filt2,'same');
%         gy = conv2(imgc,filt2','same');        
%         gxx = conv2(gx,filt2,'same');
%         gyy = conv2(gy,filt2','same');
%         gxy = conv2(gx,filt2','same');
%         imgc = (imfilter(imgc,fspecial('gaussian',3,0.3)));
        [gx,gy] = gradient(imgc);
        [gxx,gxy] = gradient(gx);
        [~,gyy] = gradient(gy);
%         gxxt = max(0,gxx);
%         gyyt = max(0,gyy);
%         gxyt = max(0,gxy);
%         mag = sqrt(gxxt.*gxxt + gyyt.*gyyt + 2*gxyt);%./conv2(imgc,ones(101)/(101*101),'same');
%         mag = max(0,mag);
        mag = (gxx.*gx.*gx + 2*gxy.*gx.*gy + gyy.*gy.*gy)./(gx.*gx + gy.*gy);
        mag(isnan(mag))=0;
        mag = max(0,mag);
        mag = mag.*(1-imclose(imgc,ones(3)));
%         mag = imclose(max(0,mag),ones(3));
        
        orx = zeros(size(gxx));
        ory = zeros(size(gxx));
        
        [hn,hc] = hist(mag(:),100);
        chn = cumsum(hn)/sum(hn);
        th=hc(find(chn>0.8,1,'first'));
        th1=hc(find(chn>0.9,1,'first'));
%         th = 0.001;
%         th1 = 0.005;
        
        eimg = bwmorph(mag>th,'spur');
        
        
        norx = zeros(size(find(eimg)));
        nory = zeros(size(find(eimg)));
        
        ngxx = gxx(eimg);
        ngyy = gyy(eimg);
        ngxy = gxy(eimg);
        for i=1:numel(ngxx)
            A = [ngxx(i), ngxy(i); ngxy(i), ngyy(i)];
            [v,d] = eig(A);
            [~,ix] = max(abs(diag(d)));
            dir = v(:,ix);
            if min(d)/max(d) < 0.3
                norx(i) = dir(1);
                nory(i) = dir(2);
            else
                norx(i)=0;
                nory(i)=0;
            end
        end
        
        orx(eimg) = norx;
        ory(eimg) = nory;
        
        %     magn = sqrt(gx.*gx+ gy.*gy);
        %     orx(eimg) = gx(eimg)./magn(eimg);
        %     ory(eimg) = gy(eimg)./magn(eimg);
        
        mag(~eimg) = 0;
        eimg = zeros(size(imgc));
        eimg = thinAndThreshold(eimg,orx,ory,mag,th,th1);
    eimg = bwareaopen(bwmorph(eimg,'thin',Inf),1);
    ory(~eimg)=0;
    orx(~eimg)=0;
    
    ors = orx*sind(-r_angle) + ory*cosd(-r_angle);
    eimg = bwareaopen((~bwareaopen(abs(ors)>0.95,20,8)) & eimg,1);
    orx(~eimg) = 0;
    ory(~eimg) = 0;
    
    es =  find(eimg);
    for i=1:numel(es)
        dir = [orx(es(i));ory(es(i))];
        vor = [0 1]*dir;
        if vor<0
            dir = -dir;
        elseif vor==0
            dir = abs(dir);
        end
        da = acosd(dir(1));
                da = floor(da/15)*15;
        orx(es(i)) = cosd(da);
        ory(es(i)) = sind(da);
    end
    
            figure; imshow(cat(3,max(imgc,double(eimg)),imgc.*~eimg,imgc.*~eimg));
            hold on;
            [r,c] = find(eimg);
        %     quiver(c,r,orx(sub2ind(size(orx),r,c)),ory(sub2ind(size(ory),r,c)));
            quiver(c,r,orx(eimg),ory(eimg));
    toc;
    disp('done');

    %% 
  
    %%template matching
%     close all
    clear limg1 limg h h1 bw cc sth img gxx gyy gxy ngxx ngyy ngxy norx nory
    
    tic;
    disp('Spore-shape template matching...');
    imgc = padarray(imgc,[25,25]);
    eimg = padarray(eimg,[25,25]);
    orx = padarray(orx,[25,25]);
    ory = padarray(ory,[25,25]);
    %% 

    
    fimg = -1*ones([size(imgc),num_p]);
    ixs = ones([size(imgc),num_p]);
    parfor i = 1:num_p
        tbananasx = gbananasx(:,:,:,i);
        tbananasy = gbananasy(:,:,:,i);
        
%         tbananas1 = bananas1(:,:,:,i);
%         tbananas2 = bananas2(:,:,:,i);
        for j=1:pn
            [fimg(:,:,i),ixn] = max(cat(3,fimg(:,:,i),abs(conv2(orx,tbananasx(end:-1:1,end:-1:1,j), 'same') ...
                + conv2(ory,tbananasy(end:-1:1,end:-1:1,j),'same'))),[],3);

%             [fimg(:,:,i),ixn] = max(cat(3,fimg(:,:,i),(conv2(double(imgc),tbananas1(end:-1:1,end:-1:1,j), 'same'))...
%          ./(conv2(double(imgc),tbananas2(end:-1:1,end:-1:1,j), 'same'))),[],3);        
%         ),[],3);
                
            
            ixs(:,:,i) = ixs(:,:,i).*(ixn==1) + j*(ixn==2);
        end
    end
    [tfimg,ix] = max(fimg,[],3);
    figure;imshow(tfimg,[]);
    colormap(jet);
    colorbar;
    
    toc;
    disp('done');
    %%
    possample=[];
    negsample=[];
    nhood = [ones(5,11); 1 1 1 1 1 0 1 1 1 1 1; ones(5,11)];
    [r,c] = find((tfimg > imdilate(tfimg,nhood)) & ((tfimg.*~(fmsk)) >= 0.8) ... 
        | (tfimgg > imdilate(tfimgg,nhood)) & ((tfimgg.*~(imdilate(bwareaopen(imgc>0.7,10),ones(11,1)) | fmsk)) >= 0.3));
    inds = find(r<25 | r>size(tfimg,1)-25 | c<25 | c>size(tfimg,2)-25);
    r(inds)=[]; c(inds)=[];
    sporemask = false(size(tfimg));
    count=0;
    fr=[];
    fc=[];
    for i=1:numel(r)
        
        si = ixs(r(i),c(i),ix(r(i),c(i)));
        si = pn*(ix(r(i),c(i))-1) + si;
        
        si1 = ixss(r(i),c(i),ixx(r(i),c(i)));
        si1 = pn*(ixx(r(i),c(i))-1) + si1;
        
        sh = bananas(:,:,si);
        sh1 = bananas1(:,:,si1)>0;
        sh = bwmorph(sh>0.875*max(sh(:)),'thin',Inf);
        shm = imdilate(sh,ones(3));
        f1 = gbananasx(:,:,ixss(r(i),c(i),ixx(r(i),c(i))),ixx(r(i),c(i)));
        f2 = gbananasy(:,:,ixss(r(i),c(i),ixx(r(i),c(i))),ixx(r(i),c(i)));
        f3 = bananas1(:,:,ixs(r(i),c(i),ix(r(i),c(i))),ix(r(i),c(i)));
        f4 = bananas2(:,:,ixs(r(i),c(i),ix(r(i),c(i))),ix(r(i),c(i)));
        im = imgc(r(i)-24:r(i)+25,c(i)-24:c(i)+25);
        im1 = tfimgg(r(i)-24:r(i)+25,c(i)-24:c(i)+25);
        eim = eimg(r(i)-24:r(i)+25,c(i)-24:c(i)+25);
        res4 = imfilter(im,f3)./imfilter(im,f4);
        res4(isnan(res4))=0;
        res4 = imdilate(res4,ones(5));
        eimm = eim;
        eim = eim & shm;
%         juncs = imfilter(double(teim),ones(3));
        eim = bwmorph(bwareaopen(eim,1),'spur');
        cc = bwconncomp(eim);
        imb1 = orx(r(i)-24:r(i)+25,c(i)-24:c(i)+25);%.*eim;
        imb2 = ory(r(i)-24:r(i)+25,c(i)-24:c(i)+25);%.*eim;
        res = abs(imfilter(imb1,f1)+imfilter(imb2,f2));
        res = imdilate(res,ones(5));
        fm = sqrt(f1.*f1 + f2.*f2);
        fm(fm==0)=1;
        f1 = f1./fm; f2 = f2./fm;
        res1 = imb1.*f1 + imb2.*f2;
                subplot(2,2,1);
                imshow(im,[]);
                subplot(2,2,2);
                imshow(eimm,[]);
                subplot(2,2,3);
                imshow(im1,[]);
                subplot(2,2,4);
                imshow(res1,[]);

        scr1 = tfimg(r(i),c(i));
        scr2 = res(25,25);
        scr3 = tfimgg(r(i),c(i));
        scr4 = res4(25,25);
                title(['score: ',num2str(scr1),' , ',num2str(scr2), ' , ' num2str(scr3),' , ',num2str(scr4)]);
                                pause;
%                 [~,~,but]=ginput(1);
%                 if but == 1
%                     possample = [possample ; [scr1, scr2, scr3]];
%                 else
%                     negsample = [negsample ; [scr1, scr2, scr3]];
%                 end
        if (scr2 > 0.75 && scr4 > 0.2) || scr1 > 0.9 || scr3 > 0.4 
            %         if ~isempty(but)
            %             if but==1
            %                 pcount = pcount+1;
            %                 pfr = [pfr;r(i)];
            %                 pfc = [pfc;c(i)];
            %             elseif but==3
            %                 ncount = ncount+1;
            %                 nfr = [nfr;r(i)];
            %                 nfc = [nfc;c(i)];
            %             end
            count = count + 1;
            fr = [fr;r(i)];
            fc = [fc;c(i)];
            sporemask(r(i)-24:r(i)+25,c(i)-24:c(i)+25) = sporemask(r(i)-24:r(i)+25,c(i)-24:c(i)+25) | shm;
        end
    end
    %     close all;
    sporemask = imdilate(sporemask,ones(3));
    figure; imshow(cat(3,max(imgc,double(eimg)),max(imgc,double(sporemask)),imgc.*(~eimg & ~sporemask))); hold on;
    load(sporefname);
    plot(spore_locs(:,1)+25,spore_locs(:,2)+25,'*');
%     count
end
%% 3D vizualization
img = cat(3,imgc,max(imgc,double(sporemask)),imgc.*(~sporemask));
img = uint8(img(26:end-25,26:end-25,:)*255);
bsurf = getBottomSurfaceMap(fname,info,round(info(1).Width/20));
bimg = uint8(getSurfaceImage(fname, info, bsurf, 0, '', 1, false));
%%
cones=[];
for ii=1:numel(fpr)
    cones = [cones;makecone(7*2.6/4,-45*1.2,[(fpc(ii)-25)*2.6/4,(fpr(ii)-25)*2.6/4,1.2*(surfloc(fpr(ii)-25,vpc(ii)-25)-10)])];
end
coneclr = repmat([0,0,255],size(cones,1),1);
%%
[xx,yy] = meshgrid(1:4:info(1).Width,1:4:info(1).Height);
pts = [xx(:)*.26/4, yy(:)*.26/4, surfloc(sub2ind(size(surfloc),yy(:),xx(:)))*1.2];
clrs = [img(sub2ind(size(img),yy(:),xx(:),ones(numel(xx),1))),...
    img(sub2ind(size(img),yy(:),xx(:),2+zeros(numel(xx),1))),...
    img(sub2ind(size(img),yy(:),xx(:),3+zeros(numel(xx),1)))];

pts = [pts;[xx(:)*.26/4, yy(:)*.26/4, bsurf(sub2ind(size(bsurf),yy(:),xx(:)))*1.2]];
clrs = [clrs;[bimg(sub2ind(size(bimg),yy(:),xx(:),ones(numel(xx),1))),...
    bimg(sub2ind(size(bimg),yy(:),xx(:),ones(numel(xx),1))),...
    bimg(sub2ind(size(bimg),yy(:),xx(:),ones(numel(xx),1)))]];

%%
WritePly('sptest3.ply',pts,clrs);
WritePly('sptest_cones4.ply',cones1,conclr1);


%%

fimgcc = zeros(size(orxc));
ixsc = zeros(size(orxc));
tbananasx = reshape(gbananasx,size(gbananasx,1),size(gbananasx,2),size(gbananasx,3)*size(gbananasx,4));
tbananasy = reshape(gbananasy,size(gbananasy,1),size(gbananasy,2),size(gbananasy,3)*size(gbananasy,4));
%                 tbananas = bananas(:,:,:,i);
for j=1:size(tbananasx,3)
    [fimgcc,ixs] = max(cat(3,fimgcc,abs(conv2(orxc,tbananasx(end:-1:1,end:-1:1,j),'same') ...
        + conv2(oryc,tbananasy(end:-1:1,end:-1:1,j),'same'))),[],3);
    ixsc = ixsc + ixs-1;
    %   fimg(:,:,i) = max(fimg(:,:,i),abs(conv2(double(eimg),tbananas(end:-1:1,end:-1:1,j),'same')));
end
figure;imshow(fimgcc,[]);
colormap(jet);
colorbar;

