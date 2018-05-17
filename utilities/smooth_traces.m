function [smoothed_matrix] = smooth_traces(data_matrix,Fs,Tw,Ts)
% SMOOTH_TRACES Function that smooths each row in a matrix of time-series, 
% of dimensions N x T, where N is the dimensionality of the time-series,
% and T is the recording length

% Inputs: same as for Chronux's locsmooth function (see below):
%  Running line fit (using local linear regression) - continuous
%  processes
%  Usage: data=locsmooth(data,Fs,Tw,Ts)
%  Inputs:
% Note that units of Fs, movinwin have to be consistent.
%  data_matrix  (N x T matrix) 
%  Fs    (sampling frequency) - optional. Default 1
%  Tw    (length of moving window) - optional.  Default. full length of data (global detrend)
%  Ts    (step size) - optional. Default Tw/2.
% 
% Output:
% smoothed_matrix   (locally smoothed data).

n = size(data_matrix,1);

for i = 1:n
    smoothed_matrix(i,:) = locsmooth(data_matrix(i,:),Fs,Tw,Ts);
end
