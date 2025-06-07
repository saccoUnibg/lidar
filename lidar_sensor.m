
%% setup
clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar')
%% Tools
% lidarViewer
% lidarLabeler
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
%% 1. import data or load workspace (same .pcd)

ptCloud = functions.importPointCloud('/Users/cristiansacco/Tesi/1_files_pcd/test01',110);
% ptCloud = functions.importPointCloud('/Users/cristiansacco/Tesi/1_files_pcd/PointCloudTest',40);
% ptCloud = pcread("ptCloudRot.pcd")
% pcshow(ptCloud,"ColorSource","Intensity")
%% 2. preprocessing
% values = models.PreprocessingValues(30,0.75,0.75,0.1);
values = models.PreprocessingModel();
values.max_distance = 25;
values.denoise_threshold = 0.75;
values.downsample_threshold = 0.75;
values.elevation_threshold = 0.1;

ptCloudProcessed = functions.preprocessingFunction(ptCloud,values);

%% 

theta = deg2rad(180);  % ad esempio ruota di 90° in senso antiorario
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
     0           0          1];

rotatedXYZ = (R * ptCloudProcessed.Location')';
ptCloudRot = pointCloud(rotatedXYZ, 'Intensity', ptCloudProcessed.Intensity);

pcshow(ptCloudRot,"ColorSource","Intensity");

ptCloudVisible = functions.ptCloudVisible(ptCloudRot);
pcshow(ptCloudVisible,"ColorSource","Intensity")

%% 3. PointPillars model

pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
colors = {'green','magenta'};
% ptCloudOrganized = functions.pcOrganization(ptCloudProcessed);

results = detect(detector,ptCloudRot);
[bboxes, scores, labels] = detect(detector, ptCloudRot);
detector.ClassNames;

functions.showPointCloudWith3DBoxes(ptCloudRot,bboxes,labels,detector.ClassNames,colors);