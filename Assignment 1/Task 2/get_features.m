function [F, STR] = get_features(image, mask)

F(1) = max(max(bwlabel(image > 0.8*max(max(image)))));
STR{1} = 'Number of regions';

F(2) = calc_roundness(mask);
STR{2} = 'Roundness';

F(3) = skewness(image(find(mask)));
STR{3} = 'Skewness';

F(4) = kurtosis(image(find(mask)));
STR{4} = 'Kurtosis';

%F(7) = sum(image(find(mask)))/64^2;
%STR{7} = '% filled';


% Need to name all features.
assert(numel(F) == numel(STR));

end
%% 

function roundness = calc_roundness(mask)
    [B,~] = bwboundaries(mask,'noholes');
    % Estimate object's perimeter
    delta_sq = diff(B{1}).^2;   
    perimeter = sum(sqrt(sum(delta_sq,2)));
    % Estimate roundness
    area = sum(sum(mask));
    roundness = 4*pi*area/perimeter^2;
end
4*pi*r*r*pi
2*r*pi*2*r*pi

