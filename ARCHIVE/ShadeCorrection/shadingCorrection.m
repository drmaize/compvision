function [imgs, shading] = shadingCorrection(img1,blks,rot,nhi,ovrlp,sthresh)
% imgl --> input image
% blks --> num of horizontal image blocks
% rot --> rotation angle to rotate image if required
% nhi --> number of vertical blocks
% ovrlp --> approx overlap in pixels between adjacent tiles 
% ssthresh --> threshold (error of fitting a cubic function to the mean projected image-intensity profile) to automatically detect if shading correction is required

img = imrotate(double(img1),rot,'crop');
blksz = floor(size(img,1)/blks);
img = img(:,ovrlp+1:end-ovrlp);
shading = zeros(size(img));

vd = mean(img); %mean intensity projection on the X-axis.
%fit a cubic function to the mean intensity profile 
A = [ (1:numel(vd))' .* (1:numel(vd))' .* (1:numel(vd))' , (1:numel(vd))' .* (1:numel(vd))' , (1:numel(vd))' , ones(numel(vd),1)];
fx = A\vd';
vr = mean(abs(vd' - A*fx)./vd')*100;

%check if shade correction is required based on the error in approximation
%by the cubic function.
if vr > sthresh
    mval = mean(img);
    mval = max(mval)-mval; %invert mean intensity profile
    xs = findprominentpeaks(mval,11,31,180); %find prominent peaks (assuming there are 10 tiles per row of the image)
    if numel(xs)==10 %make sure that there are 11 peaks
        xs = [ovrlp xs];
    end
    
    for xi = 1:1:11-nhi % horizontally divide the image into overlapping block each containing nhi tiles.
        x11 = xs(xi);
        x22 = xs(xi+nhi);
        tempshading = zeros(size(img)); %place holder for shading profile
        for y11 = 1:blksz:size(img,1)-11 % vertically divide the image with each block of height blksz
            
            %     v = mean(img(y11:y22,:),1);
            %     mv1 = v<1;
            %     x1 = find(mv1(1,:),1,'first');
            %     x2 = size(mv1,2)-find(mv1(1,end:-1:1),1,'first') + 1;
            %     mv2 = v(x1:x2)>1;
            %     x1 = x1+find(mv2,1,'first');
            %     x2 = x2-find(mv2(1,end:-1:1),1,'first');
            
            y22 = y11+blksz-1;
            if y22 > size(img,1) || y22 == size(img,1)-10
                y22 = size(img,1);
            end
            
            imgc = double(img(y11:y22,x11:x22)); %current image block being processed
            vd = mean(imgc);
            %quadratic approximation of the profile
            A = [(1:numel(vd))' .* (1:numel(vd))' ,(1:numel(vd))' , ones(numel(vd),1)];
            fx = A\vd';
            vr = mean(abs(vd' - A*fx)./vd')*100;
            
            %if shade correction required for the current block
            if vr > 3
                
                %find low frequencies that are a multiple of number of
                %horizontal tiles in the current block
                f = fftshift(fft(max(0,log(vd))));
                fmag = abs(f);
                c = find(fmag==max(fmag(:)));
                [pks,locs] = findpeaks(fmag);
                
                [~,ix] = sort(pks,'descend');
                locs = locs(ix);
                
                sh1=nhi;%abs(locs(2)-locs(1));
                locs2 = abs(locs-locs(1));
                locs2 = mod(locs2,sh1);
                ii = find(locs2==0 & abs(locs-locs(1)) < 100);
                
                mask = zeros(size(fmag));
                mask(locs(ii(2:end)))=1;
                mask(c)=1;
                
                %these low frequencies form the shading profile of the
                %current block
                vv2 = abs(ifft(f.*mask));
                %     vv2 = mean(nimg);
                
                %         vv2 = bandpass1d(max(0,log(vd)),0,nhi,nhi*10,1,[]);
                
                
                %     [a1,b1] = findpeaks(imfilter(vd,ones(1,15)/15));
                %     [a,b] = findpeaks(imfilter(vv2,ones(1,15)/15));
                
                %horizontally align the shading profile and the mean projected intensity
                %profile of the current block. This is done by aligning the
                %prominent peaks of the intensity profiles of shading image
                %and the input image blocks
                mval = vd;
                mval = max(mval)-mval;
                b1 = findprominentpeaks(mval,nhi+1,15,150);
                mval = vv2;
                mval = max(mval)-mval;
                b = findprominentpeaks(mval,nhi+1,15,150);
                a = vv2(b);
                if numel(b1)==numel(b)-1
                    b1(end+1) = numel(vd);
                end
                a1 = vd(b1);
                
                
                db = abs(repmat(b',1,length(b1)) - repmat(b1,length(b),1));
                [mv,ii]=min(db,[],2);
                %                 ii = unique(ii);
                ij = find(mv > 63);
                ii(ij)=[];
                b(ij)=[];
                nv=zeros(size(vd));
                for j=1:length(b)-1
                    v1 = vv2(b(j):b(j+1)-1);
                    v1 = imresize(v1,[1,b1(ii(j+1))-b1(ii(j))]);
                    nv(b1(ii(j)):b1(ii(j+1))-1)=v1;
                end
                v1 = vv2(b(end):end);
                v1 = imresize(v1,[1,length(vd)-b1(ii(end))+1]);
                nv(b1(ii(end)):end) = v1;
                
                v1 = vv2(1:b(1));
                v1 = imresize(v1,[1,b1(ii(1))]);
                nv(1:b1(ii(1))) = v1;
                
                vv2=nv;
            else
                vv2 = repmat(mean(max(0,log(vd))),size(vd));
            end
            %     imwrite(repmat(1.5uint8(exp(vv2)),size(img,1),1),'shade_image.png','png');
            %     vv2 = getLightingModel(vd,nhi,10);
            
            %     vdr = repmat(vd,ovrlp*2 - 1,1);
            %     vv2r = [];
            %     for sh=-(ovrlp-1):ovrlp-1
            %         if sh < 0
            %             vv2r = [vv2r;[vv2(1-sh:end) zeros(1,abs(sh))]];
            %         else
            %             vv2r = [vv2r;[zeros(1,sh) vv2(1:end-sh)]];
            %         end
            %         %         vv2r = [vv2r;circshift(vv2,[0,sh])];
            %     end
            %     stpsz = round(size(vd,2)/(nhi/1));
            %
            %     for l=1:round(stpsz/2):size(vd,2)
            %         vvd = vdr(:,max(l,1):min(l+stpsz-1,size(vd,2))).* vv2r(:,max(l,1):min(l+stpsz-1,size(vd,2)));
            %         [~,idx] = max(sum(vvd,2));
            %         vv2(1,max(l,1):min(l+stpsz-1,size(vd,2))) = vv2r(idx,max(l,1):min(l+stpsz-1,size(vd,2)));
            % %                 if l>1
            % %                     vv2(max(l-2*ovrlp,1):min(l+2*ovrlp,size(vv2,2))) =  filter2(ones(1,round(ovrlp))/ovrlp,vv2(max(l-2*ovrlp,1):min(l+2*ovrlp,size(vv2,2))),'symmetric');
            % %                 end
            %     end
            %     vv2 = imfilter(vv2,ones(1,15)/15,'replicate');
            %             figure; plot(max(0,log(vd)),'b');hold on;plot(vv2,'r'); plot(max(0,log(vd))-(vv2)+mean(max(0,log(vd))),'g');
            %             pause;
            %     imgst= uint8(mean(exp(vv2))*(double(imgc)./repmat(exp(vv2),size(imgc,1),1)));
            
            ms = mean(tempshading(abs(tempshading)>0));
            if isnan(ms)
                tempshading(y11:y22,x11:x22) = repmat(vv2,size(imgc,1),1);
            else
                tempshading(y11:y22,x11:x22) = repmat(vv2-mean(vv2)+ms,size(imgc,1),1);
            end
            %             vv2 = exp(vv2);            
            %     imgst = double(imgc)-repmat(exp(vv2),size(imgc,1),1) + mean2(imgc);
            %     imgst= uint8(double(imgc).* repmat(nv./v,size(imgc,1),1));
            %     imgs = [imgs; [img(y11:y22,1:ovrlp) imgst(:,:) img(y11:y22,end-ovrlp+1:end)]];
            
        end
        ms = mean(shading(abs(shading)>0));
        if ~isnan(ms)
            tempshading(abs(tempshading)>0) = tempshading(abs(tempshading)>0) - mean(tempshading(abs(tempshading)>0)) + ms;
        end        
        t1 = tempshading+shading;
        t2 = (tempshading+shading)/2;
        inds1 = find(abs(shading)==0 | abs(tempshading)==0);
        inds2 = find(abs(shading)>0 & abs(tempshading)>0);
        shading(inds1) = t1(inds1);
        shading(inds2) = t2(inds2);
    end
    close all;
%     shading = imfilter(shading,ones(1,ovrlp)/ovrlp,'replicate');
    % correct shading
    imgt = max(0,log(img));
    imgs = imgt - shading;
    imgs = exp(imgs - mean2(imgs) + mean2(imgt));
else
    imgs = img;
end
