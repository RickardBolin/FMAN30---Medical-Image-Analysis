load('../Assignment 3/data hand in 3 2020/dmsa_images.mat')
load('../Assignment 3/data hand in 3 2020/man_seg.mat')
load('../Assignment 3/data hand in 3 2020/models.mat')

%%
aligned_mean_shape = aligning_algorithm(models);

%% 
function aligned_mean_shape = aligning_algorithm(models)    
    % Initialize "aligned mean shape" as the first shape
    aligned_mean_shape = [real(models(:,1)), imag(models(:,1))]';
    for iter = 1:5
        aligned_shapes{1} = aligned_mean_shape;
        % Align all shapes the the mean shape
        %figure 
        for shape_idx = 2:length(models)
            shape_to_align = [real(models(:, shape_idx)), imag(models(:, shape_idx))]';
            %subplot(1,2,1)
            %hold on
            %plot(shape_to_align(1,:), shape_to_align(2,:))
            %hold off
            [R, t, s] = find_similarity_transform(shape_to_align, aligned_mean_shape);
            sRshape = s*R*shape_to_align;
            aligned_shape = [sRshape(1,:) + t(1); sRshape(2,:)  + t(2)];
            aligned_shapes{shape_idx} = aligned_shape;
            %subplot(1,2,2)
            %hold on
            %plot(aligned_shape(1,:), aligned_shape(2,:))
            %hold off
        end
        
        % Calculate new mean shape
        mean_coords = zeros(2,14);
        for i = 1:length(aligned_shapes)
            mean_coords = mean_coords + aligned_shapes{i};
        end
        mean_shape = mean_coords/length(aligned_shapes);

        % Align new mean shape to the previous mean shape
        [R, t, s] = find_similarity_transform(mean_shape, aligned_mean_shape);
        sRshape = s*R*mean_shape;
        aligned_mean_shape = [sRshape(1,:) + t(1); sRshape(2,:)  + t(2)];
        %mse = norm(aligned_mean_shape - mean_shape)?
    end
end

%%
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
