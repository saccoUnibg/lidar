
%% Setup iniziale
clc
clear
close all 
cd('/Users/cristiansacco/workspaces/lidar')
%% Tools & functions
% lidarViewer
% lidarLabeler
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')

% functions.show        -> mostra la nuvola di punti
% function.showVisible ->
%% 1. Import data or load workspace (same .pcd)

 ptCloud = functions.importPointCloud('/Users/cristiansacco/Tesi/1_files_pcd/test01',110);
 functions.show(ptCloud)
 title("ptCloud")
%% 2. Preprocessing
% - rimozione righe nulle
% - rimozione punti oltre "max_distance" m
% - denoise
% - downsample
% - ground segmentation

ptCloudProcessed = functions.preprocessingFunction(ptCloud,25,0.75,0.75,0.1);

functions.show(ptCloudProcessed)
title("ptCloudProcessed")

% I valori non sono congrui al modello; necessita sicuramente una rotazione
%% 3. Rotazione PointCloud per PointPillars Model
%   xmin    xmax    ymin    ymax    zmin    zmax     
%   0	    69.12	-39.68  39.68	-5	    5

theta = deg2rad(180);  % ad esempio ruota di 90° in senso antiorario
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
     0           0          1];

rotatedXYZ = (R * ptCloudProcessed.Location')';
ptCloudRotated = pointCloud(rotatedXYZ, 'Intensity', ptCloudProcessed.Intensity);

functions.show(ptCloudRotated);
title ("ptCloudRotated")

%% 3. PointPillars model import

pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
disp(detector.PointCloudRange)
colors = {'green','magenta'};

%% model on Point Cloud
results = detect(detector,ptCloudRotated);
[bboxes, scores, labels] = detect(detector, ptCloudRotated);figure;

% functions.showPointCloudWith3DBoxes(ptCloudRotated,bboxes,labels,detector.ClassNames,colors);

functions.show(ptCloudRotated);            % mostra la nuvola
axis on; grid on;
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);                    % vista 3D

% Sovrapponi le bounding box
hold on;
showShape("cuboid", bboxes, ...
          "Label", labels, ...
          "Color", "g", ...
          "LineWidth", 1.5);