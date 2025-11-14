%% plot bici corsa
clc;clear;close all;
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d';
cd(root);
type = "bici_corsa";
% type = "mtb"
best_pcd_path = root + "/pcd_classification/" + type;
inference_functions.show_pcd_from_path(best_pcd_path);