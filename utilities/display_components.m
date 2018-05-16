function display_components(A,C,sz)
% DISPLAY_COMPONENTS function that allows one to visualize results of a
% matrix factorization in terms of the inferred spatial components (A) and
% temporal components (C)

R = size(A,2);

d1 = sz(1); d2 = sz(2);

figure();
colormap gray;

for i = 1:R
    subplot(121)
    imagesc(reshape(A(:,i),d1,d2));
    title(sprintf('Spatial component %d',i))
    subplot(122); plot(C(i,:));
    title(sprintf('Temporal component %d',i));
    pause;
end