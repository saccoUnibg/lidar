%% Example Pointpillars
clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar/example')

%% Download dataset from url and put in 'dataset' folder
openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
% https://ssd.mathworks.com/supportfiles/lidar/data/Pandaset_LidarData.tar.gz

%% Load dataset

outputFolder = fullfile("dataset/","Pandaset_LidarData/");
path = fullfile(outputFolder,'Lidar/');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));

gtPath = fullfile(outputFolder,'Cuboids','PandaSetLidarGroundTruth.mat');
data = load(gtPath,'lidarGtLabels');
Labels = timetable2table(data.lidarGtLabels);
boxLabels = Labels(:,2:3);

% Display full-view point cloud folder
figure
ptCld = preview(lidarData);
ax = pcshow(ptCld.Location);
set(ax,'XLim',[-50 50],'YLim',[-40 40]);
zoom(ax,2.5);
axis on;

grid on
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

%% Preprocess data
% crop pcd 
xMin = 0.0;     % Minimum value along X-axis.
yMin = -39.68;  % Minimum value along Y-axis.
zMin = -5.0;    % Minimum value along Z-axis.
xMax = 69.12;   % Maximum value along X-axis.
yMax = 39.68;   % Maximum value along Y-axis.
zMax = 5.0;     % Maximum value along Z-axis.
xStep = 0.16;   % Resolution along X-axis.
yStep = 0.16;   % Resolution along Y-axis.

pointCloudRange = [xMin xMax yMin yMax zMin zMax];
voxelSize = [xStep yStep];

% function: crop front view + select boxLabels inside ROI (ROI dimensions
% set by params over there)

[croppedPointCloudObj,processedLabels] = exampleFunctions.cropFrontViewFromLidarData(...
    lidarData,boxLabels,pointCloudRange);

pc = croppedPointCloudObj{1,1};
bboxes = [processedLabels.Car{1};processedLabels.Truck{1}];

ax = pcshow(pc);
showShape('cuboid',bboxes,'Parent',ax,'Opacity',0.1,...
        'Color','green','LineWidth',0.5);

axis on;

grid on
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

reset(lidarData);
%% CUSTOM: media punti tra i diversi point cloud
% obtain length of croppedPointCloudObj
pc = 0;
for i= 1 : size(croppedPointCloudObj,1)

    pc = pc + size(croppedPointCloudObj{i,1}.Location,1); % Accumulate point clouds
end
    pc = pc / (i + 1); % Average the accumulated point clouds


%% Create Datastore Objects
rng(1);
shuffledIndices = randperm(size(processedLabels,1));
idx = floor(0.7 * length(shuffledIndices));

trainData = croppedPointCloudObj(shuffledIndices(1:idx),:);
testData = croppedPointCloudObj(shuffledIndices(idx+1:end),:);

trainLabels = processedLabels(shuffledIndices(1:idx),:);
testLabels = processedLabels(shuffledIndices(idx+1:end),:);

writeFiles = true;
dataLocation = fullfile(outputFolder,'InputData');
[trainData,trainLabels] = exampleFunctions.saveptCldToPCD(trainData,trainLabels,...
    dataLocation,writeFiles);

lds = fileDatastore(dataLocation,'ReadFcn',@(x) pcread(x));

bds = boxLabelDatastore(trainLabels);

cds = combine(lds,bds);

%% Perform Data Augmentation

augData = preview(cds);
[ptCld,bboxes,labels] = deal(augData{1},augData{2},augData{3});

% Define the classes for object detection.
classNames = {'Car','Truck'};

% Define colors for each class to plot bounding boxes.
colors = {'green','magenta'};

exampleFunctions.helperShowPointCloudWith3DBoxes(ptCld,bboxes,labels,classNames,colors)

sampleLocation = fullfile(outputFolder,'GTsamples');
[ldsSampled,bdsSampled] = sampleLidarData(cds,classNames,'MinPoints',20,...                  
                            'Verbose',false,'WriteLocation',sampleLocation);
cdsSampled = combine(ldsSampled,bdsSampled);

numObjects = [10 10];
cdsAugmented = transform(cds,@(x)pcBboxOversample(x,cdsSampled,classNames,numObjects));

cdsAugmented = transform(cdsAugmented,@(x)helperAugmentData(x));

augData = preview(cdsAugmented);
[ptCld,bboxes,labels] = deal(augData{1},augData{2},augData{3});
helperShowPointCloudWith3DBoxes(ptCld,bboxes,labels,classNames,colors)

%% Create PointPillars Object Detector

anchorBoxes = exampleFunctions.calculateAnchorsPointPillars(trainLabels);
detector = pointPillarsObjectDetector(pointCloudRange,classNames,anchorBoxes,...
    'VoxelSize',voxelSize); 

%% Specify Training Options

executionEnvironment = "auto";

options = trainingOptions('adam',...
    Plots = "training-progress",...
    MaxEpochs = 60,...
    MiniBatchSize = 3,...
    GradientDecayFactor = 0.9,...
    SquaredGradientDecayFactor = 0.999,...
    LearnRateSchedule = "piecewise",...
    InitialLearnRate = 0.0002,...
    LearnRateDropPeriod = 15,...
    LearnRateDropFactor = 0.8,...
    ExecutionEnvironment= executionEnvironment, ...
    PreprocessingEnvironment = 'parallel',...
    BatchNormalizationStatistics = 'moving',...
    ResetInputNormalization = false,...
    CheckpointFrequency = 10, ...
    CheckpointFrequencyUnit = 'epoch', ...
    CheckpointPath = userpath);

%% Train PointPillars Object Detector

doTraining = false;
if doTraining    
    [detector,info] = trainPointPillarsObjectDetector(cdsAugmented,detector,options);
else
    pretrainedDetector = load('pretrainedPointPillarsDetector.mat','detector');
    detector = pretrainedDetector.detector;
end

%% Generate Detections
ptCloud = testData{20,1};
pcshow(ptCloud,"ColorSource","Intensity")

axis on;

grid on
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

% Run the detector on the test point cloud.
[bboxes,score,labels] = detect(detector,ptCloud);

% Display the predictions on the point cloud.
exampleFunctions.helperShowPointCloudWith3DBoxes(ptCloud,bboxes,labels,classNames,colors)

%% Evaluate Detector Using Test Set

numInputs = 50;

% Generate rotated rectangles from the cuboid labels.
bds = boxLabelDatastore(testLabels(1:numInputs,:));
groundTruthData = transform(bds,@(x)exampleFunctions.createRotRect(x));

detectionResults = detect(detector,testData(1:numInputs,:),...
                         'Threshold',0.25);

% Convert the bounding boxes to rotated rectangles format and calculate
% the evaluation metrics.
for i = 1:height(detectionResults)
    box = detectionResults.Boxes{i};
    detectionResults.Boxes{i} = box(:,[1,2,4,5,9]);
    detectionResults.Labels{i} = detectionResults.Labels{i}';
end

% Evaluate the object detector using average orietation similarity metric
metrics = evaluateObjectDetection(detectionResults,groundTruthData,"AdditionalMetrics","AOS");
[datasetSummary,classSummary] = summarize(metrics)