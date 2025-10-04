%% Struttura folder
%
%   /lidar
%       /mmdetection3d
%           /workspaces
%           inference.m
%           postprocessing.m
%       /tests
%           /test01 ...
%
%% 2. Postprocessing
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')
clc;clear; close all;

% --- Workspace filename ---
% workspace_filename = "workspaces/workspace_pointpillars.mat";
workspace_filename = "workspaces/workspace_11.mat";

load(workspace_filename);

% --- Model name ---
% model = "pointpillars"
model = "second";

% --- Path ---
% path = "/Users/cristiansacco/workspaces/lidar/tests/test99_pointpillars";
path = "/Users/cristiansacco/workspaces/lidar/tests/test11";

%%  Filter cyclists results
close all;
results_filtered = functions.filter_cyclist(results,model);

%% Show results
close all;
threshold = 0.1;
functions.show_results(path,results_filtered,threshold);

%% Estrazione punti interni alle bb + pcd traiettoria
[pcd_list, pcd_traiettoria,center_list] = functions.extract_points_from_bb (path, results_filtered);

%% 0. Visualizzazione traiettoria
functions.plot_trajectory(pcd_list,center_list);

%% 1. Calcolo velocita'
% Calculate speed based on extracted points
[speed_array, speed_mean] = functions.calculate_speed(pcd_list);
disp("Speed (mean): " + speed_mean + " km/h");

%% 2. Inclinazione bici
pcd_ground_list_filtered = functions.calculate_inclination(path,results_filtered, pcd_list);

%% 3. Classificazione bici corsa/mountain bike
