function [masks,nROIs] = choose_ROIs(img)
% CHOOSE_ROIs wrapper function for user-driven while loop that iteratively
% asks for freehand selections on the provided 2D image img. Stores
% associated binary masks in masks

keep_choosing = true;
[d1,d2,~] = size(img);

masks = zeros(d1,d2,1);

figure;
colormap gray;
imagesc(img); 

mask_iter = 1;
while keep_choosing
    fprintf('Choose to segment a new ROI, stop selecting, or re-do previous selection (y/n/r, default n)\n');
    choice_string = input('','s');
    if strcmp(choice_string,'y')
        temp_obj = imfreehand(gca,'Closed',true);
        temp_mask = temp_obj.createMask();
        masks(:,:,mask_iter) = temp_mask;
        mask_iter = mask_iter + 1;
    elseif strcmp(choice_string,'r')
        temp_obj.delete();
        mask_iter = mask_iter - 1;
        masks(:,:,mask_iter) = zeros(d1,d2);
        temp_obj = imfreehand(gca,'Closed',true);
        temp_mask = temp_obj.createMask();
        masks(:,:,mask_iter) = temp_mask;
        mask_iter = mask_iter + 1;
    else
        keep_choosing = false;
    end
end

nROIs = size(masks,3);

end