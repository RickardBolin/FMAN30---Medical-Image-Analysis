%function [F, STR] = get_features(image, mask)
%keyboard;
%F(1) = mean(image(find(mask)));
%STR{1} = 'mean intensity';

%F(2) = std(image(find(mask)));
%STR{2} = 'std dev';

% F(3) = median(image(find(mask)));
% STR{3} = 'median intensity';

% Need to name all features.
%assert(numel(F) == numel(STR));