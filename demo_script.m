%% demo script for loading and extracting fluorescence from Ca2+ imaging videos

addpath(genpath('utilities'));

%% load in data

[fnam,fdir] = uigetfile('*.tif'); % open ui window for choosing .tif file
img_nam = fullfile(fdir,fnam); % combine file directory and name to create image file name

img = loadtiff(img_nam); % loadtiff(img_nam, start_frame, numFrames2Read) - can also specify start frame and until when to read

%% play fluorescence video 

Fs = 5; % frames per second / Hz
speed_up_factor = 5; % how much to speed up video during display
min_subtract_flag = false; % boolean flag for whether to subtract background or not

play_video(img,Fs,speed_up_factor,min_subtract_flag) % wrapper for playing Ca2+ videos
pause;
close gcf;

%% filter and spatially-downsample (if you want, will save time later)

spatial_ds_factor = 2;
psf = fspecial('average',[10 10]); % average filter of 10 x 10 pixels
img_filt = imfilter(img,psf,'replicate');
img_filt = img_filt(1:spatial_ds_factor:end,1:spatial_ds_factor:end,:);

%% Create statistical image that you can use for selecting regions-of-interest (ROIs)

corr_image = generate_stat_image(single(img_filt),'correlation',[1 10]); % creates statistical image with desired statistic 
                                               % (e.g. 'mean','max','min','median','correlation','stdev')
std_image = generate_stat_image(single(img_filt),'stdev');                                   

%% choose ROIs using hand-drawn selections

stat_image = corr_image.*std_image; % scale the correlation image by the variance at each pixel -- this way, you 'penalize' pixels that have
                                    % high local correlation but don't change a lot over time

[all_masks,nROIs] = choose_ROIs(stat_image);

%% show results of ROI selection overlaid on video data
ROIs_on_video(img_filt,all_masks,Fs,speed_up_factor)

%% extract fluorescence within ROI masks

[raw_traces,bg_traces] = extract_traces(img_filt,all_masks);

%% DF/F0 Calculation
% calculate 'delta-F/F'-like quantity by smoothing bg traces, then
% subtracting and dividing by this smoothed estimate

window_length = 2; % in seconds
window_overlap = 1; % in seconds
dF_F0 = calc_dFF_traces(raw_traces,bg_traces,Fs,window_length,window_overlap);

%% visualize all traces

[nROIs,T] = size(dF_F0);

t_axis = [1:T]/Fs;

% create offsets along Y-axis for visualization purposes
shift_interval = ceil(max(range(dF_F0,2)));
shifts = repmat(1:shift_interval:(shift_interval*nROIs),T,1); 

figure;
plot(dF_F0'+ shifts,'b','LineWidth',1.5); axis tight;
xlabel('Time (s)','FontSize',16)
ylabel('Normalized Fluorescence Change (AU)','FontSize',16);


