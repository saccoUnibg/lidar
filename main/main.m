%% 0. Setup iniziale

clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar/main')
% ptCloudProcessed = functions.preprocess_pcd(ptCloud,25,0.75,0.75,0.1);
% lidarViewer
%% 1. Load Dataset
 
outputFolder = fullfile("/Users/cristiansacco/workspaces/lidar/1_files_pcd/");
path = fullfile(outputFolder,'test11/');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
%% Show point cloud (to check rotation)
ptCloud = preview(lidarData);
functions.show_pcd(ptCloud,"Point Cloud - Input (Da ruotare?)");
reset(lidarData);
%% 2. Preprocess data - Point Cloud Front View

ptCloudRotation = 0; % fattore di rotazione

xMin = 0.0;     % Minimum value along X-axis.
xMax = 69.12;   % Maximum value along X-axis.

yMin = -39.68;  % Minimum value along Y-axis.
yMax = 39.68;   % Maximum value along Y-axis.

zMin = -5.0;    % Minimum value along Z-axis.
zMax = 5.0;     % Maximum value along Z-axis.

xStep = 0.16;   % Resolution along X-axis.
yStep = 0.16;   % Resolution along Y-axis.

pointCloudRange = [xMin xMax yMin yMax zMin zMax];
voxelSize = [xStep yStep];

croppedPointCloudObj = functions.cropPointCloud(lidarData,pointCloudRange,ptCloudRotation);

ptCloudFrontView = croppedPointCloudObj{20,1};
hold on;
functions.show_pcd(ptCloudFrontView,"Point Cloud - Front view");

reset(lidarData);
%% 3a. Downsample locale (maggiore sui punti vicini) - Point Cloud Downsampled

% scelgo distanza a cui fare downsample
distanceDownsample = 25;
idxNear = ptCloudFrontView.Location(:,2) < distanceDownsample;  % Y = avanti
ptNear = select(ptCloudFrontView, idxNear);

% Downsample dei punti vicini considerando un solo punto per ogni cubo di
% 0.15 di lato
ptNearDS = pcdownsample(ptNear, 'gridAverage', 0.2);

% Punti lontani li tengo così
idxFar = ptCloudFrontView.Location(:,2) >= distanceDownsample;
ptFar = select(ptCloudFrontView, idxFar);

% Combino le due point cloud
mergedLocs = [ptNearDS.Location; ptFar.Location];
mergedInt = [ptNearDS.Intensity; ptFar.Intensity];
ptCloudDownsampled = pointCloud(mergedLocs, 'Intensity', mergedInt);

functions.show_pcd(ptCloudDownsampled,"Point Cloud - Downsampled");
%% 3b. Downsample generale

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
%% 4. Offset asse z - Point Cloud Shifted
% Applica un offset Z di -0.7 m per allineare al suolo KITTI
locations = ptCloudDownsampled.Location;
intensity = ptCloudDownsampled.Intensity;

offsetZ = 0;
locations(:,3) = locations(:,3) + offsetZ;
ptCloudShifted = pointCloud(locations, 'Intensity', intensity);
functions.show_pcd(ptCloudShifted,"Point Cloud - Z shifted");
%% 5. Detection
threshold = 0.5;
%%
functions.detect_pcd(ptCloudFrontView, threshold,"FrontView");
%%
functions.detect_pcd(ptCloudDownsampled,threshold,"Downsample");
%%
functions.detect_pcd(ptCloudShifted, threshold, "Z Shifted");

%% functions.detect_pcd(ptCloudOrg, threshold, "Organized\n");
%% 999. Misc


zVals = ptCloudShifted.Location(:,3);

figure;
histogram(zVals, 100);  % 100 bin per più dettaglio
xlabel('Altezza Z (metri)');
ylabel('Numero di punti');
title('Distribuzione verticale dei punti (asse Z)');
grid on;