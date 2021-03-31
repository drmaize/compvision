function [] = SurfaceEstimation(in_filename, out_filename)
%%%%in_filename: path to the stack to find the surface of. Used the
%%%%lightfield/cell images in testing
%%%%out_filename: path to .txt file to store the results'


disp('This might take a few minutes...');
fname = in_filename; %filename
fsurfname = [out_filename '.txt']; %file name to save surface location
isurfname = [out_filename '.png']; %surface image name

%read input file
info = imfinfo(fname);
tic;
A=[];
for i=1:numel(info)
    A = cat(3,A,imread(fname,i));
end
toc;

p1=1; %line 
p2='poly11'; %plane

%initialize surface from MIP
[mim,surfloc] = max(imfilter(A,ones(25)/625),[],3);

%initialize weight used in optimization of snake

%hn = hist(A(:),0:255);
%hn = cumsum(hn)/sum(hn);
%idx = find(hn>=0.9,1,'first');
%wt=mean(A(A(:)>(idx-1)))/255

wt = mean(mim(:))/255;

fsurf = surfloc;
for iter = 1:5 %number of optimization iterations
    disp(['Current iteration: ' num2str(iter) '/5']);
    w = ceil(50/iter);  %image patch size to be used for computing brigtness and sharpness metrics
    [x,y] = meshgrid(w+1:w+1:info(1).Width-w,...
        w+1:w+1:info(1).Height-w);  %uniformly spaced grid of control points based on image patch size.
    
    fsurf = fsurf(sub2ind(size(fsurf),y,x));
    
    for jj=1:1
        ofsurf = fsurf;
        
        %2 iterations: one for horizotal connections of control points and
        %one for vertical connections
        for i=1:2
            
            ply = fit([x(:),y(:)],ofsurf(:),p2); % fit plane to control points
            fa = @(X) [repmat(w+1,size(X,1),1), X(:,2), X(:,3)]; % row/column of 3D control points
            fb = @(X) polyfit(X(:,2),ply(X(:,1:2)),p1); % approximate a row/column of control points by a line that lies on the plane fit to all the control points.
            f = @(X) snakeiter3D1(A(min(X(:,2))-w:max(X(:,2))+w,min(X(:,1))-w:max(X(:,1))+w,:),...
                fa(X),-floor(15/iter):floor(15/iter),w,fb(X),1,0.2*wt*iter,0.05*wt/iter); %optimization function
            
            % split control points into separate row/column
            cell1 = mat2cell([x(:), y(:), fsurf(:)],repmat(size(x,1),1,size(x,2)),3);
            
            tic;
            C = cell(size(cell1));
            % optimization is done for each row/column of control points
            for k=1:size(cell1,1)
                C{k} = f(round(cell1{k}));
            end
            toc;
            
            %switch between row and column
            tx = x; x = y'; y = tx';
            ofsurf = ofsurf';
            
            pts = cat(1,C{:});
            fsurf = reshape(pts(:,3),size(fsurf));
            fsurf = fsurf';
            
            A = permute(A,[2,1,3]);
        end
    end
    %bilinear interpolation to estimate surface depth and every pixel and
    %also handle boundaries of the image by padding.
    fsurf = interp2(x,y,fsurf,min(x(:)):max(x(:)),(min(y(:)):max(y(:)))');
    fsurf = padarray(fsurf,[w,w],'replicate','pre');
    fsurf = padarray(fsurf,[size(surfloc,1)-size(fsurf,1),size(surfloc,2)-size(fsurf,2)],'replicate','post');
end

%save results
dlmwrite(fsurfname,fsurf);
[x,y] = meshgrid(1:info(1).Width,1:info(1).Height);
imwrite(A(sub2ind(size(A),y,x,max(1,round(fsurf)))),isurfname,'png');


end

