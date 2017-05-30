function peaks = findprominentpeaks(a,n,w,d)
%a --> intensity profile
%n --> number of peaks to find
%w --> window size for smoothing/non-max suppression.
%d --> minimum distance between peaks.

a = a/max(abs(a)); %normalize input profile
w = w-1*mod(w,2); %make w even
t = a; %make temp copy of the input profile
 %supress non-max
a = imdilate(a,ones(1,w));
a(a>t)=0;

%initial estimate of peaks
peaks = 1:numel(a);
[~,b] = findpeaks([0 a 0]);
peaks = peaks(b-1);
peaks = sort(peaks);

%filter initial estimate ofpeaks to find 'n' promininet peaks
while numel(peaks) > n 
    v = t(peaks); %values at peaks
    dv1 = imfilter(v,[-1,1,0],'replicate'); %backward differene of values
    dv2 = imfilter(v,[0,1,-1],'replicate'); %forward difference of values
    d1 = abs(imfilter(peaks,[-1,1,0],'replicate')); %backward difference of peak positions
    d2 = abs(imfilter(peaks,[0,1,-1],'replicate')); %forward difference of peak positions
    ii=find((dv1 < 0 & dv2 < 0 & (d1 < d | d2 < d))...
        | (dv1 < -0.3 & d1 < d) | (dv2 < -0.3 & d2 < d)); %filter non-prominent peaks
    if isempty(ii)
        break;
    else
        peaks(ii)=[];
    end
end

%if there are still more than n peaks remove peaks that are close to
%previous peak(distance less than threshold 'd')
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

%return peaks
peaks = unique(peaks);
end