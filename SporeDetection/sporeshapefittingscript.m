clear;
path = 'D:/test_data/exp013SLB/Spores/Manual/';
lst = dir([path,'*.png']);
sporeshapes=[];
scl=1;
count=1;
for j=1:numel(lst)
    name = lst(j).name;
    img = imread([path,name])>0;
    B = bwboundaries(img,4);
    for i=1:length(B)
        pts = B{i};
        if size(pts,1) >= 15
            sporeshape = fitsporeshape(pts);
            if ~isempty(sporeshape) && sporeshape.Width>=2
                [b1,gb,~] = generatesporeshape(sporeshape,50,scl);
                b1 = imdilate(~imerode(b1>0,ones(3)) & (b1>0),ones(3));
                tpts = sporeshape.Points;
                ry = min(max(1,round((1/scl)*tpts(:,2)+25/scl)),size(b1,1));
                cx = min(max(1,round((1/scl)*(tpts(:,1))+25/scl)),size(b1,2));
                msk = false(size(b1));
                msk(sub2ind(size(msk),ry,cx))=true;
                msk = imdilate(msk,ones(round(3)));
%                     figure(3);
%                     bkg = true(size(b1));
%                     im = double(cat(3,0*b1,msk,b1));
%                     imshow(im);
%                     title(['(curvature, thickness, width, offset) : (',...
%                         num2str(sporeshape.Radius,'%2.2f'),', ', ...
%                         num2str(sporeshape.Width,'%2.2f'),', ', ...
%                         num2str(sporeshape.Radius*sporeshape.Length,'%2.2f'),', ', ...
%                         num2str(sporeshape.Radius*sporeshape.Offset,'%2.2f'),')']);
%                     xlabel(['mean error:',num2str(sporeshape.MeanError)]);
%                     ax = gca; set(ax,'fontsize',30);
%                     pause;
                
                %                 [imind,cm] = rgb2ind(im,256);
                %                 if count == 1;
                %                     imwrite(imind,cm,'sporeshapefit.gif', 'Loopcount',inf);
                %                 else
                %                     imwrite(imind,cm,'sporeshapefit.gif','WriteMode','append');
                %                 end
                %                 count = count+1;
                sporeshapes = [sporeshapes;sporeshape];
            end
        end
    end
end
% save('sporeshapes.mat','sporeshapes');

%%
rng default
inds = randi(numel(sporeshapes),800,1);
shape_params = double([cat(1,sporeshapes(inds).Radius), cat(1,sporeshapes(inds).Width),...
    cat(1,sporeshapes(inds).Length),...
    abs(cat(1,sporeshapes(inds).Offset)),...
    ]);

test_shape_params = double([cat(1,sporeshapes(:).Radius), cat(1,sporeshapes(:).Width),...
    cat(1,sporeshapes(:).Length),...
    abs(cat(1,sporeshapes(:).Offset)),...
    ]);

options=statset('MaxIter',1000);
thresh = 0.01;
for i=5:5
    obj = gmdistribution.fit(shape_params,i,'Replicate',10,'Options',options);
    nosp=test_shape_params(pdf(obj,test_shape_params)<thresh,:);
    plot3(test_shape_params(:,1),test_shape_params(:,3),test_shape_params(:,4),'*');
    hold on;
    plot3(nosp(:,1),nosp(:,3),nosp(:,4),'ro');
    title(['K: ', num2str(obj.NComponents),', Samples: ', num2str(size(test_shape_params,1)),', Outliers: ', num2str(size(nosp,1))]);
    hold off;
    pause
end
close all;
%%
rng default
options=statset('MaxIter',1000);
obj = gmdistribution.fit(shape_params,10,'Replicate',10,'Options',options);

sporeshapemodel.shapes = sporeshapes;
sporeshapemodel.model = obj; %gaussian mixture model
sporeshapemodel.threshold = thresh;

%save('sporeshapemodel.mat','sporeshapemodel');

%%

