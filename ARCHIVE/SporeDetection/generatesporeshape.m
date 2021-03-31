function [gs,gb,sh] = generatesporeshape(sporeshape,n,scl,rescale)
scl = min(1,scl);
numpix = 1/scl;
func = @(x)max(x.data(:));
if isstruct(sporeshape)
    sr = floor(sporeshape.Width);
    st = sporeshape.Length;
    c = [sporeshape.Radius, sporeshape.Orientation];
    o = sporeshape.Offset;
else
    c = [sporeshape(1), sporeshape(5)];
    sr = floor(sporeshape(2));
    st = sporeshape(3);
    o = sporeshape(4);
end

sr1=sr;
sc=2^2;
st = 1*st;
sr = sqrt((1-1/sc)/(2*log(sc)))*sr;
[x,y] = meshgrid(0:scl:n-scl,0:scl:n-scl);
y = y(end:-1:1,:);
[c(1),c(2)] = pol2cart(deg2rad(c(2)),c(1));

vec = c./norm(c);
if norm(c)==0
    vec = [1 0];
end

rtm = [cos(-o) -sin(-o); sin(-o) cos(-o)];
xvec = (rtm * vec')';
yvec = [-xvec(2), xvec(1)];

c = c + round([n/2 n/2]);
x = x-c(1);
y = y-c(2);
x1 = reshape([x(:), y(:)] * xvec', size(x));
y1 = reshape([x(:), y(:)] * yvec', size(y));
[t,r] = cart2pol(x1,y1);
n = max(size(x));

pt = [(n/2)-c(1)/scl,(n/2)-c(2)/scl];
pt = xvec * (pt * xvec');
pt = round(pt + c/scl);
tc = t(pt(2),pt(1));
% rc = r(pt(2),pt(1));
rc = r(round(n/2),round(n/2));

dr = r-rc;
dt1 = abs(t-tc);
dt1(dt1>pi) = 2*pi-dt1(dt1>pi);
msk = (sign(t)==sign(o));
stm = zeros(size(msk));
tst = 2*st;
st1 = st-abs(o);
st2 = tst-st1;
stm(msk)=st1;
stm(~msk)=st2;
% sh = (dt1./stm).^2 + (dr/sr1).^2;
sh = (1-(dt1./stm).^2 - (dr/sr1).^2);
% cmsk = (1-(dt1./stm).^2 - (dr/sr1).^2)>-0.5;
dt1(msk) = min(dt1(msk),st1);
dt1(~msk) = min(dt1(~msk),st2);

c = 1./(2*(1-(dt1./stm).^2));
% c(c==Inf)=0;
% c = max(0,c);

if rescale
    gb = blockproc(1/sc * exp( -c .* ((1/sc)*(dr/sr).^2) ),[numpix,numpix],func) - ...
        blockproc(exp( -c .* ((dr/sr).^2) ), [numpix,numpix], func);
    gs =  blockproc(double(c>0).*exp( -c .* ((dr/sr).^2) ),[numpix,numpix],func);
else
    gb = 1/sc * exp( -c .* ((1/sc)*(dr/sr).^2) ) - ...
        exp( -c .* ((dr/sr).^2) );
    gs =  double(c>0).*exp( -c .* ((dr/sr).^2) );
end

% gs = gs.*bmsk;
% gb = gb.*bmsk;
% gb = gb.*imdilate(bmsk,ones(round(5/scl)));

end