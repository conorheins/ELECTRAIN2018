% demo script NMF on GCaMP6m test data

addpath(genpath('utilities'));

%% load in image data

path_to_file = ['data',filesep,'example_stack.tif'];

sframe = 1;
num2read = 4000;

Y = loadtiff(path_to_file,sframe,num2read);

%% downsample in space and time to make factorization more computationally-tractable and boost SNR

temporal_ds_factor = 4; % temporal-downsampling factor
spatial_ds_factor = 3; % spatial-downsampling factor

Fs = 31.5; % frame rate / Hz
Tw = 10; % window length in seconds
Ts = 5; % window overlap in seconds

psf_width = (spatial_ds_factor*2) + 1;
psf = fspecial('average',[psf_width psf_width]); % average filter that's at least half the downsampling frequency

Y_ds = downsample_video(Y,temporal_ds_factor,Fs,Tw,Ts,spatial_ds_factor,psf);

%% estimate background & subtract from raw data

Ysiz = size(Y_ds);

bg = zeros(Ysiz,'uint16');
tic
for frame = 1:Ysiz(3)
    bg(:,:,frame) = ordfilt2(Y_ds(:,:,frame),10,true(10),'symmetric'); % uses 10-prctile filter in 10 x 10 neighborhood
end
fprintf('Time taken to estimate background: %.2f seconds\n',toc)

figure;
imagesc(mean(bg,3)); colormap gray;
title('Estimated fluorescence background, to be subtracted from raw data');

Y_thr = Y_ds - bg; % subtract background from raw data

%% play background-subtracted video

% play_video(Y_thr,ceil(Fs/temporal_ds_factor),temporal_ds_factor,0)

play_video(Y_thr,Fs,1,0);
pause; close gcf;

%% and then rectify pixels with noise threshold

denoising_opts = CNMFSetParms; % options structure for denoising
sig = 5; % multiple of noise threshold that signal must pass to not be thrown out 
Y_thr = reshape(Y_thr,prod(Ysiz(1:2)),Ysiz(3)); % reshape for noise estimation
noise_val = get_noise_fft(Y_thr,denoising_opts); % uses fft method to estimate noise
Y_thr(bsxfun(@lt,Y_thr,noise_val*sig)) = 0; % sets pixels below noise-value to 0
Y_thr = reshape(Y_thr,Ysiz); % back into d1 x d2 x T video 

%% play background-subtracted, denoised video

play_video(Y_thr,Fs,1,0);
pause; close gcf;

%% generate statistical summary images from thresholded data

Cn_img = generate_stat_image(double(Y_thr), 'correlation',[1 3]);
Stdev_img = generate_stat_image(double(Y_thr),'stdev');

stat_image = Cn_img.*Stdev_img;

%% Initialize spatial components with image morphological operations & PCA

%% morphology -- initialize centers of ROIs (stored as 'center_coords')
morph_options.thresh_prct = 80; % upper-percentile of intensity histogram of stat_image to threshold by
morph_options.dilation_se = strel('disk',1); % structuring element
dmin = 5; 
display_flag = true;
center_coords = initialize_centers_morph_PCN(stat_image,morph_options,dmin,display_flag);
center_coords = round(fliplr(center_coords)); % now the first column is the row-index (y coordinate), second column is the col-index (x coordinate)

%% PCA to initialize spatial filters A
rectSize = [8 8];
Y_thr = reshape(Y_thr,prod(Ysiz(1:2)),[]);
tic
[A,ctr_pixels] = initialize_A_PCN(Y_thr,center_coords,Ysiz,rectSize);
fprintf('Time taken to initialize spatial components: %.2f minutes\n',toc/60)

%%  thresholding and cleaning up

% get rid of components with e.g. two few non-zero pixels
A = max(0,A);
null_components = find(sum(A,1) < 5);
A(:,null_components) = [];
A_trimmed = zeros(size(A));
options.medfilt_param = [2,2];
options.nrgthr = 0.8;
options.close_elem = strel('square',2);

numCells = size(A,2);
for i = 1:numCells
   temp =  cleanup_footprints(reshape(A(:,i),Ysiz(1),Ysiz(2)),ctr_pixels(i),options);
   A_trimmed(:,i) = reshape(temp,prod(Ysiz(1:2)),1);
end
clear A;

center_coords = com(A_trimmed,Ysiz(1),Ysiz(2));

%% initialize temporal components

tic
C_init = initialize_C_PCN_raw(A_trimmed,Y_ds,bg,center_coords,rectSize);
fprintf('Time taken to initialize temporal components: %.2f seconds\n',toc)

%% display components as they've been initialized so far

display_components(A_trimmed,C_init,Ysiz(1:2))







