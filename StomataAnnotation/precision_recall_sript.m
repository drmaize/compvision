lst = dir('F:\stomate_annotated_data\e025SLB\*GT.png');
pred_count=[];
gt_count=[];
tp_count=[];
training_count = [];
for i=1:numel(lst)
    img = im2double(rgb2gray(imread(['F:\stomate_annotated_data\e025SLB\',lst(i).name])));
    img = img(1:2048,1:2048,1);
    mask = img>0;
    pred = im2double(imread(['F:\stomate_annotated_data\stomates5\predicted\',lst(i).name(1:end-6),'segmented.png']));
    ignoremask = false(size(mask));
    if exist(['F:\stomate_annotated_data\e025SLB\',lst(i).name(1:end-6),'training.png'],'file')
        ignoremask = logical(imread(['F:\stomate_annotated_data\e025SLB\',lst(i).name(1:end-6),'training.png']));
        ignoremask = ignoremask(1:2048,1:2048);
    end
    ignore_cc = bwconncomp(ignoremask);
    training_count = [training_count;ignore_cc.NumObjects];
    cc = bwconncomp(pred>0.9 & ~ignoremask);
    pred_count = [pred_count; cc.NumObjects];
    cc_gt = bwconncomp(mask & ~ignoremask);
    gt_count = [gt_count; cc_gt.NumObjects];
    [r,c] = find(mask & ~ignoremask);
    cc_tp = bwconncomp(bwselect(pred>0.9 & ~ignoremask,c,r,8));
    tp_count = [tp_count; cc_tp.NumObjects];
end