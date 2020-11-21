%% Install VLFeat
% Download newest bin from https://www.vlfeat.org/download/
% Unpack and save to some path
% Execute command: "run vlfeat-0.9.21/toolbox/vl_setup" 

%% Load images and scale them down by 50%
HE_imgs = dir('./Assignment-2-Data/Collection 1/HE/*.bmp');   
p63AMACR_imgs = dir('./Assignment-2-Data/Collection 1/p63AMACR/*.bmp');   

for i=1:length(HE_imgs)
   HE_images{i} = imresize(imread(fullfile(HE_imgs(i).folder, HE_imgs(i).name)), 0.5);
   p63AMACR_images{i} = imresize(imread(fullfile(p63AMACR_imgs(i).folder, p63AMACR_imgs(i).name)), 0.5);
end

%% Find best rotations and translations for all image pairs (from im1 to im2)
for i = 1:length(HE_images)
    im1 = rgb2gray(HE_images{i});
    im2 = rgb2gray(p63AMACR_images{i});
    [Rs{i}, ts{i}, Ts{i}] = find_best_rigid_registration(im1, im2);
end

%% Save the rotation and magnitude of transition for each image
for i = 1:length(Rs)
    rotation_angles{i} = acosd(Rs{i}(1,1));
    translation_magnitudes{i} = norm(ts{i});
end

%% Plot the unaligned and aligned images
for i = 1:length(Rs)
    figure
    im1 = rgb2gray(HE_images{i});
    im2 = rgb2gray(p63AMACR_images{i});
    subplot(1,2,1)
    imshowpair(im1, im2, 'blend')
    tform = affine2d(Ts{i}');
    aligned = imwarp(im1, tform, 'OutputView', imref2d(size(im2)));
    subplot(1,2,2)
    imshow(imfuse(im2, aligned,'blend'))
end

%% Check performance (task 3)
load manual_points_HE_collection_1
load manual_points_p63AMACR_collection_1

xs = manual_points_HE_collection_1;
ys = manual_points_p63AMACR_collection_1;


for i = 1:length(xs)
    x = xs{i};
    y = ys{i};
    N = length(x);
    [R, t] = rigid_registration(x,y);
    figure
    tform = projective2d([R, t; 0,0,1]');
    aligned = imwarp(HE_images{i}, tform, 'OutputView', imref2d(size(p63AMACR_images{i})));
    imshow(imfuse(p63AMACR_images{i}, aligned,'diff'))   
    % Calculate eps_manual
    Rx = R*x;
    eps_manual = sqrt((1/(N-1))*sum(vecnorm(y - [Rx(1,:) + t(1); Rx(2,:)  + t(2)]).^2));

    % Apply T_auto on x and calculate eps_auto
    Rx = Rs{i}*x;
    t = ts{i};
    eps_auto = sqrt((1/(N-1))*sum(vecnorm(y - [Rx(1,:) + t(1); Rx(2,:)  + t(2)]).^2));
    
    % Check if the transformation is okay or not
    evaluation{i} = (eps_auto <= eps_manual + 10);
end
performance = sum(cell2mat(evaluation))/length(HE_imgs)

%% Functions to perform rigid registration and RANSAC

function [R, t, T] = find_best_rigid_registration(im1, im2)
    % Find SIFT-features
    [HE_F, HE_d] = vl_sift(im2single(im1));
    [p63AMACR_F, p63AMACR_d] =  vl_sift(im2single(im2));
    % Extract matching SIFT-features
    matches = vl_ubcmatch(HE_d, p63AMACR_d);
    x = HE_F(1:2 , matches(1, :));
    y = p63AMACR_F(1:2 , matches(2, :));
    % Find the best euclidean transformation using RANSAC
    [R, t, T] = ransac(x, y, 3);
end

function [R, t] = rigid_registration(x, y)
    % Algorithm to find the Euclidean transformation from x to y
    avg_x = mean(x,2);
    avg_y = mean(y,2);

    [U, ~, V] = svd((x - avg_x)*(y - avg_y)');
    R = U*diag([1 det(U*V')])*V';
    t = avg_y - R*avg_x;
end

function [best_R, best_t, T] = ransac(x, y, n)
    % Fit Euclidian transform: n = 3
    % Fit Similarity transform: n = 4
    curr_best = 0;
    best_R = [1,0;0,1];
    best_t = [0;0];
    inlier_dist = 5; % Max distance between y_i and the projection of x_i
    for iter = 1:20000
        idxs = vl_colsubset(1:length(x), n);
        xs = x(:, idxs);
        ys = y(:, idxs);
        [R, t] = rigid_registration(xs, ys);

        Rx = R*x;
        new_y = [Rx(1,:) + t(1); Rx(2,:)  + t(2)];
        inlier_idxs = vecnorm(new_y - y) < inlier_dist;
        if sum(inlier_idxs, 'all') >= max(0.1*curr_best, n)
            % Model has potential, fit transformation to all inliers
            [R, t] = rigid_registration(x(:, inlier_idxs), y(:, inlier_idxs));
            Rx = R*x;
            new_y = [Rx(1,:) + t(1); Rx(2,:)  + t(2)];
            nb_inliers = sum(vecnorm(new_y - y) < inlier_dist, 'all');
            if nb_inliers > curr_best
                curr_best = nb_inliers;
                best_R = R;
                best_t = t;
            end
        end
    end
    T = [best_R, best_t; 0, 0, 1];
end