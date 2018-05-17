function [ A ,ctr_pixels] = initialize_A_PCN(data2use,center_coords,Ysiz,rectBounds)
% Initialize spatial footprints by doing local PCAs centered on data around
% the user-given center-points. Bounding box area for local-PCA-ing is given by rectBounds(1) x
% rectBounds(2)
%   Detailed explanation goes here


d1 = Ysiz(1); d2 = Ysiz(2);

numCells = size(center_coords,1);

A = zeros(d1*d2,numCells);
ctr_pixels = zeros(1,numCells);

for i = 1:numCells
    
    r = center_coords(i,1);
    c = center_coords(i,2);
    
    rsub = max(1, -rectBounds(1)+r):min(d1, rectBounds(2)+r);
    csub = max(1, -rectBounds(1)+c):min(d2, rectBounds(2)+c);
    d1p = length(rsub);
    d2p = length(csub);

    [rgrid,cgrid] = meshgrid(rsub,csub);
    ind_nhood = sub2ind([d1 d2],rgrid,cgrid);
    
    ctr_pixels(i) = sub2ind([d1,d2],r,c);

    chunk = double(data2use(ind_nhood,:));
    pcs = pca(chunk');
    atemp = pcs(:,1);
    
    %% threshold the spatial shape and remove outliers
    % remove outliers
    % need to define center_ind relative to center of patch
    
    relative_r = r - rsub(1) + 1;
    relative_c = c - csub(1) + 1;
    center_ind = sub2ind([d1p,d2p],relative_r,relative_c);
    
    % do some thresholding and shit
    temp =  full(atemp>quantile(atemp(:), 0.5));
    l = bwlabel(reshape(temp, d1p, d2p), 4);
    temp(l~=l(center_ind)) = false;
    atemp(~temp(:)) = 0;

    A(ind_nhood,i) = atemp;
        
end

