%% 1. Load data
load(fullfile('Assignment 1/MBA_ML_2020/databases','hep_proper_mask.mat'));
X1_masks = Y1;
X2_masks = Y2;
load(fullfile('Assignment 1/MBA_ML_2020/databases','hep_proper'));
train_im = X1;
train_classes = Y1;
test_im = X2;
test_classes = Y2;

idx = randperm(size(train_im,4), round(0.05*size(train_im,4)));
validation_im = train_im(:,:,:,idx);
val_masks = X1_masks(:,:,:,idx);
train_im(:,:,:,idx) = [];
X1_masks(:,:,:,idx) = [];
validation_classes = train_classes(idx);
train_classes(idx) = [];

%% Training set class distribution
nb1 = sum(sum(double(Y1) == 1));
nb2 = sum(sum(double(Y1) == 2));
nb3 = sum(sum(double(Y1) == 3));
nb4 = sum(sum(double(Y1) == 4));
nb5 = sum(sum(double(Y1) == 5));
nb6 = sum(sum(double(Y1) == 6));

%% Preprocess data

for i = 1:size(train_im,4)
    train_im(:,:,1,i) = (train_im(:,:,1,i) - ones(64)*min(min(train_im(:,:,1,i))))/max(max(train_im(:,:,1,i)-ones(64)*min(min(train_im(:,:,1,i)))));
    train_im(:,:,2,i) = rangefilt(train_im(:,:,1,i));
    train_im(:,:,2,i) = (train_im(:,:,2,i) - ones(64)*min(min(train_im(:,:,2,i))))/max(max(train_im(:,:,2,i)-ones(64)*min(min(train_im(:,:,2,i)))));
    train_im(:,:,3,i) = entropyfilt(train_im(:,:,1,i));
    train_im(:,:,3,i) = (train_im(:,:,3,i) - ones(64)*min(min(train_im(:,:,3,i))))/max(max(train_im(:,:,3,i)-ones(64)*min(min(train_im(:,:,3,i)))));

end
for i = 1:size(test_im,4)
    test_im(:,:,1,i) = (test_im(:,:,1,i) - ones(64)*min(min(test_im(:,:,1,i))))/max(max(test_im(:,:,1,i)-ones(64)*min(min(test_im(:,:,1,i)))));
    test_im(:,:,2,i) = rangefilt(test_im(:,:,1,i));
    test_im(:,:,2,i) = (test_im(:,:,2,i) - ones(64)*min(min(test_im(:,:,2,i))))/max(max(test_im(:,:,2,i)-ones(64)*min(min(test_im(:,:,2,i)))));
    test_im(:,:,3,i) = entropyfilt(test_im(:,:,1,i));
    test_im(:,:,3,i) = (test_im(:,:,3,i) - ones(64)*min(min(test_im(:,:,3,i))))/max(max(test_im(:,:,3,i)-ones(64)*min(min(test_im(:,:,3,i)))));

end
for i = 1:size(validation_im,4)
    validation_im(:,:,1,i) = (validation_im(:,:,1,i) - ones(64)*min(min(validation_im(:,:,1,i))))/max(max(validation_im(:,:,1,i)-ones(64)*min(min(validation_im(:,:,1,i)))));
    validation_im(:,:,2,i) = rangefilt(validation_im(:,:,1,i));
    validation_im(:,:,2,i) = (validation_im(:,:,2,i) - ones(64)*min(min(validation_im(:,:,2,i))))/max(max(validation_im(:,:,2,i)-ones(64)*min(min(validation_im(:,:,2,i)))));
    validation_im(:,:,3,i) = entropyfilt(validation_im(:,:,1,i));
    validation_im(:,:,3,i) = (validation_im(:,:,3,i) - ones(64)*min(min(validation_im(:,:,3,i))))/max(max(validation_im(:,:,3,i)-ones(64)*min(min(validation_im(:,:,3,i)))));

end
%%
figure
subplot(1, 3, 1);

imshow(train_im(:,:,1,1))
title('Orig. Img', 'FontSize', 15)

subplot(1, 3, 2);
imshow(train_im(:,:,2,1))
title('Rangefilt', 'FontSize', 15)

subplot(1, 3, 3);
imshow(train_im(:,:,3,1))
title('Entropyfilt', 'FontSize', 15)

