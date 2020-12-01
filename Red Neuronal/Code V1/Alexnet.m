clc; close all; clear all;
%% Load Deep Network Designer Parameters
%params = load("C:\Users\blaib\OneDrive\Documentos\TERCERO\Primer Cuatri\ELECTRONICA\Proyecto\NN\Classifier\params_2020_11_21__13_00_12.mat");

load('C:\Users\blaib\OneDrive\Documentos\TERCERO\Primer Cuatri\ELECTRONICA\Proyecto\NN\Classifier\Datasets\Neural Networks CheckPoints\net_checkpoint__372__2020_11_23__22_15_32.mat','net')

% net = alexnet;
% layers = net.Layers;

%% Access Layers
% layers = [
%     imageInputLayer([227 227 3],"Name","data")
%     convolution2dLayer([11 11],96,"Name","conv1","BiasLearnRateFactor",2,"Stride",[4 4],"Bias",params.conv1.Bias,"Weights",params.conv1.Weights)
%     reluLayer("Name","relu1")
%     crossChannelNormalizationLayer(5,"Name","norm1","K",1)
%     maxPooling2dLayer([3 3],"Name","pool1","Stride",[2 2])
%     groupedConvolution2dLayer([5 5],128,2,"Name","conv2","BiasLearnRateFactor",2,"Padding",[2 2 2 2],"Bias",params.conv2.Bias,"Weights",params.conv2.Weights)
%     reluLayer("Name","relu2")
%     crossChannelNormalizationLayer(5,"Name","norm2","K",1)
%     maxPooling2dLayer([3 3],"Name","pool2","Stride",[2 2])
%     convolution2dLayer([3 3],384,"Name","conv3","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"Bias",params.conv3.Bias,"Weights",params.conv3.Weights)
%     reluLayer("Name","relu3")
%     groupedConvolution2dLayer([3 3],192,2,"Name","conv4","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"Bias",params.conv4.Bias,"Weights",params.conv4.Weights)
%     reluLayer("Name","relu4")
%     groupedConvolution2dLayer([3 3],128,2,"Name","conv5","BiasLearnRateFactor",2,"Padding",[1 1 1 1],"Bias",params.conv5.Bias,"Weights",params.conv5.Weights)
%     reluLayer("Name","relu5")
%     maxPooling2dLayer([3 3],"Name","pool5","Stride",[2 2])
%     fullyConnectedLayer(4096,"Name","fc6","BiasLearnRateFactor",2,"Bias",params.fc6.Bias,"Weights",params.fc6.Weights)
%     reluLayer("Name","relu6")
%     dropoutLayer(0.5,"Name","drop6")
%     fullyConnectedLayer(4096,"Name","fc7","BiasLearnRateFactor",2,"Bias",params.fc7.Bias,"Weights",params.fc7.Weights)
%     reluLayer("Name","relu7")
%     dropoutLayer(0.5,"Name","drop7")
%     fullyConnectedLayer(1000,"Name","fc8","BiasLearnRateFactor",2,"Bias",params.fc8.Bias,"Weights",params.fc8.Weights)
%     softmaxLayer("Name","prob")
%     classificationLayer("Name","output","Classes",params.output.Classes)];

%% Set up Training Data
rootFolder_train = 'C:\Users\blaib\OneDrive\Documentos\TERCERO\Primer Cuatri\ELECTRONICA\Proyecto\NN\Classifier\hand_gesture_train';
categories_train = {'1_finger','2_finger','3_finger','4_finger'};
dat_train = shuffle(imageDatastore(fullfile(rootFolder_train, categories_train), 'LabelSource','foldernames'));

%% Set up Validation Data
rootFolder_val = 'C:\Users\blaib\OneDrive\Documentos\TERCERO\Primer Cuatri\ELECTRONICA\Proyecto\NN\Classifier\hand_gesture_test';
categories_val = {'1_finger','2_finger','3_finger','4_finger'};
dat_val = shuffle(imageDatastore(fullfile(rootFolder_val, categories_val), 'LabelSource','foldernames'));

%% Change Layers
% layers(23) = fullyConnectedLayer(4);
% layers(25) = classificationLayer();

%% Training Options
options = trainingOptions('sgdm',...
        'InitialLearnRate',0.001, ...
        'Verbose',true,...
        'VerboseFrequency',3, ...
        'MiniBatchSize',64,...
        'Plots','training-progress',...
        'MaxEpochs',1,...
        'ExecutionEnvironment','auto',...
        'ValidationData',dat_val,...
        'ValidationFrequency',10,...
        'CheckpointPath','C:\Users\blaib\OneDrive\Documentos\TERCERO\Primer Cuatri\ELECTRONICA\Proyecto\NN\Classifier\Datasets\Neural Networks CheckPoints');
    
%% Train Data
alexnet = trainNetwork(dat_train, net.Layers, options);
save alexnet;