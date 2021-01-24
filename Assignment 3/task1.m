load('../Assignment 3/data hand in 3 2020/dmsa_images.mat')
load('../Assignment 3/data hand in 3 2020/man_seg.mat')
load('../Assignment 3/data hand in 3 2020/models.mat')

%% Align all shapes to mean shape and find eigenvectors
[mean_shape, Rs, ts, ss] = aligning_algorithm(models);

model_post_transform = zeros(size(models));
for i=1:length(ss)
    model_post_transform(:, i) = apply_transformation(Rs{i}, ts{i}, ss{i}, models(:, i));
end

figure
plot(mean_shape(1,:), mean_shape(2,:),'r-.', 'LineWidth', 3)
hold on
for i=1:length(ss)
    complex_coords= model_post_transform(:, i);
    x = real(complex_coords);
    y = imag(complex_coords);
    p = plot(x,y);
    p.Color(4) = 0.2;
end
legend({'Mean shape'}, 'FontSize', 16)
title('Aligned Shapes', 'FontSize', 18)

C = covariance(mean_shape, model_post_transform);
[evecs, evals] = eig(C);

% Make decscending order
evals = flip(diag(evals),1);

P = flip(evecs, 2);

% Plot eigenvalues
figure
scatter(1:28, evals, 70, 'filled')
title('Eigenvalues in descending order', 'FontSize', 18)

% Plot cumulative energy for eigenvalues
figure
plot(0:28, [0;cumsum(evals)/sum(evals)], 'LineWidth', 3)
hold on
plot(0:28, 0.7*ones(1,29), 'm-.')
plot(0:28, 0.8*ones(1,29), 'c-.')
plot(0:28, 0.9*ones(1,29), 'g-.')
plot(0:28, 0.95*ones(1,29), 'r-.')
legend({'Cumulative Energy', '70%', '80%', '90%', '95%'}, 'FontSize', 16)
s1 = scatter(0:28, [0; cumsum(evals)/sum(evals)], 50, 'r', 'filled');
set(get(get(s1(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
title('Cumulative Energy', 'FontSize', 18)

% Plot mode with different b's
for idx = 1:12
    visualise(mean_shape, idx, P, evals)
end

%% Functions
function [] = visualise(mean_shape, mode_idx, P, evals)
    eval = evals(mode_idx);
    mid = length(P(:, 1)) / 2;
    evec = [P(1:mid, mode_idx), P(mid+1:end, mode_idx)]';
        
    p1 = mean_shape - 2 * sqrt(eval) * evec;
    p2 = mean_shape - sqrt(eval) * evec;
    p3 = mean_shape;
    p4 = mean_shape + sqrt(eval) * evec;
    p5 = mean_shape + 2 * sqrt(eval) * evec;
    
    
    figure
    plot(p1(1, :), p1(2, :), 'b')
    hold on
    plot(p2(1, :), p2(2, :), 'g')
    plot(p3(1, :), p3(2, :), 'r-.', 'LineWidth', 3)
    plot(p4(1, :), p4(2, :), 'm')
    plot(p5(1, :), p5(2, :), 'k')
    
    hold off
    legend({'Mean - 2*sqrt(lambda)', 'Mean - sqrt(lambda)', 'Mean', 'Mean + sqrt(lambda)', 'Mean + 2*sqrt(lambda)'}, 'FontSize', 14)
    title(['Principal mode ' num2str(mode_idx)], 'FontSize', 18)
end

function S = covariance(mean_shape, shapes)

shapes_xs = real(shapes);
shapes_ys = imag(shapes);

[N, M] = size(shapes);

S = zeros(2 * N, 2 * N);

X_bar = [mean_shape(1, :)'; mean_shape(2, :)'];

for i=1:M
    X = [shapes_xs(:, i); shapes_ys(:, i)];
    dX = X - X_bar;
    S = S + dX * dX'; 
end

S = S / M;

end

function [aligned_mean_shape, Rs, ts, ss] = aligning_algorithm(models)    
    % Initialize "aligned mean shape" as the first shape
    aligned_mean_shape = [real(models(:,1)), imag(models(:,1))]';
    for iter = 1:5
        aligned_shapes{1} = aligned_mean_shape;
        % Align all shapes the the mean shape
        for i = 1:length(models)
            shape_to_align = [real(models(:, i)), imag(models(:, i))]';
            [Rs{i}, ts{i}, ss{i}] = find_similarity_transform(shape_to_align, aligned_mean_shape);
            aligned_shapes{i} = ss{i}*Rs{i}*shape_to_align  + ts{i};
        end
        
        % Calculate new mean shape
        mean_coords = zeros(2,14);
        for i = 1:length(aligned_shapes)
            mean_coords = mean_coords + aligned_shapes{i};
        end
        mean_shape = mean_coords/length(aligned_shapes);

        % Align new mean shape to the previous mean shape
        [R, t, s] = find_similarity_transform(mean_shape, aligned_mean_shape);
        aligned_mean_shape = s*R*mean_shape  + t;
    end
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

function new_coords = apply_transformation(R, t, s, coords)
    coords = [real(coords), imag(coords)]';
    new_coords = s*R*coords + t;
    new_coords = complex(new_coords(1, :), new_coords(2, :));
end