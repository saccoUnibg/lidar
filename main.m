%% 000. Tools, examples and functions
% -- TOOLS --
% lidarViewer
% lidarLabeler
% deepNetworkDesigner
% lidarLabeler('gTruth.mat')
% -------------------------------------------------------------------------
% -- EXAMPLES --
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
% -------------------------------------------------------------------------
% -- FUNCTIONS --
% functions.show        -> mostra la nuvola di punti
% function.showVisible ->  mostra nuvola di punti che il modello è in grado di analizzare
% -------------------------------------------------------------------------
% PointCloud Range pointpillars model
%   xmin    xmax    || ymin    ymax   || zmin   zmax     
%   0       69.12   || -39.68  39.68  || -5	    5
%% 0. Setup iniziale

clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar')
%% 1. ptCLoud: import, preprocess, rotate

 ptCloud = functions.import_pcd('/Users/cristiansacco/workspaces/lidar/1_files_pcd/test01cropped',20);
 ptCloudProcessed = functions.preprocess_pcd(ptCloud,25,0.75,0.75,0.1);
 angle = 220;
 ptCloudRotated = functions.rotate_pcd(ptCloudProcessed,angle);
 ptCloudRestructured = functions.restructure_pcd(ptCloudRotated);
%% 2. Show ptClouds

 functions.show_pcd(ptCloud,"ptCloud");
 functions.show_pcd(ptCloudProcessed,"ptCloudProcessed");
 functions.show_pcd(ptCloudRotated,"ptCloudRotated");
 functions.show_pcd(ptCloudRestructured,"ptCloudRestructured");
%% 3. apply pointpillars pretrained model

detectorObject = load("pretrainedPointPillarsDetector.mat","detector"); 
detector = detectorObject.detector;

fprintf('Range coordinate del modello pretrained:\n')
disp(detector.PointCloudRange)

results = detect(detector,ptCloudRestructured);
[bboxes, scores, labels] = detect(detector, ptCloudRestructured);

functions.show_pcd(ptCloudRestructured,"Bboxes - Cars");% mostra la nuvola

hold on;
showShape("cuboid", bboxes, ...
          "Label", labels, ...
          "Color", "g", ...
          "LineWidth", 1.5);

%% apply newDetector trained with Cyclist label

newDetectorObject = load("newDetector.mat");
newDetector = newDetectorObject.newDetector;

fprintf('Range coordinate del modello trainato:\n')
disp(newDetector.PointCloudRange)

newResults = detect(newDetector,ptCloudRestructured);
[bboxes1, scores1, labels1] = detect(newDetector, ptCloudRestructured);

functions.show_pcd(ptCloudRestructured,"BBoxes - Cyclists")

hold on;
showShape("cuboid", bboxes1, ...
          "Label", labels1, ...
          "Color", "g", ...
          "LineWidth", 1.5);    
