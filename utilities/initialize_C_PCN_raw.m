function C = initialize_C_PCN_raw(A_init,data2use,bg,center_coords,rectBounds)

% Initialize C by running a few iterations of HALS on data centered around
% cell center
%   Uses background to subtract local background patch around cell of
%   interest

[d1,d2,T] = size(data2use);

numROIs = size(A_init,2);
C = zeros(numROIs,T);

for i = 1:numROIs
    
    fprintf('Extracting trace from neuron (%d / %d)\n',i,numROIs)
    r = round(center_coords(i,1));
    c = round(center_coords(i,2));
    rsub = max(1, -rectBounds(1)+r):min(d1, rectBounds(2)+r);
    csub = max(1, -rectBounds(1)+c):min(d2, rectBounds(2)+c);
    [cind, rind] = meshgrid(csub,rsub);
    [d1p,d2p] = size(cind);
    ind_nhood = sub2ind([d1,d2],rind(:),cind(:));
    
    relative_r = r - rsub(1) + 1;
    relative_c = c - csub(1) + 1;
    
    center_ind = sub2ind([length(rsub),length(csub)],relative_r,relative_c);
    
    Y_box = cast(reshape(data2use(rsub,csub,:),d1p*d2p,[]),'double');
    localBG = cast(reshape(bg(rsub,csub,:),d1p*d2p,[]),'double');
    ai = reshape(A_init(ind_nhood,i),d1p,d2p);
    
    detrended_chunk = Y_box - localBG;
    y0 = detrended_chunk(center_ind,:);
    tmp_corr = reshape(corr(y0', detrended_chunk'), d1p, d2p);
    cell_pixels = find(tmp_corr > 0.3 & ai > 0);
    
    ci = mean(Y_box(cell_pixels,:),1);
    ai = reshape(ai,d1p*d2p,1);
    
    C(i,:) = HALS_temporal(Y_box, ai, ci, 5);
    
      
end

