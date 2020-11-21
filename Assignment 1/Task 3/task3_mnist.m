%% 1. Load mnist data
[train_im,train_classes,train_angles]=digitTrain4DArrayData;
[test_im,test_classes,test_angles]=digitTest4DArrayData;

%% 2. Select deep learning architecture
layers = [
    imageInputLayer([28 28 1]) % Specify input sizes
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
    fullyConnectedLayer(10)    % Fully connected is a affine map from 28^2 pixels to 10 numbers 
    softmaxLayer               % Convert to 'probabilities'
    classificationLayer];      % Specify output layer

%%
imageAugmenter = imageDataAugmenter( ...
    'RandScale', [0.9 1.1], ...
    'RandRotation',[-8,8], ...
    'RandXTranslation',[-3 3], ...
    'RandYTranslation',[-3 3]);
    
imageSize = [28 28 1];
augmented_images = augmentedImageDatastore(imageSize,train_im,train_classes,'DataAugmentation',imageAugmenter);


%% 3. Train deep learning network
miniBatchSize = 512;       
max_epochs = 10;           % Specify how long we should optimize
learning_rate = 1e-3;     % Try different learning rates 
options = trainingOptions('adam',...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.9, ...
    'LearnRateDropPeriod',1, ...
    'MaxEpochs',max_epochs,...
    'InitialLearnRate',learning_rate, ...
    'Plots', 'training-progress');
net = trainNetwork(augmented_images, layers, options);
%% 4. Test the classifier on the test set
[Y_result2,scores2] = classify(net,test_im);
accuracy2 = sum(Y_result2 == test_classes)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);
%% Test the classifier on the training set
[Y_result1,scores1] = classify(net,train_im);
accuracy1 = sum(Y_result1 == train_classes)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);

