%% Generate data
mu = [0.0, 1.0];
%sigma = 0.4;
sigma = 4;

train = normrnd(mu.*ones(10,2), sigma.*ones(10,2), 10, 2);
test = normrnd(mu.*ones(1000,2), sigma.*ones(1000,2), 1000, 2);

%% Get estimated distributions
x = linspace(-30, 30, 1000)';
%h = 0.02; 
h = 1;

my_parzen = @(x,T,h) sum(normpdf((x-T)/h))/(length(T)*h);
px_given_1 = arrayfun(@(x) my_parzen(x,train(:,1),h), x);
px_given_2 = arrayfun(@(x) my_parzen(x,train(:,2),h), x);
px = 0.5*(px_given_1 + px_given_2);
p1_given_x = 0.5*(px_given_1./px);
p2_given_x = 0.5*(px_given_2./px);

%% Get true distributions
px_given_1_true = normpdf(x, mu(1), sigma);
px_given_2_true = normpdf(x, mu(2), sigma);
px_true = 0.5*(px_given_1_true + px_given_2_true);
p1_given_x_true = 0.5*(px_given_1_true./px_true);
p2_given_x_true = 0.5*(px_given_2_true./px_true);

%% Compare
plot_two_w_combined(x, p1_given_x, ' Estimated P(y=1|x)', p1_given_x_true, 'Comparison', 'True P(y=1|x)')
plot_two_w_combined(x, p2_given_x, ' Estimated P(y=2|x)', p2_given_x_true, 'Comparison', 'True P(y=2|x)')
plot_two_w_combined(x, px_given_1, ' Estimated P(x|y=1)', px_given_1_true, 'Comparison', 'True P(x|y=1)')
plot_two_w_combined(x, px_given_2, ' Estimated P(x|y=2)', px_given_2_true, 'Comparison', 'True P(x|y=2)')
plot_two_w_combined(x, px, ' Estimated P(x)', px_true, 'Comparison', 'True P(x)')

%% Calculate error rate for test data
% Error rate for test data from class 1:
ground_truth = [zeros(1000,1); ones(1000,1)];
prob_y1 = arrayfun(@(x) my_parzen(x,train(:,1),h), test(:));
prob_y2 = arrayfun(@(x) my_parzen(x,train(:,2),h), test(:));
error_rate = sum(prob_y1 > prob_y2 == ground_truth) / length(test(:));

% Error rate when using theoretically optimal threshold (intersection at 0.5)
error_rate_1_opt = sum([test(:,1) < 0.5; test(:,2) > 0.5] ~= 1) / length(test(:));

%% K-fold crossvalidation to estimate kernel width
A = repmat(train(:,1),[2,1]);
N = length(train)-1;
hs = linspace(0.1, 3, 300);
est = zeros(length(hs),1);
vals = zeros(length(train),1);
for j = 1:length(hs)
    for i = 2:N+2
        vals(i-1) = my_parzen(A(i-1), A(i:i+N-1), hs(j));
    end
    est(j) = sum(log(vals));
end
[~, max_idx] = max(est);
est_kernel_width = hs(max_idx);
%plot(hs, est)

%% Function to plot the distributions

function [] = plot_two_w_combined(x,d1,t1,d2,t2,t3)
    figure
    subplot(1, 3, 1);
    plot(x, d1, 'r');
    axis square
    title(t1, 'FontSize', 15)

    subplot(1, 3, 2);
    hold on
    plot(x, d1, 'r');
    plot(x, d2, 'b');
    axis square
    title(t2, 'FontSize', 15)
    hold off

    subplot(1, 3, 3);
    plot(x, d2, 'b');
    axis square
    title(t3, 'FontSize', 15)
end
