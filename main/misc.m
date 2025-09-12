%% setup
clc; clear; close all;

cd('/Users/cristiansacco/workspaces/lidar/main')
%% Load datastore
outputFolder = fullfile("/Users/cristiansacco/workspaces/lidar/1_files_pcd/");
path = fullfile(outputFolder,'test11/cropped');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
ptCloud = preview(lidarData);
functions.show_pcd(ptCloud,"Point Cloud - Input (Da ruotare?)");

%% show pcd for tl
newPath = "/Users/cristiansacco/workspaces/lidar/1_files_pcd/0_transfer_learning/";
endpoint = "set_00/pcd_00";
fullPath = newPath + endpoint;
lidarData = fileDatastore(fullPath,'ReadFcn',@(x) pcread(x));
ptCloudTL = preview(lidarData);
functions.show_pcd(ptCloudTL,"tl");

%% ciclo su datastore: ruota e salva
newPath = "/Users/cristiansacco/workspaces/lidar/1_files_pcd/0_transfer_learning/";
endpoint = "set_01";
fullPath = newPath + endpoint;

if ~exist(fullPath, 'dir')
    try
        mkdir(fullPath);
        reset(lidarData);
        numFiles = size(lidarData.Files,1);
        for i = 1:numFiles
            ptCloud = read(lidarData);
            % rimozione punti non validi e terreno
            ptCloud = functions.preprocess_pcd(ptCloud);

            % rotazione 90 gradi
            rotationAngles = [0 0 90];
            translation = [0 0 0];
            tform = rigidtform3d(rotationAngles,translation);
            ptCloudRotated = pctransform(ptCloud, tform);
            
            % salvataggio pcd in fullPath
            pcdFileName = fullfile(fullPath, sprintf('pcd_tl_%03d.pcd', i));
            pcwrite(ptCloudRotated, pcdFileName);
        end
    catch ME
        rmdir(fullPath,'s');
        disp("Errore nel salvataggio delle pcd, ripetere l'operazione");
        disp(ME.message);
    end
else
    disp("Cartella gia' presente, non e' stato sovrascritto nulla (forse devi cambiare endpoint?)");
end

%% visualizzazione point cloud datastore
newPath = "/Users/cristiansacco/workspaces/lidar/1_files_pcd/0_transfer_learning/";
endpoint = "set_01/pcd_01";
fullPath = newPath + endpoint;

lidarData = fileDatastore(fullPath,'ReadFcn',@(x) pcread(x));

ptCloud = read(lidarData);
functions.show_pcd(ptCloud,"PtCloud");

%% rotazione 90 gradi
% Rotazione 90 gradi -> y positivo frontale
rotationAngles = [0 0 0];
translation = [0 0 0];
tform = rigidtform3d(rotationAngles,translation);
ptCloudRot = pctransform(ptCloud,tform);

figure()
ax = pcshow(ptCloudRot,"ColorSource","Intensity");
set(ax,'XLim',[-30 30],'YLim',[0 30]);
title("Pcd Ruotata");
axis on
grid on
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');

%% Lista funzioni utilizzate dagli script
cd('/Users/cristiansacco/workspaces/lidar/main')
matlab.codetools.requiredFilesAndProducts('main.m')'
matlab.codetools.requiredFilesAndProducts('transferLearning.m')'

%% Distribuzione altezza punti pcd

zVals = ptCloudShifted.Location(:,3);
figure;
histogram(zVals, 100);  % 100 bin per più dettaglio
xlabel('Altezza Z (metri)');
ylabel('Numero di punti');
title('Distribuzione verticale dei punti (asse Z)');
grid on;

%% test new detector trained

newPath = "/Users/cristiansacco/workspaces/lidar/1_files_pcd/0_transfer_learning/";
endpoint = "set_01/pcd_01";
fullPath = newPath + endpoint;

lidarData = fileDatastore(fullPath,'ReadFcn',@(x) pcread(x));

ptCloud = read(lidarData);
functions.show_pcd(ptCloud,"PtCloud");

disp("Nuovo detector")
classNames = {'Cyclist','Car'};
colors = {'green','magenta'};
threshold = 0.4;
newDetectorObject = load("newDetector_13righe.mat");

newDetector = newDetectorObject.newDetector;
[bboxes,score,labels] = detect(newDetector,ptCloud,"Threshold",threshold);

functions.detect_pcd(ptCloud,newDetector,threshold,"Inferenza New Detector");


