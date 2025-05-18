
%% setup
clc
clear
close all

%% Tools
% lidarViewer
% lidarLabeler

%% import data or load workspace (same .pcd)

%{
    Field "Import":
    0 -> import from file explorer
    1 -> import from workspace
%}
import = 0;

if import == 0
    ptcloud = functions.importPointCloud('/Users/cristiansacco/Tesi/pcd/PointCloudTest',47);
else
    load("workspace.mat")
end

%% preprocessing: denoise, downsample, ground segmentation

ptCloudProcessed = functions.preprocessing(ptcloud);
