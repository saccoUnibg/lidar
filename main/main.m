%% --- 0. Setup iniziale
clc; clear; close all;
cd('/Users/cristiansacco/workspaces/lidar/main')
% ptCloudProcessed = functions.preprocess_pcd(ptCloud,25,0.75,0.75,0.1);
% lidarViewer
% lidarLabeler
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
%% --- 1. Load Dataset
outputFolder = fullfile("/Users/cristiansacco/workspaces/lidar/1_files_pcd/");
path = fullfile(outputFolder,'test11/cropped');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
%% --- 2. Show point cloud (to check rotation)
ptCloud = preview(lidarData);
functions.show_pcd(ptCloud,"Point Cloud - Input (Da ruotare?)");
reset(lidarData);
%% --- 3. Preprocess data - Point Cloud Front View

croppedPointCloudObj = functions.cropPointCloud(lidarData);

ptCloudFrontView = croppedPointCloudObj{20,1};
hold on;
functions.show_pcd(ptCloudFrontView,"Point Cloud - Front view");
reset(lidarData);

%% --- Downsample locale (maggiore sui punti vicini) - Point Cloud Downsampled

% scelgo distanza a cui fare downsample
distanceDownsample = 25;
idxNear = ptCloudFrontView.Location(:,2) < distanceDownsample;  % Y = avanti
ptNear = select(ptCloudFrontView, idxNear);

% Downsample dei punti vicini considerando un solo punto per ogni cubo di
% 0.2 di lato
ptNearDS = pcdownsample(ptNear, 'gridAverage', 0.2);

% Punti lontani li tengo così
idxFar = ptCloudFrontView.Location(:,2) >= distanceDownsample;
ptFar = select(ptCloudFrontView, idxFar);

% Combino le due point cloud
mergedLocs = [ptNearDS.Location; ptFar.Location];
mergedInt = [ptNearDS.Intensity; ptFar.Intensity];
ptCloudDownsampled = pointCloud(mergedLocs, 'Intensity', mergedInt);

functions.show_pcd(ptCloudDownsampled,"Point Cloud - Downsampled");
%% --- Downsample random

% switch1 = 1;
% 
% if switch1 == 1
%     gridStep = 0.1;
%     ptCloudDownsampled = pcdownsample(ptCloud, 'gridAverage', gridStep);
% else
%     ptCloudIdealValue = 34500;
%     percentage = (ptCloudIdealValue)/size(ptCloud.Location,1);
%     ptCloudDownsampled = pcdownsample(ptCloud,"random",percentage,"PreserveStructure",true);
% end
% 
% functions.show_pcd(ptCloudDownsampled,"Pt Cloud Downsampled");
%% --- Offset asse z - Point Cloud Shifted
% Applica un offset Z di -0.7 m per allineare al suolo Pandaset
locations = ptCloudFrontView.Location;
intensity = ptCloudFrontView.Intensity;

offsetZ = -0.7;
locations(:,3) = locations(:,3) + offsetZ;
ptCloudShifted = pointCloud(locations, 'Intensity', intensity);
functions.show_pcd(ptCloudFrontView,"Point Cloud - Z shifted");
%% --- Offset asse z - Point Cloud Shifted Downsampled
% Applica un offset Z di -0.7 m per allineare al suolo Pandaset
locations = ptCloudDownsampled.Location;
intensity = ptCloudDownsampled.Intensity;
% -0.7 miglior risultato
offsetZ = -0.7;
locations(:,3) = locations(:,3) + offsetZ;
ptCloudShiftedDownsampled = pointCloud(locations, 'Intensity', intensity);
functions.show_pcd(ptCloudShiftedDownsampled,"Point Cloud - Z shifted downsampled");
%% --- Detection
% threshold = 0.30; 
threshold = 0.4;
%%
functions.detect_pcd(ptCloudFrontView, threshold,"FrontView");
%%
functions.detect_pcd(ptCloudDownsampled,threshold,"Downsample");
%%
functions.detect_pcd(ptCloudShifted, threshold, "Z Shifted");
%%
functions.detect_pcd(ptCloudShiftedDownsampled, threshold, "Z Shifted downsampled");
