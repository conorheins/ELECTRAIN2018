function play_video(img_sequence,Fs,speed_up_factor,min_subtract_flag)
% PLAY_VIDEO Quick function to play stack of images (of size d1 x d2 x T)
% with a given frame rate, speed-up factor and min-subtraction flag
% if speed_up_factor is not provided, assumed to be played in real_time
% can also optionally choose to subtract the minimum frame from every
% frame, which helps with visualization -- if not provided, does not
% subtract the min

if nargin < 4 || isempty(min_subtract_flag)
    min_subtract_flag = false;
end

if nargin < 3 || isempty(speed_up_factor)
    speed_up_factor = 1;
end

if min_subtract_flag
    img_sequence = img_sequence - min(img_sequence,[],3);
end

[~,~,T] = size(img_sequence);

inter_frame_time = (1/Fs)/speed_up_factor;

cmin = min(img_sequence(:));
cmax = max(img_sequence(:));


figure;
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);

colormap gray;
for t = 1:T
    imagesc(img_sequence(:,:,t),[cmin cmax]);
    pause(inter_frame_time);
end

end

