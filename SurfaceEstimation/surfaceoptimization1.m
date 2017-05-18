datapath = ['/mnt/data27/wisser/drmaize/image_data/e',experiment,'/microimages/reconstructed/HS/'];
samp = ['e',experiment,'p',plt,'w',wl,'x20_',timestamp];
% disp(samp);
fname = [datapath,samp,'rl001.ome.tif'];
%surfname = [datapath,'surfacemap/',samp,'_topsurface.txt'];
fsurfname = [datapath,'surfacemap/',samp,'_topsurface_optimized1.txt'];
isurfname = [datapath,'surfacemap/',samp,'_topsurface_image1.png'];
%surfloc = dlmread(surfname);
info = imfinfo(fname);

tic;
A=[];
for i=1:numel(info)
    A = cat(3,A,imread(fname,i));
end
toc;

%hn = hist(A(:),0:255);
%hn = cumsum(hn)/sum(hn);
%idx = find(hn>=0.9,1,'first');
%wt=mean(A(A(:)>(idx-1)))/255

p1=1; p2='poly11';
[mim,surfloc] = max(imfilter(A,ones(25)/625),[],3);
wt = mean(mim(:))/255
fsurf = surfloc;
for iter = 1:5
    w = ceil(50/iter);
    [x,y] = meshgrid(w+1:w+1:info(1).Width-w,...
        w+1:w+1:info(1).Height-w);
    
    fsurf = fsurf(sub2ind(size(fsurf),y,x));
    
    for jj=1:1
        ofsurf = fsurf;
        for i=1:2
            
            ply = fit([x(:),y(:)],ofsurf(:),p2);
            fa = @(X) [repmat(w+1,size(X,1),1), X(:,2), X(:,3)];
            fb = @(X) polyfit(X(:,2),ply(X(:,1:2)),p1);%[X(:,2), ones(size(X,1),1)]\([X(:,1),X(:,2), ones(size(X,1),1)]*plane);
            f = @(X) snakeiter3D1(A(min(X(:,2))-w:max(X(:,2))+w,min(X(:,1))-w:max(X(:,1))+w,:),...
                fa(X),-floor(15/iter):floor(15/iter),w,fb(X),1,0.2*wt*iter,0.05*wt/iter);
            
            cell1 = mat2cell([x(:), y(:), fsurf(:)],repmat(size(x,1),1,size(x,2)),3);
            
            tic;
            C = cell(size(cell1));
            for k=1:size(cell1,1)
                C{k} = f(round(cell1{k}));
            end
            toc;
            
            tx = x; x = y'; y = tx';
            ofsurf = ofsurf';
            
            pts = cat(1,C{:});
            fsurf = reshape(pts(:,3),size(fsurf));
            fsurf = fsurf';
            
            A = permute(A,[2,1,3]);
        end
    end
    fsurf = interp2(x,y,fsurf,min(x(:)):max(x(:)),(min(y(:)):max(y(:)))');
    fsurf = padarray(fsurf,[w,w],'replicate','pre');
    fsurf = padarray(fsurf,[size(surfloc,1)-size(fsurf,1),size(surfloc,2)-size(fsurf,2)],'replicate','post');
end
dlmwrite(fsurfname,fsurf);
[x,y] = meshgrid(1:info(1).Width,1:info(1).Height);
imwrite(A(sub2ind(size(A),y,x,max(1,round(fsurf)))),isurfname,'png');

