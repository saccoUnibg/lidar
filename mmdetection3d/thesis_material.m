%% pcshow point cloud generica

pcshow("/Users/cristiansacco/workspaces/lidar/tests/bici_corsa/test01/0_original/test01 (Frame 0022).pcd")


%% Selezione test
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d';
cd(root)
clc;clear; close all;

test = "03";
bike_type = "bici_corsa";
bike_type = "mtb";
path = "../tests/" + bike_type + "/test" + test;
%% Show pcd with index (faster way) - Raw data

% mtb, test03, frame 28

pcd_index = 28;
subfolder0 = "/0_original";
subfolder1 = "/1_pcd";
path1 = path + subfolder0;

lidarData = fileDatastore(path1,'ReadFcn',@(x) pcread(x));
reset(lidarData);
numFiles = size(lidarData.Files,1);

for i = 1 : numFiles
    pointCloud = lidarData.read();
    if i~=pcd_index
        continue
    end
    extra_functions.show_pcd(pointCloud,"Point cloud");
end

