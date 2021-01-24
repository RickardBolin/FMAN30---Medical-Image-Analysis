path = '/Users/rickard/Documents/MATLAB/FMAN30 - Medical Image Analysis/Assignment 4/Assignment-4/images/MR-carotid-coronal';
[im, info] = mydicomreadfolder(path);

spacing = strsplit(info.PixelSpacing, '\');

[sx, sy, sz] = size(im);
height = [info.Rows*str2double(spacing(1)), 0];
width = [0, info.Columns*str2double(spacing{2})];
depth = [0, int8(str2double(info.SpacingBetweenSlices)*(sz-1) + str2double(info.SliceThickness)*sz)];

%% Maximum intensity projection
% Transverse plane (x=width, y=depth)
figure
im_trans = max(im,[],1);
im_trans = reshape(im_trans, [sx, sz]);
im_trans = transpose(im_trans);

imagesc(width, depth, im_trans*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 16)
colormap('gray')
title('Transverse plane, MIP', 'FontSize', 20)
axis image
xlabel('Width', 'FontSize', 20)
ylabel('Depth', 'FontSize', 20)

% Coronal plane (x=width, y=height)
figure
im_coronal = max(im,[],3);
%im_coronal = transpose(im_coronal);
imagesc(width, height, flipdim(im_coronal,1)*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 16)
colormap('gray')
axis image
title('Coronal plane, MIP', 'FontSize', 20)
xlabel('Width (mm)', 'FontSize', 20)
ylabel('Height (mm)', 'FontSize', 20)

% Sagital plane (x=depth, y=height)
figure
im_sagital = max(im,[],2);
im_sagital = reshape(flipdim(im_sagital,1), [sx, sz]); 
im_sagital = flip(im_sagital, 2);  % SKA DENNA FLIPPAS?
imagesc(depth, height, im_sagital*255)
set(gca,'xcolor',[1 0 0],'ycolor',[1 0 0]);
set(gca,'ticklength',[0.05 0.05]);
ax = gca;
ax.FontSize = 16; 
colorbar('FontSize', 16)
colormap('gray')
title('Sagital plane, MIP', 'FontSize', 20)
xlabel('Depth (mm)', 'FontSize', 20)
ylabel('Height (mm)', 'FontSize', 20)
axis image

