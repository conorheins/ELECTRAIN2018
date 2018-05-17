% demo script for running non-negative matrix factorization to extract
% neural activity from Ca2+ imaging recordings

addpath(genpath('utilities'));

%% load in data

[fnam,fdir] = uigetfile('*.tif'); % open ui window for choosing .tif file
img_nam = fullfile(fdir,fnam); % combine file directory and name to create image file name

img = loadtiff(img_nam); % loadtiff(img_nam, start_frame, numFrames2Read) - can also specify start frame and until when to read

%%  downsampling
% aggressive downsampling to make the factorization less
% computationally-expensive

spatial_ds_factor = 4;
temporal_ds_factor = 1;

psf = fspecial('average',[10 10]); % average filter of 10 x 10 pixels
img_filt = imfilter(img,psf,'replicate');
img_filt = img_filt(1:spatial_ds_factor:end,1:spatial_ds_factor:end,1:temporal_ds_factor:end);

%% generation of statistical image

corr_image = generate_stat_image(single(img_filt),'correlation',[1 10]);
std_image = generate_stat_image(single(img_filt),'stdev'); 
stat_image = corr_image.*std_image; 

%% find active pixels based on upper end of stat_image pixel intensity histogram

percent_thr = 80;
stat_thresh = prctile(stat_image(:),percent_thr); % only include pixels that are above percent_thr of values in the stat image
active_pixel_ind = stat_image > stat_thresh; % set a mask based on threshold

%% run matrix factorizations on active pixels

[d1s,d2s,Ts] = size(img_filt); % get dimensions of image data (post-downsampling)

Y = reshape(img_filt,d1s*d2s,Ts); % reshape video into matrix for factorization purposes

all_active_pixels = Y(find(active_pixel_ind),:); % extract pixel data under mask

R = 10; % choose rank for factorization

% initialize spatial components with Principal Components Analysis (PCA)
[coeff,scores] = pca(single(all_active_pixels)');
coeff_thr = threshold_initial_A(coeff(:,1:R),85); % threshold principal components to get rid of negative coefficients

% non-negative matrix factorization with initialized spatial components
[W,H] = nnmf(single(all_active_pixels)',R,'h0',coeff_thr');

A = zeros(d1s*d2s,R);
A(find(active_pixel_ind),:) = H';
C = W'; clear W H;

image_dims = [d1s, d2s];

display_components(A,C,[d1s d2s])

% Merge redundantly-discovered components

merge_type = 'spatial'; % what information to use for the merge ('spatial' or 'temporal')
merge_thr = [0.5 0.5]; % merge thresholds -- spatial and then temporal
display_flag = 1; % boolean flag for whether to display the components to be merged

[A_merge,C_merge,K_merge] = neuron_merge(A, C, [d1s,d2s], 'spatial', [0.5 0.5], 1);
        
display_components(A_merge,C_merge,[d1s d2s]) % display components after merging
