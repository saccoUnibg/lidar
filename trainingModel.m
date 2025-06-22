%% Setup iniziale
clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar')

%% import pcd
lidarLabeler

load("Untitled.mat")
%% PointPillars model import
pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
fprintf('Range coordinate del modello:\n')
disp(detector.PointCloudRange)

%% Transfer learning
%Le --anchor boxes-- non indicano dove si trovano gli oggetti nel point cloud,
% ma rappresentano le dimensioni tipiche (forma e scala) degli oggetti che 
% vuoi rilevare, usate come prototipi durante la fase di training.

% POINT CLOUD RANGE
xMin = 0.0;     % Minimum value along X-axis.
yMin = -39.68;  % Minimum value along Y-axis.
zMin = -5.0;    % Minimum value along Z-axis.
xMax = 69.12;   % Maximum value along X-axis.
yMax = 39.68;   % Maximum value along Y-axis.
zMax = 5.0;     % Maximum value along Z-axis.
xStep = 0.16;   % Resolution along X-axis.
yStep = 0.16;   % Resolution along Y-axis.
pointCloudRange = [xMin xMax yMin yMax zMin zMax];

% anchorBoxes -> [l, w, h, c, a]

anchorBoxes = {
    [1.8, 0.6, 1.7, 0.85, 0;   % frontale
    1.8, 0.6, 1.7, 0.85, pi/2];   % laterale
};
classNames = {'Cyclist'};

cyclistDetector = pointPillarsObjectDetector(detector.Network,pointCloudRange,classNames,anchorBoxes);

%% set training data
load("gTruth.mat")
[pcds,bxds] = lidarObjectDetectorTrainingData(gTruth);
trainingData = combine(pcds,bxds);

pcdFolder = 'path_to_your_pcd_files'; % Specify the folder containing PCD files
ds = datastore(fullfile(pcdFolder, '*.pcd'), 'Type', 'file');


%% training

options = trainingOptions("adam","ExecutionEnvironment","auto","ResetInputNormalization",false, ...
    "BatchNormalizationStatistics","moving","OutputNetwork","last-iteration");
[newDetector,info] = trainPointPillarsObjectDetector(trainingData,cyclistDetector,options);