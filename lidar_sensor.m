
%% setup
clc
clear
close all
%% Tools
% lidarViewer
% lidarLabeler

%% import data or load workspace (same .pcd)
import = 0;

if import == 0
    ptcloud = importPointCloud('/Users/cristiansacco/Tesi/pcd/PointCloudTest',47);
else
    load("workspace.mat")
end

%% preprocessing: denoise, downsample, ground segmentation

ptCloudProcessed = preprocessing(ptcloud);

lidarViewer