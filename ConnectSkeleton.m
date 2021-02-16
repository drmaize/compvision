function [] = ConnectSkeleton(in_filename, out_filename, gap_length, scale, endpointsOnly, window_sz, Verbose)
%       in_filename --  required. path to Nd skeleton to process
%
%       out_filename --  required. path to write the results
%
%       gap_length (optional) - a single number representing 
%       the furthest gap the algorithm will connect. Default 50
%           
%       scale (optional) - a 1xN array, where N is the dimension of bw
%       containing the scale in each dimension. Useful for medical or
%       biological data where the scan resolution is different in the z
%       dimension. Default all 1s
%
%       endpointsOnly (optional) - a (nonlogical) flag. If the flag is set to 1,
%       only endpoints can be connected -- fast. If set to 0, the algorithm will
%       connect any points -- slower, especially on large skeletons.
%       If the flag is set to 2, connections between points must include at 
%       at least 1 endpoint -- also slower. Default 2
%
%       window_sz (optional) - a 1xN array, where N is the dimension of bw, 
%       containing a window size of how to break up the original bw array.
%       Useful if the original bw array is very large in memory.
%       Set all values <= 1 to run on the entire array. Default is all 30s
%
%       verbose (optional) - a logical flag (0 or 1) that determines if the
%       program prints to the screen its progress. Default 1

if ~exist('gap_length','var')
   gap_length = 30;
else
   gap_length = str2num(gap_length);
end

if ~exist('scale','var')
   scale = [1 1 3];
else
    scale = str2num(scale);
end

if ~exist('Verbose','var')
   endpointsOnly = 2; 
else
    endpointsOnly = str2num(endpointsOnly);
end

if ~exist('window_sz','var')
   window_sz = round(scale*100);
else
    window_sz = str2num(window_sz);
end

if ~exist('Verbose','var')
   Verbose = 1; 
else
    Verbose = str2num(Verbose);
end

disp(['Reading in the stack: ' in_filename]);
stack = readStack(in_filename);
stack = bwareaopen(stack,10); %removes noise
stack = logical(stack);
tic();
bw_conn = Connect_MST_ND(stack, gap_length, scale, endpointsOnly, window_sz, Verbose);
t = toc();
disp(['The MST algorithm took ' num2str(t) 's to process the ' num2str(size(stack)) ' size array']);
disp(['Writing results of Skeleton Connection to ' out_filename]);
write_skeletal(double(bw_conn), out_filename);

end

