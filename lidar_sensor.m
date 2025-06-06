
%% setup
clc
clear
close all

%% Tools
% lidarViewer
% lidarLabeler

%% 1. import data or load workspace (same .pcd)

ptCloud = functions.importPointCloud('/Users/cristiansacco/Tesi/1_files_pcd/test01',110);

% pcshow(ptCloud,"ColorSource","Intensity")
%% 2. preprocessing
% values = models.PreprocessingValues(30,0.75,0.75,0.1);
values = models.PreprocessingValues();
values.max_distance = 30;
values.denoise_threshold = 0.75;
values.downsample_threshold = 0.75;
values.elevation_threshold = 0.1;

ptCloudProcessed = functions.preprocessingFunction(ptCloud,values);

pcshow(ptCloudProcessed,"ColorSource","Intensity");

%% 3. PointPillars model
pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;

ptCloudOrganized = functions.pcOrganization(ptCloudProcessed);

results = detect(detector,ptCloudOrganized);
detector.ClassNames
% problema: https://it.mathworks.com/help/lidar/ug/object-detection-using-pointpillars-network.html
% qua è scritto che allenano solo su car e truck

