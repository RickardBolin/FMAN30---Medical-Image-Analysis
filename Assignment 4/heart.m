path = '/Users/rickard/Documents/MATLAB/FMAN30 - Medical Image Analysis/Assignment 4/Assignment-4/images/MR-thorax-transversal';
[im, info] = mydicomreadfolder(path);

spacing = strsplit(info.PixelSpacing, '\');
%%
[sx, sy, sz] = size(im);
depth = [info.Rows*str2double(spacing(1)), 0];
width = [0, info.Columns*str2double(spacing{2})];
height = [0, int8(info.SpacingBetweenSlices*(sz-1) + str2double(info.SliceThickness)*sz)];

% Transverse plane (x=width, y=depth)
figure

imagesc(width, depth, flipdim(im(:,:,sz/2), 1)*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 20)
colormap('gray')
title('Transverse plane', 'FontSize', 24)
xlabel('Width (mm)', 'FontSize', 24)
ylabel('Depth (mm)', 'FontSize', 24)
axis image


% Coronal plane (x=width, y=height)
figure
im_coronal = im(sx/2,:,:);
im_coronal = reshape(im_coronal, [sy, sz]);
im_coronal = transpose(im_coronal);
imagesc(width, height, im_coronal*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 20)
colormap('gray')
title('Coronal plane', 'FontSize', 24)
xlabel('Width (mm)', 'FontSize', 24)
ylabel('Height (mm)', 'FontSize', 24)
axis image

% Sagital plane (x=depth, y=height)
figure
im_sagital = im(:,sy/2,:);
im_sagital = reshape(im_sagital, [sx, sz]);
im_sagital = flip(transpose(im_sagital), 2);

imagesc(depth, height, im_sagital*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 20)
colormap('gray')
title('Sagital plane', 'FontSize', 24)
xlabel('Depth (mm)', 'FontSize', 24)
ylabel('Height (mm)', 'FontSize', 24)
axis image


%% Maximum intensity projection
%  NOT PART OF ASSIGNMENT
%close all
% Transverse plane (x=width, y=depth)
%figure
%im_trans = max(im,[],3);

%imagesc(width, depth, im_trans*255)
%colorbar
%colormap('gray')
%title('Transverse plane')

% Coronal plane (x=width, y=height)
%figure
%im_coronal = max(im,[],1);
%im_coronal = reshape(im_coronal, [sy, sz]);

%im_coronal = transpose(im_coronal);
%imagesc(width, height, im_coronal*255)
%colorbar
%colormap('gray')
%title('Coronal plane')

% Sagital plane (x=depth, y=height)
%figure
%im_sagital = max(im,[],2);
%im_sagital = reshape(im_sagital, [sx, sz]);
%im_sagital = flip(transpose(im_sagital),2);

%imagesc(depth, height, im_sagital*255)
%colorbar
%colormap('gray')
%title('Sagital plane')



