function [A_init] = threshold_initial_A(initial_components,prct)
% THRESHOLD_INITIAL_A This function thresholds a set of initial spatial
% components for subsequent use in non-negative matrix factorization

A_init = zeros(size(initial_components));

for i = 1:size(initial_components,2)
    tmp = initial_components(:,i);
    thr = prctile(tmp,prct);
    tmp(tmp < thr) = 0;
    A_init(:,i) = tmp;
end