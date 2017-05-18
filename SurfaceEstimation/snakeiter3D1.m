function [pts,finalenergy] = snakeiter3D1(im,pts,neighbor,w,ply,alpha,beta,gamma)
[~,~,pp] = size(im);
m = numel(neighbor);
n = size(pts,1);
energymtx = zeros(m,n);
posmtx = zeros(m,n);

im = padarray(im,round([0, 0, m/2]));
pts(:,3) = pts(:,3) + floor(m/2);

for i=1:n-1
    %     [x,y] = find(D==i);
    %     x = [x,x-1,x+1]; y = [y,y-1,y+1];
    %     x(x<1 | x>nn) = []; y(y<1 | y>mm)=[];
    %     inds = D(y,x);
    %     tpts = pts(inds(:),:);
    for j=1:m
        minenergy = 10000000;
        minpos = round(numel(neighbor)/2);
        pt2 = pts(i+1,:) + [0 0 neighbor(j)];
        exte = getexternalenergy(pt2,im,w);
        ginte = abs(pt2(3)-floor(m/2)-polyval(ply,pt2(2))); 
        im2 = double(im(pt2(2)-w:pt2(2), pt2(1)-w:pt2(1)+w, pt2(3)))/255;
        im2 = im2(:) - mean(im2(:)); im2 = im2/norm(im2);
        for k=1:m
%             disp([i,j,k]);
            pt1 = pts(i,:) + [0 0 neighbor(k)];
            im1 = double(im(pt1(2):pt1(2)+w, pt1(1)-w:pt1(1)+w, pt1(3)))/255;
            im1 = im1(:) - mean(im1(:)); im1 = im1/norm(im1);
            if i==1
                energy = alpha * (getexternalenergy(pt1,im,w)+exte) + ...
                    beta * -(im1' * im2) + ...
                    gamma * (abs(pt1(3)-floor(m/2)-polyval(ply,pt1(2)))+ ginte);
            else
                energy = energymtx(k,i-1) + alpha * exte + ...
                    beta * -(im1' * im2) + ...
                    gamma * ginte;
            end
            if energy < minenergy
                minenergy = energy;
                minpos = k;
            end
        end
        energymtx(j,i) = minenergy;
        posmtx(j,i) = minpos;
    end
end

[finalenergy,pos] = min(energymtx(:,end-1));

for i=n:-1:1
    pts(i,3) = pts(i,3) + neighbor(pos);
    if i>1
        pos = posmtx(pos,i-1);
    end
end
pts(:,3) = min(max(1,pts(:,3) - floor(m/2)),pp);
end

function ie = getinternalenergy(pts)
A = [pts(:,2),pts(:,1),ones(size(pts,1),1)];
ie = sum(abs(pts(:,3)-A*(A\pts(:,3))));
end

function ee = getexternalenergy(pts,im,w)
ee=0;
n = size(pts,1);
for i=1:n
    img = im(pts(i,2)-w:pts(i,2)+w, pts(i,1)-w:pts(i,1)+w, pts(i,3));
    ee = ee + 2*(fmeasure(img,'ACMO',[])/127) + (double(mean2(img))/255);
end
ee = -ee;
end

function ee = getsimilarityscore(pts,im,w)
n = size(pts,1);
ee=0;
if n==2
    img1 = double(im(pts(1,2):pts(1,2)+w, pts(1,1)-w:pts(1,1)+w, pts(1,3)))/255;
    img2 = double(im(pts(2,2)-w:pts(2,2), pts(2,1)-w:pts(2,1)+w, pts(2,3)))/255;
    m1 = mean(img1(:)); m2 = mean(img2(:));
    img1 = img1(:)-m1; img2 = img2(:)-m2;
    img1 = img1/norm(img1); img2 = img2/norm(img2);
    ee = -(img1'*img2);
end
end
