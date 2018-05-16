function [dF_F0] = calc_dFF_traces(raw_traces,background_traces,Fs,Tw,Ts)
% CALC_DFF_TRACES Function that calculates delta-F/F0 using a matrix of raw
% fluorescence traces, background traces, sampling frequency Fs, and some
% smoothing parameters. See documentation of smooth_traces or locsmooth for info on use of Fs, Tw,
% and Ts

% smoothing using locally-linear regression
F0 = smooth_traces(background_traces,Fs,3,1); 

% generate dF/F0 by subtracting instantaneous background estimate and dividing by smoothed estimate
dF_F0 = bsxfun(@rdivide,bsxfun(@minus,raw_traces,background_traces),F0); 

% normalize to between 0 and 1
dF_F0 = bsxfun(@rdivide,dF_F0 - min(dF_F0,[],2), range(dF_F0,2)); 

end