%% Code for part 1 of shape model project 
clc
clear
close all

% Load the DMSA images and manual segmentation
load('../Assignment 3/data hand in 3 2020/dmsa_images.mat')
load('../Assignment 3/data hand in 3 2020/man_seg.mat')
load('../Assignment 3/data hand in 3 2020/models.mat')


% Extract x- and y-coordinates
Xmcoord=real(man_seg);
Ymcoord=imag(man_seg);

% Choose patient and look at image
pat_nbr = 1;

figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy
axis equal
hold on


drawshape_comp(man_seg,[1 length(man_seg) 1],'.-r')
%%
figure
boundary = [Xmcoord, Ymcoord];
[~, min_idx] = min(boundary(:,2));
% Make lowest point of the boundary first in the list
boundary = circshift(boundary, length(boundary) - min_idx);

[x, y] = resampleLandmarks(boundary(:,1), boundary(:,2));
plot(x,y, 'r-.', 'LineWidth', 2)
plot([x; x(1)], [y; y(1)], 'r-.', 'LineWidth', 2)

hold on
plot([Xmcoord; Xmcoord(1)], [Ymcoord; Ymcoord(1)], 'b-')

title('Resampling of man\_seg.mat', 'FontSize', 20)
ylim([40,85])
scatter(Xmcoord,Ymcoord, 'bo', 'filled')
scatter(x,y,70, 'ro', 'filled')

legend({'Resampled', 'Original man\_seg.mat'}, 'FontSize', 18)
%%
subplot(1,2,1)
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
%axis xy
xlim([0,128])
ylim([0,128])
%axis equal
hold on
drawshape_comp(man_seg,[1 length(man_seg) 1],'.-r')
title('Original man\_seg.mat', 'FontSize', 20)

subplot(1,2,2)
new_seg = complex(x,y);
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
xlim([0,128])
ylim([0,128])
%axis equal
hold on
drawshape_comp(new_seg,[1 length(new_seg) 1],'.-r')
title('Resampled of man\_seg.mat', 'FontSize', 20)


%% Code for part 2 of shape model project 
clc
clear
close all

% Load the DMSA images
%load dmsa_images

% Choose patient and look at image
pat_nbr = 1;

figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy

% Load the manual segmentations
% Columns 1-20: the right kidney of patient 1-20
% Columns 21-40: the mirrored left kidney of patient 1-20
% Each row is a landmark position
load models

% Extract x- and y-coordinates
Xcoord=real(models);
Ycoord=imag(models);

% Mirror the left kidney to get it in the right position in the image
figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy
hold on
drawshape_comp(models(:,pat_nbr),[1 14 1],'.-r')
drawshape_comp((size(dmsa_images,2)+1)-models(:,pat_nbr+20)',[1 14 1],'.-r')
axis equal








%%

function [new_xs, new_ys] = resampleLandmarks(xs, ys)
% Extract x- and y-coordinates
pathXY = [xs ys; xs(1) ys(1)];
stepLengths = sqrt(sum(diff(pathXY,[],1).^2,2));
stepLengths = [0; stepLengths]; % add the starting point
cumulativeLen = cumsum(stepLengths);
finalStepLocs = linspace(0,cumulativeLen(end), 15);
finalPathXY = interp1(cumulativeLen, pathXY, finalStepLocs, 'linear');
finalPathXY = finalPathXY(1:14,:);

new_xs = finalPathXY(:,1);
new_ys = finalPathXY(:,2);
end










