function [raw_traces,background_traces] = extract_traces(img_sequence,mask_stack)
% EXTRACT_TRACES Function that extracts fluorescence within the pixels
% given by a stack of ROI masks (binary images) as well as calculates a
% background component that can be subtracted from the raw traces

% INPUTS: img_sequence: time-lapsed fluorescence data (d1 x d2 x T) to extract
%                       ROI-specific fluorescence from
%         mask_stack:   d1 x d2 x numberROIs stack of binary masks that
%                       determine which pixels go into calculation of
%                       fluorescence trace

% OUTPUTS:  raw_traces: mean fluorescence from ROIs within each frame, concatenated across frames 
%    background_traces: median fluorescence from bounding box surrounding
%                       each box, but not including pixels within the mask

nROIs = size(mask_stack,3);
[d1s,d2s,T] = size(img_sequence);
raw_traces = zeros(nROIs,T);
background_traces = zeros(nROIs,T);

Y = reshape(img_sequence,d1s*d2s,T);

for i = 1:nROIs
    
    [rsub,csub] = find(mask_stack(:,:,i));
    
    bg_box_minr = max( min(rsub)-10, 1);
    bg_box_maxr = min( max(rsub) + 10, d1s);
    
    bg_box_minc = max( min(csub) - 10, 1);
    bg_box_maxc = min( max(csub) + 10, d2s);
    
    bg_mask = false(d1s,d2s);
    bg_mask(bg_box_minr:bg_box_maxr,bg_box_minc:bg_box_maxc) = true;
    
    mask_pix_ind = find(mask_stack(:,:,i));
    bg_pix_ind = find(bg_mask & ~mask_stack(:,:,i));
    
    raw_traces(i,:) = mean(Y(mask_pix_ind,:),1);
    background_traces(i,:) = mean(Y(bg_pix_ind,:),1);
    
end