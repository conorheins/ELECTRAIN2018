function ROIs_on_video(img_sequence,mask_stack,Fs,speed_up_factor)
% ROIS_ON_VIDEO Uses image sequence and stack of binary masks to show
% instantaneous video data with hand-selected ROIs overlaid

if nargin < 4 || isempty(speed_up_factor)
    speed_up_factor = 1;
end

[~,~,T] = size(img_sequence);

inter_frame_time = (1/Fs)/speed_up_factor;

cmin = min(img_sequence(:));
cmax = max(img_sequence(:));

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries = bwboundaries(sum(mask_stack,3));

figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

colormap gray;
for t = 1:T
    imagesc(img_sequence(:,:,t),[cmin cmax]);
    for i = 1:length(structBoundaries)
       hold on;
       plot(structBoundaries{i}(:,2),structBoundaries{i}(:,1),'r','LineWidth',2);
    end
    pause(inter_frame_time);
    hold off;
end