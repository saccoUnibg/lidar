%% 0. Setup iniziale

clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar/main')
% ptCloudProcessed = functions.preprocess_pcd(ptCloud,25,0.75,0.75,0.1);
%% 1. Load Dataset
 
outputFolder = fullfile("1_files_pcd/");
path = fullfile(outputFolder,'test00/');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));

%% Show point cloud (to check rotation)
ptCld = preview(lidarData);
functions.show_pcd(ptCld,"Point Cloud - Input (Da ruotare?)");

%% 2. Preprocess data
rotatePointCloud = 1;

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

croppedPointCloudObj = functions.cropPointCloud(lidarData,pointCloudRange,rotatePointCloud);

ptCloud = croppedPointCloudObj{20,1};
functions.show_pcd(ptCloud,"Point Cloud - Front view");
%% 3a. Downsample locale (maggiore sui punti vicini)

% scelgo distanza a cui fare downsample
distanceDownsample = 20;
idxNear = ptCloud.Location(:,1) < distanceDownsample;  % X = avanti
ptNear = select(ptCloud, idxNear);

% Downsample dei punti vicini considerando un solo punto per ogni cubo di
% 0.15 di lato
ptNearDS = pcdownsample(ptNear, 'gridAverage', 0.05);

% Punti lontani li tengo così
idxFar = ptCloud.Location(:,1) >= distanceDownsample;
ptFar = select(ptCloud, idxFar);

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
%% 4. Offset asse z
% Applica un offset Z di -0.7 m per allineare al suolo KITTI
locations = ptCloudDownsampled.Location;
intensity = ptCloudDownsampled.Intensity;

offsetZ = 0;
locations(:,3) = locations(:,3) + offsetZ;
ptCloudShifted = pointCloud(locations, 'Intensity', intensity);
functions.show_pcd(ptCloudShifted,"Point Cloud - Z shifted");
%% 5. Detection
classNames = {'Car','Truck'};
colors = {'green','magenta'};

pretrainedDetector = load('pretrainedPointPillarsDetector.mat','detector');
detector = pretrainedDetector.detector;

[bboxes,score,labels] = detect(detector,ptCloudShifted,"Threshold",0.5);

if isempty(bboxes)
    disp("Nessun oggetto rilevato.");
else
    disp("Oggetti rilevati: " + size(bboxes,1));
end
functions.helperShowPointCloudWith3DBoxes(ptCloudShifted,bboxes,labels,classNames,colors);
%% 999. Misc
zVals = ptCloudShifted.Location(:,3);

figure;
histogram(zVals, 100);  % 100 bin per più dettaglio
xlabel('Altezza Z (metri)');
ylabel('Numero di punti');
title('Distribuzione verticale dei punti (asse Z)');
grid on;