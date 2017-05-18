function peaks = findprominentpeaks(a,n,w,d)
a = a/max(abs(a));
w = w-1*mod(w,2);
t = a;
a = imdilate(a,ones(1,w));
a(a>t)=0;
peaks = 1:numel(a);
% while numel(peaks) > n
    [~,b] = findpeaks([0 a 0]);
    peaks = peaks(b-1);
% end
peaks = sort(peaks);
while numel(peaks) > n 
    v = t(peaks);
    dv1 = imfilter(v,[-1,1,0],'replicate');
    dv2 = imfilter(v,[0,1,-1],'replicate');
    d1 = abs(imfilter(peaks,[-1,1,0],'replicate'));
    d2 = abs(imfilter(peaks,[0,1,-1],'replicate'));
    ii=find((dv1 < 0 & dv2 < 0 & (d1 < d | d2 < d))...
        | (dv1 < -0.3 & d1 < d) | (dv2 < -0.3 & d2 < d));
    if isempty(ii)
        break;
    else
        peaks(ii)=[];
    end
end
if numel(peaks) > n
    v = t(peaks);
    d1 = abs(imfilter(peaks,[-1,1,0],'replicate'));
    d1 = d1(2:end);
    ii = find(d1<d);
    ii=ii(:);
    [~,jj] = min([v(ii);v(ii+1)]);
    ii = ii + jj'-1;
    peaks(ii)=[];
end
peaks = unique(peaks);
end