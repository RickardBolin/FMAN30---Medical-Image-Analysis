%% Load mnist data

%[imgDataTrain, labelsTrain, imgDataTest, labelsTest] = prepareData;

[train_im,train_classes,train_angles]=digitTrain4DArrayData;
[test_im,test_classes,test_angles]=digitTest4DArrayData;

%%


layers = [
    imageInputLayer([28 28 1])
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,64,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(10)
    softmaxLayer
    classificationLayer];


% slightly deeper 

%% Train deep learning network

miniBatchSize = 512;
max_epochs = 300;
learning_rate = 0.0001;
options = trainingOptions( 'sgdm',...
    'MaxEpochs',max_epochs,...
    'MiniBatchSize', miniBatchSize,...
    'InitialLearnRate',learning_rate, ...
    'Plots', 'training-progress');

net = trainNetwork(train_im, train_classes, layers, options);


%% Test the classifier on the test set

[Y_result2,scores2] = classify(net,test_im);
accuracy2 = sum(Y_result2 == test_classes)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);

%% Test the classifier on the training set

[Y_result1,scores1] = classify(net,train_im);
accuracy1 = sum(Y_result1 == train_classes)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);

