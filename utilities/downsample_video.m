function [Y_ds] = downsample_video(Y,temporal_ds_factor,Fs,Tw,Ts,spatial_ds_factor,psf)
% DOWNSAMPLE_VIDEO Uses spatiotemporal downsampling factors, combined with
% smoothing parameters, to first smooth the data and then downsample it

[d1,d2,T] = size(Y);

Yr = reshape(Y,d1*d2,T);

% % locally smooth in time before downsampling
% tic
% fprintf('Temporally smoothing every pixel with moving window size of %d and overlap of %d\n',Ts,Ts)
% Ytemp = smooth_traces(double(Yr),Fs,Tw,Ts);
% fprintf('Time taken to temporally smooth video: %.2f seconds\n',toc);
% 
% % temporal downsample
% Ytemp_ds = Ytemp(:,1:temporal_ds_factor:end);

Ytemp_ds = Yr(:,1:temporal_ds_factor:end);
Tsub = size(Ytemp_ds,2);
Ytemp_ds = reshape(Ytemp_ds,d1,d2,Tsub);

% spatial downsample
Ytemp_ds = imfilter(Ytemp_ds,psf,'replicate');
Y_ds = Ytemp_ds(1:spatial_ds_factor:end,1:spatial_ds_factor:end,:);

end