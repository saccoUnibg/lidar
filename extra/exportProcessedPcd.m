clc
clear
close all 
cd('/Users/cristiansacco/workspaces/lidar')

% 1. cambiare path sorgente
% 2. creare path destinazione
% 3. cambiare nome file pcd
%% 1. ptCloud: Import data or load workspace (same .pcd)

folderPath = '/Users/cristiansacco/workspaces/lidar/1_files_pcd/test09';  % percorso della cartella
fileList = dir(fullfile(folderPath, '*.pcd'));  % tutti i file .pcd
outputFolder = '/Users/cristiansacco/workspaces/lidar/1_files_pcd/test09cropped';

%% export pcd cropped
for i = 1:length(fileList)
    fileName = fileList(i).name;
    fullFilePath = fullfile(folderPath, fileName);

    ptCloud = pcread(fullFilePath);

    ptCloudProcessed = functions.preprocessingFunction(ptCloud,25,0.75,0.75,0.1);
    fileName = sprintf('Test09f%03d.pcd',i);
    fullPath = fullfile(outputFolder, fileName);

    pcwrite(ptCloudProcessed,fullPath)
end
 
%% 
lidarViewer

%% lidarLabeler
lidarLabeler