load('sporeshapemodel.mat');
sporeshapes = sporeshapemodel.shapes;
shape_params = [[cat(1,sporeshapes(:).Radius), cat(1,sporeshapes(:).Width),...
    cat(1,sporeshapes(:).Length).*cat(1,sporeshapes(:).Radius),...
    abs(cat(1,sporeshapes(:).Offset)).*cat(1,sporeshapes(:).Radius)]];
%     [cat(1,sporeshapes(:).Radius), cat(1,sporeshapes(:).Width)+0.5,...
%     cat(1,sporeshapes(:).Length).*cat(1,sporeshapes(:).Radius),...
%     abs(cat(1,sporeshapes(:).Offset)).*cat(1,sporeshapes(:).Radius)];
%     [cat(1,sporeshapes(:).Radius), cat(1,sporeshapes(:).Width)+1,...
%     cat(1,sporeshapes(:).Length).*cat(1,sporeshapes(:).Radius),...
%     abs(cat(1,sporeshapes(:).Offset)).*cat(1,sporeshapes(:).Radius)]];
shape_params(shape_params(:,1)>150,:)=[];
% PCA to select cases
[coeffs, scrs, latent, tsqrd, explnd, msp] = pca(shape_params);
%uniform sampling
% nsmp = [7 5 3 1];
% cs = createcombos(nsmp);
% av = [2 2 2 2];
% w=[];
% for n=1:size(nsmp,2)
%     if nsmp(n)==1
%         w = [w zeros(size(cs,1),1)];
%     else
%         tw = min(-av(n)+([0:(nsmp(n)-1)]*((2*av(n))/(nsmp(n)-1))),av(n));
%         w = [w tw(cs(:,n))'];
%     end
% end
% nscrs = w.*repmat(sqrt(latent'),size(w,1),1);
% io = (nscrs.*nscrs)*(1./(av'.*av'.*latent));
% nscrs = nscrs(io<=1,:);
% nscrs = unique(nscrs,'rows');
% spts = (coeffs*nscrs')' + repmat(msp,size(nscrs,1),1);

% n=100;
% rng default;
% spts = random(sporeshapemodel.model,n);

n=12;
% rng default;
scl = sqrt(latent');
% scrs = scrs./repmat(scl,size(shape_params,1),1);
[clusters,spts] = kmeans(scrs,n,'Replicates',10,'emptyaction','drop','OnlinePhase','On','MaxIter',1000);
hn = hist(clusters,1:n);
ii = hn<=0.05*numel(clusters);
spts(ii,:)=[];


% spts = spts.*repmat(scl,size(spts,1),1);
spts = (coeffs*spts')' + repmat(msp,size(spts,1),1);

plot3(shape_params(:,1),shape_params(:,3),shape_params(:,4),'*'); axis equal; hold on;
xlabel('Radius of Curvature');
ylabel('Arc Length');
zlabel('Offset');
hold all;
plot3(spts(:,1),spts(:,3),spts(:,4),'ro'); hold off;
hold off;

spts(:,3) = spts(:,3)./spts(:,1); spts(:,4) = spts(:,4)./spts(:,1);
%%

spts = [spts(:,1:4);[spts(:,1:3), -spts(:,4)]];
spts = unique(spts,'rows');


angs = 0:15:359;
angs = repmat(angs,size(spts,1),1);
bparams = [repmat(spts',1,size(angs,2)); angs(:)'];
% bparams(2,:) = bparams(2,:)+1;
%% 

sporesLoG=[];
sporesGauss=[];
sporesShape=[];
for i = 1:size(bparams,2)
    [gs,gb,sh] = generatesporeshape(bparams(:,i)+[0;1;0;0;0],50,0.25,1);
    gb(abs(gb)<=10^-5) = 0;
    gb(gb>0) = gb(gb>0)/sum(gb(gb>0));
    gb(gb<0) = -gb(gb<0)/sum(gb(gb<0));
    %     B = bwboundaries(gs>0);
    %     b = B{1,1};
    %     im = false(size(gs));
    %     im(sub2ind(size(im),b(:,1),b(:,2)))=true;
    spore = gb-gs;
    spore(spore>0) = spore(spore>0)/sum(spore(spore>0));
    spore(spore<0) = -spore(spore<0)/sum(spore(spore<0));
%     gb(gb>0) = gb(gb>0)-mean(gb(gb>0));
    sporesLoG = cat(3,sporesLoG,gb);
    sporesGauss = cat(3,sporesGauss,gs);
    sporesShape = cat(3,sporesShape,sh);
    %     surf(gs-gb); pause;
end


% save('sporefilters_LoG.mat','sporesLoG');
% save('sporefilters_Gaussian.mat','sporesGauss');
figure;
filts=[];
blank = zeros(size(gs));
k=0;
filt=[];
for i=1:size(spts,1)
    if k==10
        filts = cat(1,filts,filt);
        k=0;
        filt=[];
    end
    filt = cat(2,filt,sporesLoG(:,:,i));
    k=k+1;
end
while k<10
    filt = cat(2,filt,blank);
    k=k+1;
end
filts = cat(1,filts,filt);
imshow(filts,[]);
%%
bananas = spores;
gbananasx=[];
gbananasy=[];
for i = 1:size(bananas,3)
    im = bananas(:,:,i);
    msk = bwmorph(im>=0.9*max(im(:)),'thin',Inf);
    mask = imdilate(msk,ones(1));
    tim = double(msk);%min(im,0.95*max(im(:)));
    wt = sum(tim(msk));
    wt = tim/wt;
    
    [gx,gy] = gradient(im);
    [gxx,gxy] = gradient(gx);
    [gyx,gyy] = gradient(gy);
    
    gxx = imfilter(gxx,fspecial('gaussian'));
    gyy = imfilter(gyy,fspecial('gaussian'));
    gxy = imfilter(gxy,fspecial('gaussian'));
    gyx = imfilter(gyx,fspecial('gaussian'));
    
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
    
    %     subplot(1,3,1); imshow(gxx,[]);
    %     subplot(1,3,2); imshow(gyy,[]);
    %     subplot(1,3,3);
    %     imshow(wt.*mask,[]); hold on;
    %     [r,c] = find(mask);
    %     quiver(c,r,gorx(mask),gory(mask));
    %     hold off;
    %     pause;
    
    gbananasx = cat(3,gbananasx,gorx);
    gbananasy = cat(3,gbananasy,gory);
end

save('gbananasx_new.mat','gbananasx');
save('gbananasy_new.mat','gbananasy');
save('bananas_new.mat','bananas');
% save('bananas1.mat','bananas1');
% save('bananas2.mat','bananas2');

toc;
disp('done');
clear gbananasx gbananasy bananas bananas1 bananas2 gorx gory;

%%
num_p=3;

blank = zeros(50);
n = size(spores,3);

while mod(n,num_p) > 0
    spores = cat(3,spores,blank);
    n=n+1;
end
n = size(spores,3);
pn = n/num_p;
spores = reshape(spores,50,50,pn,num_p);

fimg1 = -1*ones([size(mag),num_p]);
ixs1 = ones([size(mag),num_p]);
distmap = bwdist(mag>=0.1);
parfor i = 1:num_p
    tspores = spores(:,:,:,i);
    for j=1:pn
        [fimg1(:,:,i),ixn1] = max(cat(3,fimg1(:,:,i),abs(conv2(distmap,tspores(end:-1:1,end:-1:1,j), 'same'))),[],3);
        ixs1(:,:,i) = ixs1(:,:,i).*(ixn1==1) + j*(ixn1==2);
    end
end
[tfimg1,ix1] = max(fimg1,[],3);
% ix1 = (ix1(sub2ind(size(ix1),y,x))-1)*pn + ixs1(sub2ind(size(ixs1),y,x,ix1(sub2ind(size(ix1),y,x))));
