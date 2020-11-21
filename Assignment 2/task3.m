load manual_points_HE_collection_1
load manual_points_p63AMACR_collection_1

%% Check performance (task 3)
xs = manual_points_HE_collection_1;
ys = manual_points_p63AMACR_collection_1;


%%
for i = 1:length(xs)
    x = xs{i};
    y = ys{i};
    N = length(x);
    [R, t] = rigid_registration(x,y);
    
    % Calculate eps_manual
    for j = 1:length(x)
        eps{j} = y(:,j) - (R*x(:,j) - t);
    end
    sum_eps = 0;
    for k = 1:length(eps)
        sum_eps = norm(eps{k})^2;
    end
    eps_manual = sqrt((1/(N-1))*sum_eps);
    
    % Apply T_auto on x and calculate eps_auto
    for j = 1:length(x)
        eps{j} = y(:,j) - (Rs{j}*x(:,j) - ts{j});
    end
    sum_eps = 0;
    for k = 1:length(eps)
        sum_eps = norm(eps{k})^2;
    end
    eps_auto = sqrt((1/(N-1))*sum_eps);
    
    evaluation{i} = (eps_auto <= eps_manual + 10);
end

%% Check performance of task 2
load manual_points_HE_collection_2
load manual_points_TRF_collection_2

% LADDA NYA Ts, ss och ts!!

%%

xs = manual_points_TRF_collection_2; % TRF
ys = manual_points_HE_collection_2; % HE

xs{10} = [238, 172; 306, 310; 203, 349; 143, 262; 237, 228]';

for i = 1:length(xs)
    x = xs{i};
    y = ys{i};
    N = length(x);
    [R, t, s] = find_similarity_transform(x,y);
    
    % Calculate eps_manual
    for j = 1:length(x)
        eps{j} = y(:,j) - (s*R*x(:,j) - t);
    end
    sum_eps = 0;
    for k = 1:length(eps)
        sum_eps = norm(eps{k})^2;
    end
    eps_manual = sqrt((1/(N-1))*sum_eps);
    
    % Apply T_auto on x and calculate eps_auto
    for j = 1:length(x)
        eps{j} = y(:,j) - (Rs{j}*x(:,j) - ts{j});
    end
    sum_eps = 0;
    for k = 1:length(eps)
        sum_eps = norm(eps{k})^2;
    end
    eps_auto = sqrt((1/(N-1))*sum_eps);
    
    evaluation{i} = (eps_auto <= eps_manual + 10);
end

%%

function [R, t, s] = find_similarity_transform(x, y)
    % Algorithm to find the Euclidean transformation from x to y
    avg_x = mean(x,2);
    avg_y = mean(y,2);
    x_tilde = x - avg_x;
    y_tilde = y - avg_y;
    [U, ~, V] = svd(y_tilde*x_tilde');
    R = U*diag([1 det(U*V')])*V';
    
    s1 = 0;
    s2 = 0;
    for i = 1:length(x)
        s1 = s1 + y_tilde(:,i)'*R*x_tilde(:,i);
        s2 = s2 + norm(x_tilde(:,i))^2;
    end
    s = s1/s2;
    
    t = avg_y - s*R*avg_x;
end


function [R, t] = rigid_registration(x, y)
    % Algorithm to find the Euclidean transformation from x to y
    avg_x = mean(x,2);
    avg_y = mean(y,2);

    [U, ~, V] = svd((x - avg_x)*(y - avg_y)');
    R = U*diag([1 det(U*V')])*V';
    t = avg_y - R*avg_x;
end