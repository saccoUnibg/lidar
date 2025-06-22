
%% 0. Setup iniziale
clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar')
%% Tools, examples and functions
% -- TOOLS --
% lidarViewer
% lidarLabeler
% deepNetworkDesigner
% lidarLabeler('gTruth.mat')
% ------------
% -- EXAMPLES --
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
% ------------
% -- FUNCTIONS --
% functions.show        -> mostra la nuvola di punti
% function.showVisible ->  mostra nuvola di punti che il modello è in grado di analizzare
%% 1. ptCloud: Import data or load workspace (same .pcd)
%  2. ptCloudProcessed: import and Preprocessing

% - rimozione righe nulle
% - rimozione punti oltre "max_distance"
% - denoise
% - downsample
% - ground segmentation
 ptCloud = functions.importPointCloud('/Users/cristiansacco/Tesi/1_files_pcd/test07cropped',085);
 ptCloudProcessed = functions.preprocessingFunction(ptCloud,25,0.75,0.75,0.1);

%% 3. ptCloudRotated: Rotazione PointCloud per PointPillars Model
%   xmin    xmax    ||ymin    ymax   ||zmin   zmax     
%   0       69.12   ||-39.68  39.68  ||-5	    5

theta = deg2rad(180);  % ad esempio ruota di 90° in senso antiorario
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
     0           0          1];

rotatedXYZ = (R * ptCloudProcessed.Location')';
ptCloudRotated = pointCloud(rotatedXYZ, 'Intensity', ptCloudProcessed.Intensity);
%% Sho ptClouds

 functions.show(ptCloud,"ptCloud");

 functions.show(ptCloudProcessed,"ptCloudProcessed");

 functions.show(ptCloudRotated,"ptCloudRotated");
%% 4. PointPillars model import

pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
fprintf('Range coordinate del modello:\n')
disp(detector.PointCloudRange)

%% 5. transfer learning
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

% anchorBoxes = {
%     [1.8, 0.6, 1.7, 0.85, 0;   % frontale
%     0.6, 1.8, 1.7, 0.85, 0];   % laterale
% };

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

options = trainingOptions("adam","ExecutionEnvironment","auto","ResetInputNormalization",false,"BatchNormalizationStatistics","moving","OutputNetwork","last-iteration");
[newDetector,info] = trainPointPillarsObjectDetector(trainingData,cyclistDetector,options)

%% 6. result: apply model on Point Cloud

results = detect(newDetector,ptCloudProcessed);
[bboxes, scores, labels] = detect(newDetector, ptCloudProcessed);

functions.show(ptCloudProcessed,"bounding boxes - Cyclists");% mostra la nuvola
axis on; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);    % vista 3D

% Sovrapponi le bounding box
hold on;
showShape("cuboid", bboxes, ...
          "Label", labels, ...
          "Color", "g", ...
          "LineWidth", 1.5);

%% ptCloudAdapted: pcorganize with pandar64 lidar sensor (NOT USEFUL)
 % lidarParams = struct;
% lidarParams.VerticalResolution = 64;
% lidarParams.VerticalFieldOfView = [-25 15];     % tipico per Pandar64
% lidarParams.HorizontalResolution = 0.2;         % corrisponde a 1800 steps per 360°
% lidarParams.SensorType = 'Pandar64';            % opzionale
% 
% % Organizza il tuo point cloud in "stile Pandar64"
% organizedPC = pcorganize(ptCloud, lidarParams);
% sensorName = 'Pandar64';
% verticalResolution = 64;
% verticalFoV=[15 -25];
% horizontalResolution = 1800;
% params = lidarParameters(verticalResolution,verticalFoV,horizontalResolution);
% pcCloudAdapted = pcorganize(ptCloudRotated,params);
