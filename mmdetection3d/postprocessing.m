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

test = "01";
bike_type = "bici_corsa";
% bike_type = "mtb";

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% --- Workspace + path ---
workspace_filename = "workspaces/" + bike_type + "/workspace_"+ test +".mat";
load(workspace_filename);
path = "../tests/" + bike_type + "/test" + test;
% --- Model name ---
model = "second";

%%  Filter cyclists results
close all;
threshold = 0.3;
results_filtered = postprocessing_functions.filter_cyclist(results,model,threshold);

%% Show results
close all;
lim = 50;
postprocessing_functions.show_results(path,results_filtered,threshold,lim);

%% Estrazione punti interni alle bb + pcd traiettoria
[pcd_list, pcd_traiettoria,center_list] = postprocessing_functions.extract_points_from_bb(path, results_filtered);

%% 0. Visualizzazione traiettoria
close all;
postprocessing_functions.plot_trajectory(pcd_list,center_list);

%% 1. Analisi dinamica: Calcolo velocita'
[speed_array, speed_mean] = postprocessing_functions.calculate_speed(pcd_list);

%% 2. Analisi statica: Inclinazione bici
clc;close all;
[ground_equation_list, bike_equation_list, angle_list] = postprocessing_functions.calculate_inclination(path,results_filtered, pcd_list);
%% plot each pcd with planes
postprocessing_functions.plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list,angle_list);
%% plot all pcd with planes
postprocessing_functions.plot_pcd_ground_sequence(ground_equation_list,bike_equation_list,pcd_list,angle_list);
%% 3. Classificazione 2 features: bici corsa/mountain bike
postprocessing_functions.classification(path,results_filtered,pcd_list);
%% 999. Misc
