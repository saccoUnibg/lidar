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
%% 1. ptCloud: Import data or load workspace (same .pcd)

folderPath = '/Users/cristiansacco/Tesi/1_files_pcd/test07';  % percorso della cartella
fileList = dir(fullfile(folderPath, '*.pcd'));  % tutti i file .pcd
outputFolder = ['/Users/cristiansacco/Tesi/1_files_pcd/test07cropped'];


for i = 1:length(fileList)
    fileName = fileList(i).name;
    fullFilePath = fullfile(folderPath, fileName);

    ptCloud = pcread(fullFilePath);

    ptCloudProcessed = functions.preprocessingFunction(ptCloud,25,0.75,0.75,0.1);
    fileName = sprintf('Test07f%03d.pcd',i);
    fullPath = fullfile(outputFolder, fileName);

    pcwrite(ptCloudProcessed,fullPath)
end
 
 