%%
imageAugmenter = imageDataAugmenter('RandScale', [0.999 1.001]);
imageSize = [64 64 3];

%%
ac = {};
scaling = [12,11,26,21,13,32];
for i = 1:6
    class_idx = find(double(train_classes) == i);
    ac{i} = augmentedImageDatastore(imageSize,repmat(train_im(:,:,:,class_idx),[1,1,1,scaling(i)]),repmat(train_classes(class_idx),scaling(i), 1), 'DataAugmentation',imageAugmenter);
    ac{i} = transform(ac{i}, @(x){x});
end
cmb = combine(ac{1},ac{2},ac{3},ac{4},ac{5},ac{6});
data = cmb.read;
aug_train_data = vertcat(data{1}, data{2}, data{3}, data{4}, data{5}, data{6});
aug_train_cells = aug_train_data{:,1};
aug_classes = aug_train_data{:,2};

aug_train = zeros(64, 64, 2, length(aug_train_cells));
for i = 1:length(aug_train_cells)
    im = aug_train_cells{i,1};
    aug_train(:,:,1,i) = im(:,:,1);
    aug_train(:,:,2,i) = im(:,:,2);
    aug_train(:,:,3,i) = im(:,:,3);
end
%%

imageAugmenter = imageDataAugmenter('RandRotation',[0,360]);
augmented_images = augmentedImageDatastore(imageSize, aug_train, aug_classes,'DataAugmentation',imageAugmenter);
%augmented_images = augmentedImageDatastore(imageSize, train_im, train_classes,'DataAugmentation',imageAugmenter);
%%
layers = [
    imageInputLayer([64 64 3]) % Specify input sizes
    convolution2dLayer(3,16,'Padding','same')
    reluLayer  
    batchNormalizationLayer
    convolution2dLayer(3,16,'Padding','same')
    reluLayer  
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(3,32,'Padding','same')
    reluLayer  
    batchNormalizationLayer
    convolution2dLayer(3,32,'Padding','same')
    reluLayer  
    maxPooling2dLayer(2,'Stride',2)
    fullyConnectedLayer(512) 
    batchNormalizationLayer
    reluLayer  
    fullyConnectedLayer(256) 
    batchNormalizationLayer
    reluLayer 
    fullyConnectedLayer(6)    % Fully connected is a affine map from 28^2 pixels to 10 numbers 
    softmaxLayer               % Convert to 'probabilities'
    classificationLayer];      % Specify output layer
%%
%% Pooling replaced with stride
layers = [
    imageInputLayer([64 64 3]) % Specify input sizes
    convolution2dLayer(3,16, 'Stride', 2)
    reluLayer  
    batchNormalizationLayer
    convolution2dLayer(3,16, 'Stride', 2)
    reluLayer  
    convolution2dLayer(3,32, 'Stride', 2)
    reluLayer  
    batchNormalizationLayer
    convolution2dLayer(3,32, 'Stride', 2)
    reluLayer  
    fullyConnectedLayer(512) 
    batchNormalizationLayer
    reluLayer  
    fullyConnectedLayer(256) 
    batchNormalizationLayer
    reluLayer 
    fullyConnectedLayer(6)    % Fully connected is a affine map from 28^2 pixels to 10 numbers 
    softmaxLayer               % Convert to 'probabilities'
    classificationLayer];      % Specify output layer


%%
analyzeNetwork(net)

%% 3. Train deep learning network
%miniBatchSize = 32; 
augmented_images.MiniBatchSize = 64;
max_epochs = 25;           % Specify how long we should optimize
learning_rate = 4e-4;     % Try different learning rates 
options = trainingOptions('rmsprop',...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.8, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',max_epochs,...
    'InitialLearnRate',learning_rate, ...
    'Plots', 'training-progress', ...
    'ValidationData',{validation_im,validation_classes}, ...
    'ValidationFrequency', 3);
net = trainNetwork(augmented_images , layers, options);
%net = trainNetwork(train_im, train_classes, layers, options);

%% 4. Test the classifier on the test set
[Y_result2,scores2] = classify(net,test_im);
accuracy2 = sum(Y_result2 == test_classes)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);

%% Confusion matrix
cm = confusionchart(test_classes, Y_result2);

%% Test the classifier on the training set
[Y_result1,scores1] = classify(net,train_im);
accuracy1 = sum(Y_result1 == train_classes)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);

