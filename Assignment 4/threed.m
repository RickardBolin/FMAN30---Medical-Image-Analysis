path = '/Users/rickard/Documents/MATLAB/FMAN30 - Medical Image Analysis/Assignment 4/Assignment-4/images/MR-carotid-coronal';
[im, info] = mydicomreadfolder(path);

spacing = strsplit(info.PixelSpacing, '\');

[sx, sy, sz] = size(im);
height = [info.Rows*str2double(spacing(1)), 0];
width = [0, info.Columns*str2double(spacing{2})];
depth = [0, int8(info.SpacingBetweenSlices*(sz-1) + str2double(info.SliceThickness)*sz)];
%% Shoe 3D image
imshow3D(im)

%% Manually selected point (left?)
%x = 361;
%y = 297;
%z = 30;
%% Manually selected point (right?)
x = 128;
y = 285;
z = 26;

%% Calculate speed image
slider1 = 1;
slider2 = 1;
slider3 = 1;
[~,~,N] = size(im);

speed = zeros(size(im));
for i = 1:N
    im_i = im(:,:,i);
    % Shift min value to zero
    if min(im_i, [], 'all') < 0
        im_i = im_i - min(im_i, [], 'all');
    end

    % Normalize image
    im_i(im_i > 0) = (im_i(im_i > 0) - min(im_i(im_i > 0), [], 'all')) / (max(im_i(im_i > 0), [], 'all') - min(im_i(im_i > 0), [], 'all'));

    %im_i = imadjust(im_i, [0.1, 0.9]);

    %im_int = im_i.^(slider2*0.1);
    %blur = slider2*imgaussfilt(im_int, slider2*0.03 + 0.001);

    %conn = grayconnected(im_i, y, x, 0.1);
    %conn = imfill(conn, 'holes');
    
    %edge = imfilter(imgaussfilt(im_i, 1.5), fspecial('laplacian'), 'same');
    %edge = bwareafilt(imcomplement(imbinarize(im_i)), 5);% [1e2, 1e6]);
    %edge = imdilate(edge, strel('disk',double(slider3*100)));

    %speed_i = 0*blur + 0*slider1*conn - 5*edge;
    speed_i = im_i > 0.45;
    %speed_i = speed_i.*imerode(imbinarize(speed_i), strel('disk',double(slider3*100))); 

    % Make sure that the speed of the object at the seed is larger than its bounds
    %if speed_i(y,x) > mean(speed_i, 'all')
    %    speed_i = imcomplement(speed_i);
    %end

    % Normalize, apply squared cos and set low values to zero
    %speed_i = (speed_i - min(speed_i, [], 'all')) / (max(speed_i, [], 'all') - min(speed_i, [], 'all'));
    %speed_i = cos(speed_i).^2;
    %speed_i(speed_i > 0.4) = 1;
    %speed_i(speed_i < 0.4) = 1e-7;
    speed_i(speed_i > 0) = 1e-6;

    speed(:,:,i) = speed_i;
end

%for i = 1:N
%    speed(:,:,i) = imcomplement(speed(:,:,i));
%end
%%
imshow3D(speed)
%%
CC = bwconncomp(speed);
new = zeros(size(speed));
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
new(CC.PixelIdxList{idx}) = 1;
%%
imshow3D(new)

%% Segmentation
segmented = msfm3d(speed, [y;x;z], true, true);
%%
imshow3D(segmented)

%%
%s = smooth3(segmented);
%s = smooth3(speed,'box');

p1 = patch(isosurface(speed),...
   'FaceColor','black','EdgeColor','red');
%isonormals(segmented,p1);
reducepatch(p1,0.5);
view(3); 
axis vis3d
camlight left
lighting phong


hold on
p1 = patch(isosurface(new),...
   'FaceColor','b','EdgeColor','blue');
%isonormals(segmented,p1);
reducepatch(p1,0.5);
view(3); 
axis vis3d
camlight left
lighting phong

title('Segmented right carotid', 'FontSize', 24)
xlabel('Width (mm)', 'FontSize', 20)
ylabel('Height (mm)', 'FontSize', 20)
zlabel('Depth (mm)', 'FontSize', 20)