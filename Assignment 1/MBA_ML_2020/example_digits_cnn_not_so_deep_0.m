%% 1. Load mnist data
[train_im,train_classes,train_angles]=digitTrain4DArrayData;
[test_im,test_classes,test_angles]=digitTest4DArrayData;
%% 2. Select deep learning architecture
layers = [
    imageInputLayer([28 28 1]) % Specify input sizes
    fullyConnectedLayer(10)    % Fully connected is a affine map from 28^2 pixels to 10 numbers
    softmaxLayer               % Convert to 'probabilities'
    classificationLayer];      % Specify output layer
%% 3. Train deep learning network
miniBatchSize = 512;       
max_epochs = 30;           % Specify how long we should optimize
learning_rate = 1;     % Try different learning rates 
options = trainingOptions( 'sgdm',...
    'MaxEpochs',max_epochs,...
    'InitialLearnRate',learning_rate, ...
    'Plots', 'training-progress');
net = trainNetwork(train_im, train_classes, layers, options);
%% 4. Test the classifier on the test set
[Y_result2,scores2] = classify(net,test_im);
accuracy2 = sum(Y_result2 == test_classes)/numel(Y_result2);
disp(['The accuracy on the test set: ' num2str(accuracy2)]);
%% Test the classifier on the training set
[Y_result1,scores1] = classify(net,train_im);
accuracy1 = sum(Y_result1 == train_classes)/numel(Y_result1);
disp(['The accuracy on the training set: ' num2str(accuracy1)]);

