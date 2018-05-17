function [ center_coords ] = initialize_centers_morph_PCN(stat_image,morph_options,dmin,display_flag)
%initialize_centers_morph_PCN: Uses image morphology operations to
%initialize spatial components and merge redundantly found ones
% INPUTS: stat_image:    statistical image upon which thresholding,
%                       morphology, and ROI-seeding will be accomplished
%         morph_options: parameter structure containing options for doing image
%                       morphology
%         dmin:          max distance (in pixels) within which to  neighboring
%                       ROI-candidates are merged
%         display_flag: boolean flag for whether to display the results of
%                       the seeding


[d1,d2] = size(stat_image);

thresh_prct = morph_options.thresh_prct;
dilation_se = morph_options.dilation_se;

mask = stat_image > prctile(stat_image(:),thresh_prct);
dilated = imdilate(mask,dilation_se);

thresholded = stat_image;
thresholded(dilated == 0) = 0;

temp = imregionalmax(thresholded); % find local maxima of opened image-slice
ROIs = bwconncomp(temp); %find ROIs with 8-pixel connectivity on the regional maxima image
center_coords = zeros(ROIs.NumObjects,2);
for roi = 1:ROIs.NumObjects
    [y,x] = ind2sub([d1 d2],ROIs.PixelIdxList{roi});
    center_coords(roi,:) = [x, y];
end

center_coords = distmerge(center_coords,dmin,display_flag,stat_image);


end

