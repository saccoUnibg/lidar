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

%% 2. Preprocess data - Point Cloud Front View

numFiles = size(lidarData.Files,1);
croppedPointCloudObj = cell(size(numFiles));
xmax = 75;
xmin = -75;
ymax = 75;
ymin = -75;
zmax = 5;
zmin = -5;

new_path = path + 'cropped';
if ~exist(new_path, 'dir')
    mkdir(new_path);
end
for i = 1:numFiles
    ptCloud = read(lidarData);
    pos = find( ptCloud.Location(:,1) < xmax ...
        & ptCloud.Location(:,1) > xmin ...
        & ptCloud.Location(:,2) < ymax ...
        & ptCloud.Location(:,2) > ymin ...
        & ptCloud.Location(:,3) < zmax ...
        & ptCloud.Location(:,3) > zmin);    
    ptCloud = select(ptCloud, pos, 'OutputSize', 'full');
    processedData = removeInvalidPoints(ptCloud);
    croppedPointCloudObj{i,1} = processedData;
    filename = fullfile(new_path, sprintf('pointcloud_%03d.pcd', i));

    pcwrite(ptCloud,filename,"Encoding","ascii");
end


