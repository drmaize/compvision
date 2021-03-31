function sporeshape = fitsporeshape(pts)
sporeshape=[];
if size(pts,1) >= 15
    pts = pts';
    %fit quadratic curves to smooth data
    [p1,p2,sizx,tpts,rt,~] = smoothsporeshape( pts );
    orientation = sign(asind(rt(2,1)))*acosd(rt(1,1)) - 90;
    
    %if both sides of the shape are curved in the same direction
    if (sign(p1(1))*sign(p2(1))) > 0
        if sign(p1(1)) == 1
            p=p1;
            p1=p2;
            p2=p;
            tpts(2,:)=-tpts(2,:);
            tpts=tpts(:,end:-1:1);
            p1(1)=-p1(1); p1(3)=-p1(3);
            p2(1)=-p2(1); p2(3)=-p2(3);
            orientation = 180 + orientation;
        end
    end
    
    %generate medial axis of the spore shape
    stp = sizx/100;
    x = -sizx/2:stp:sizx/2;
    y = [(x.*x)' x' ones(size(x,2),1)]*p1;
    npts1 = [x',y];
    y = [(x.*x)' x' ones(size(x,2),1)]*p2;
    npts2 = [x',y];
    pts = [npts1(:,1), mean([npts2(:,2),npts1(:,2)],2)]';
    
%     plot(tpts(1,:),tpts(2,:),'.');
%     hold on;
%     axis equal;
%     plot(npts1(:,1),npts1(:,2),'r.');
%     plot(npts2(:,1),npts2(:,2),'r.');
%     hold off;
%     
    %fit circle
    [pp,ferr] = CircleFitByPratt(pts');
    if ferr
        return;
    end
    %radius of curvature of the spore
    r = pp(3);
    
    %half-length of the spore measured in radians
    ex = pts(1,end);
    ey = pts(2,end);
    v1 = [0 -1];
    v2 = [ex ey-r]/norm([ex ey-r]);
    l = acos(abs(dot(v1,v2)));
    
    %half-width of the spore estimated at the thickest part across the medial
    %axis
    ix = (p2(2)-p1(2))/(2*(p1(1)-p2(1)));
    if ix >= min(x) && ix <= max(x)
        w = [ix*ix ix 1]*p1 - [ix*ix ix 1]*p2;
    else
        w=0;
    end
    w=w/2;
    
    %angular offset of the center of the spore (thickest part)
    ex = ix;
    ey = [ix*ix ix 1]*p1-w;
    v2 = [ex ey-r]/norm([ex ey-r]);
    o = sign(ix)*acos(dot(v1,v2));
    
    %error of fit
    c = [0 0];
    fx = tpts(2,:)'; fy = tpts(1,:)';
    mp = (p1(end)+p2(end))/2;
    fx = fx-mp;
    [c(1),c(2)] = pol2cart(deg2rad(0),r);
    vec = c./norm(c);
    if norm(c)==0
        vec = [1 0];
    end
    rtm = [cos(-o) -sin(-o); sin(-o) cos(-o)];
    xvec = (rtm * vec')';
    yvec = [-xvec(2), xvec(1)];
    x = fx-c(1);
    y = fy-c(2);
    x1 = reshape([x(:), y(:)] * xvec', size(x));
    y1 = reshape([x(:), y(:)] * yvec', size(y));
    [tt,rr] = cart2pol(x1,y1);
    
    pt = [-c(1),-c(2)];
    pt = xvec * (pt * xvec');
    
    [tc,~] = cart2pol(pt(1),pt(2));
    rc = r;
    
    dr = rr-rc;
    dt1 = abs(tt-tc);
    dt1(dt1>pi) = 2*pi-dt1(dt1>pi);
    msk = (sign(tt)==sign(o));
    stm = zeros(size(msk));
    tst = 2*l;
    st1 = l-abs(o);
    st2 = tst-st1;
    stm(msk)=st1;
    stm(~msk)=st2;
    alpha = 1./sqrt((dt1./stm).^2 + (dr/w).^2);
    err = mean(abs((1-1./alpha).* sqrt((pt(1)-x1).^2 + (pt(2)-y1).^2)));
    
    %set spore shape parameters
    sporeshape.Radius = r;
    sporeshape.Width = w;
    sporeshape.Length = l;
    sporeshape.Offset = o;
    sporeshape.Orientation = orientation;
    sporeshape.Points = [fx, fy];
    sporeshape.MeanError = err; % maybe correct but need to be checked
end