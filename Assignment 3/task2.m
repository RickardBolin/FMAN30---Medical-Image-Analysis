load('../Assignment 3/data hand in 3 2020/dmsa_images.mat')
load('../Assignment 3/data hand in 3 2020/man_seg.mat')
load('../Assignment 3/data hand in 3 2020/models.mat')

%% Normalize and binarize images
dmsa_images = dmsa_images./max(max(max(dmsa_images)));
im = dmsa_images(:,:,end);
imshow(im);
im = imbinarize(((im(:,:,end))), 0.2);
figure;
imshow(im);

%% Find boundaries and landmarks for last five images
for i = 1:5
    im = imbinarize(((dmsa_images(:,:,20+i))), 0.14);
    [B,L] = bwboundaries(im,'noholes');
    
    boundary = B{2};
    boundary = [boundary(:,2), boundary(:,1)]; %Why do we have to flip x and y...?
    
    boundary = boundary(1:end-1,:);
    [~, min_idx] = min(boundary(:,2));
    % Make lowest point of the boundary first in the list
    boundary = circshift(boundary, length(boundary) - min_idx);
    
    [x, y] = resampleLandmarks(boundary(:,1), boundary(:,2));
    
    shapes{i} = [x'; y'];
    boundaries{i} = boundary';
end


%% Find shape model for last five images
nb_eigvals = 5;
for shape_idx = 1:length(shapes)
    % Initialize X as 14 equidistant landmarks from real boundary
    X = shapes{shape_idx};

    % Find true/original shapes (only used for plot)
    [R, t, s] = find_similarity_transform(X, mean_shape);
    true_shapes{shape_idx} = s*R*X + t;
     
    for iter = 1:50
        % Transform landmarks to mean
        [R, t, s] = find_similarity_transform(X, mean_shape);
        X = s*R*X + t;
        
        % Calculate b
        b{shape_idx} = P(:, 1:nb_eigvals)'*([X(1,:), X(2,:)]' - [mean_shape(1,:), mean_shape(2,:)]');
        % Limit b to +-3sqrt(eigval) for stability
        b{shape_idx} = min(b{shape_idx}, 3*sqrt(evals(1:nb_eigvals)));
        b{shape_idx} = max(b{shape_idx}, -3*sqrt(evals(1:nb_eigvals)));
        
        % Find new landmarks in the shape-space
        X = [mean_shape(1,:), mean_shape(2,:)]' + P(:, 1:nb_eigvals)*b{shape_idx};
        X = [X(1:14), X(15:end)]';
        
        % Transform new landmarks back to image space
        X = R'*(X-t)/s;
        
        % Find closest point on original contour to the new landmarks and
        % use these as new landmarks
        X = orthogonal_proj_on_contour(X, boundaries{shape_idx});
    end
end

%% Plot results
for i = 1:5
    figure
    %imagesc(dmsa_images(:,:,i+20))
    new = [mean_shape(1,:), mean_shape(2,:)]' + P(:, 1:nb_eigvals)*b{i};
    plot(new(1:14), new(15:end))
    hold on
    plot(mean_shape(1,:), mean_shape(2,:))
    plot(true_shapes{i}(1,:), true_shapes{i}(2,:))
    hold off
    legend('Fitted' ,'Mean' , 'True')
end

%%

function X = orthogonal_proj_on_contour(X, boundary)
    for i = 1:length(X)
        % Find closest point on boundary to X(:,i)
        dists = vecnorm(boundary - repmat(X(:,i), 1, length(boundary)), 2, 1);
        [~, min_idx] = min(dists);
        % Replace X(:,i) with closest point on boundary
        X(:,i) = boundary(:,min_idx);
    end
end


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


function [R, t, s] = find_similarity_transform(x, y)
    % Algorithm to find the Similarity transformation from x to y
    avg_x = mean(x,2);
    avg_y = mean(y,2);
    x_tilde = x - avg_x;
    y_tilde = y - avg_y;
    [U, ~, V] = svd(y_tilde*x_tilde');
    R = U*diag([1 det(U*V')])*V';
    s = sum(diag(y_tilde'*R*x_tilde))/sum(vecnorm(x_tilde).^2);
    t = avg_y - s*R*avg_x;
end
