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
workspace_filename = "workspaces/workspace_11.mat";

load(workspace_filename);

% --- Model name ---
model = "second";

% --- Path ---
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

%% 1. Analisi dinamica: Calcolo velocita'
[speed_array, speed_mean] = functions.calculate_speed(pcd_list);

%% 2. Analisi statica: Inclinazione bici
[ground_equation_list, bike_equation_list, angle_list] = functions.calculate_inclination(path,results_filtered, pcd_list);

%% 3. Classificazione 2 features: bici corsa/mountain bike
close all;
pcd_prova = pcd_list{20};
pcshow(pcd_prova)
hold on;

pts = pcd_prova.Location();
        xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
        yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
        [xg, yg] = meshgrid(xrange, yrange);


zg = 0.5*xg + 0.5*yg;

hGround = surf(xg, yg, zg, ...
    'FaceAlpha', 0.55, ...
    'EdgeColor','none', ...
    'FaceColor', [0.20 0.70 0.30]);   % verde

axis on
grid on
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
