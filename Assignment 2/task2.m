%% Install VLFeat
% Download newest bin from https://www.vlfeat.org/download/
% Unpack and save to some path
% Execute command: "run vlfeat-0.9.21/toolbox/vl_setup" 

%% Load images and scale them down by 50%
HE_imgs = dir('./Assignment-2-Data/Collection 2/HE/*.jpg');   
TRF_imgs = dir('./Assignment-2-Data/Collection 2/TRF/*.tif');   

for i=1:length(HE_imgs)
   HE_images{i} = rgb2gray(imresize(imread(fullfile(HE_imgs(i).folder, HE_imgs(i).name)), 1));
   HE_images{i} = double(HE_images{i})/double(max(max(HE_images{i})));
   
   TRF_images{i} = imresize(imread(fullfile(TRF_imgs(i).folder, TRF_imgs(i).name)), 0.5);
   TRF_images{i} = histeq(double(TRF_images{i})/double(max(max(TRF_images{i}))));
   TRF_images{i} = imcomplement(TRF_images{i});
end
shuffle = [10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9];
for i = 1:12
    HE_images_new{shuffle(i)} = HE_images{i};
    TRF_images_new{shuffle(i)} = TRF_images{i};
end
HE_images = HE_images_new;
TRF_images = TRF_images_new;

%% Find best rotation, translation and scale for all image pairs (from im1 to im2)

for i = 1:length(HE_images)
    im1 = TRF_images{i};
    im2 = HE_images{i};
    [Rs{i}, ts{i}, ss{i}, Ts{i}] = find_best_similarity_transform(im1, im2);
end

%% Save the rotation and magnitude of transition for each image
for i = 1:length(Rs)
    rotation_angles{i} = acosd(Rs{i}(1,1));
    translation_magnitudes{i} = norm(ts{i});
    scales{i} = ss{i};
end

%% Plot the unaligned and aligned images
for i = 3:length(Rs)
    im1 = TRF_images{i};
    im2 = HE_images{i};
    figure
    subplot(1,2,1)
    imshow(im1)
    subplot(1,2,2)
    imshow(im2)
    tform = projective2d(Ts{i}');
    aligned = imwarp(im1, tform, 'OutputView', imref2d(size(im2)));
    figure
    imshow(imfuse(im2, aligned,'diff'))
end

%% Check performance (task 3)
load manual_points_HE_collection_2
load manual_points_TRF_collection_2

xs = manual_points_TRF_collection_2; % TRF
ys = manual_points_HE_collection_2; % HE

for i = 1:length(xs)
    x = xs{i};
    y = ys{i};
    N = length(x);
    [R, t, s] = find_similarity_transform(x,y);
    
    % Calculate eps_manual
    sRx = s*R*x;
    eps_manual = sqrt((1/(N-1))*sum(vecnorm(y - [sRx(1,:) + t(1); sRx(2,:) + t(2)]).^2));

    % Apply T_auto on x and calculate eps_auto
    sRx = ss{i}*Rs{i}*x;
    t = ts{i};
    eps_auto = sqrt((1/(N-1))*sum(vecnorm(y - [sRx(1,:) + t(1); sRx(2,:) + t(2)]).^2));
    
    evaluation{i} = (eps_auto <= eps_manual + 10);
end
performance = sum(cell2mat(evaluation))/length(HE_imgs);

%% Functions to perform rigid registration and RANSAC

function [R, t, s, T] = find_best_similarity_transform(im1, im2)
    % Find SIFT-features
    [TRF_F, TRF_d] = vl_sift(im2single(im1));
    [HE_F, HE_d] = vl_sift(im2single(im2));

    % Extract matching SIFT-features
    matches = vl_ubcmatch(TRF_d, HE_d);
    x = TRF_F(1:2 , matches(1, :));
    y = HE_F(1:2 , matches(2, :));
    
    % Find the best Similarity transformation using RANSAC
    [R, t, s, T] = ransac(x, y, 4);
end

function [R, t, s] = find_similarity_transform(x, y)
    % Algorithm to find the Euclidean transformation from x to y
    avg_x = mean(x,2);
    avg_y = mean(y,2);
    x_tilde = x - avg_x;
    y_tilde = y - avg_y;
    [U, ~, V] = svd(y_tilde*x_tilde');
    R = U*diag([1 det(U*V')])*V';
    s = sum(diag(y_tilde'*R*x_tilde))/sum(vecnorm(x_tilde).^2);
    t = avg_y - s*R*avg_x;
end

function [best_R, best_t, best_s, T] = ransac(x, y, n)
    % Fit Euclidian transform: n = 3
    % Fit Similarity transform: n = 4
    curr_best = 0;
    inlier_dist = 10;
    best_R = [1,0;0,1];
    best_t = [0;0];
    best_s = 1;
    for iter = 1:20000
        idxs = vl_colsubset(1:length(x), n);
        xs = x(:, idxs);
        ys = y(:, idxs);
        [R, t, s] = find_similarity_transform(xs, ys);
        
        sRx = s*R*x;
        new_y = [sRx(1,:) + t(1); sRx(2,:)  + t(2)];
        inlier_idxs = vecnorm(new_y - y) < inlier_dist;
        if sum(inlier_idxs, 'all') > max(0.1*curr_best, n)
            % Model has potential, fit transformation to all inliers
            [R, t, s] = find_similarity_transform(x(:, inlier_idxs), y(:, inlier_idxs));
            sRx = s*R*x;
            new_y = [sRx(1,:) + t(1); sRx(2,:)  + t(2)];
            nb_inliers = sum(vecnorm(new_y - y) < inlier_dist, 'all');
            if nb_inliers > curr_best && s > 0
                curr_best = nb_inliers;
                best_R = R;
                best_t = t;
                best_s = s;
            end
        end
    end
    T = [best_s*best_R, best_t; 0, 0, 1];
end