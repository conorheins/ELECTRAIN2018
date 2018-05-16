function [ stat_image ] = generate_stat_image(image_sequence, stat_type,sz)
%GENERATE_STAT_IMAGE Creates 2D statistical summary image of an image
%sequence using specified statistic 
%   INPUTS: image_sequence -- d1 x d2 x T image data
%           stat_type -- 'mean','max','min','median','correlation','stdev'
%           sz -- optional argument specifiying size (in a two-element array of [dmin dmax] ) of neighborhood over
%           which to compute correlation image -- only relevant when
%           stat_type is 'correlation'

if nargin < 3 && strcmp(stat_type,'correlation')
    sz = [0,1,0; 1,0,1; 0,1,0]; % default neighborhood kernel 
end

if nargin < 2
    stat_type = 'mean'; % defaults to computing average image
end

switch stat_type
    case 'mean'
        stat_image = mean(image_sequence,3);
    case 'max'
        stat_image = max(image_sequence,[],3);
    case 'min'
        stat_image = min(image_sequence,[],3);
    case 'median'
        stat_image = median(image_sequence,3);
    case 'correlation'
        [d1,d2,~] = size(image_sequence);
        stat_image = correlation_image(image_sequence,sz,d1,d2);
    case 'stdev'
        stat_image = std(image_sequence,0,3);
end
        
        

end

