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
workspace_filename = "workspaces/workspace_10.mat";

load(workspace_filename);

% --- Model name ---
model = "second";

% --- Path ---
path = "/Users/cristiansacco/workspaces/lidar/tests/pcd_tests_mtb/test10";

%%  Filter cyclists results
close all;
threshold = 0.3;
results_filtered = functions.filter_cyclist(results,model,threshold);

%% Show results
close all;
functions.show_results(path,results_filtered,threshold);

%% Estrazione punti interni alle bb + pcd traiettoria
[pcd_list, pcd_traiettoria,center_list] = functions.extract_points_from_bb(path, results_filtered);

%% 0. Visualizzazione traiettoria
functions.plot_trajectory(pcd_list,center_list);

%% 1. Analisi dinamica: Calcolo velocita'
[speed_array, speed_mean] = functions.calculate_speed(pcd_list);

%% 2. Analisi statica: Inclinazione bici
clc;close all;
[ground_equation_list, bike_equation_list, angle_list] = functions.calculate_inclination(path,results_filtered, pcd_list);

%% 3. Classificazione 2 features: bici corsa/mountain bike


%% 999. Misc
