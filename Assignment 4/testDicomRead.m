heart_path = '/Users/rickard/Documents/MATLAB/FMAN30 - Medical Image Analysis/Assignment 4/Assignment-4/images/MR-heart-single.dcm';
thorax_path = '/Users/rickard/Documents/MATLAB/FMAN30 - Medical Image Analysis/Assignment 4/Assignment-4/images/CT-thorax-single.dcm';
%%
[info, heart_im] = mydicomread(heart_path);
[info, thorax_im] = mydicomread(thorax_path);

%%
imagesc(heart_im)
colormap('gray')
colorbar('FontSize', 20)
title('Heart test image', 'FontSize', 24)
axis off

%%
imagesc(thorax_im)
colormap('gray')
colorbar('FontSize', 20)
title('Thorax test image', 'FontSize', 24)
axis off


%% Remove values outside domain to get relevant scale/colorbar
thorax_im(thorax_im < -1300) = NaN;
imagesc(thorax_im)
colormap('gray')
colorbar('FontSize', 20)
title('Thorax test image, only values in domain', 'FontSize', 24)
axis off
