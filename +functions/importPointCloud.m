function [ptCloud] = importPointCloud(folderPath,pcd_index)
%IMPORTPOINTCLOUD Summary of this function goes here
%   Detailed explanation goes here

files = dir(fullfile(folderPath, '*.pcd'));

filePath = fullfile(folderPath, files(pcd_index).name);
ptCloud = pcread(filePath);
pcshow(ptCloud,"ColorSource","Intensity")
title('Imported Point Cloud')
end

