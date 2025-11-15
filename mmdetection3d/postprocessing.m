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
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d';
cd(root)
clc;clear; close all;

test = "";
% bike_type = "bici_corsa";
bike_type = "mtb";

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% --- Workspace + path ---
workspace_filename = "workspaces/" + bike_type + "/workspace_"+ test +".mat";
load(workspace_filename);
path = "../tests/" + bike_type + "/test" + test;
% --- Model name ---
model = "second";
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d';
% Filter cyclists results
close all;
threshold = 0.3;
results_filtered = postprocessing_functions.filter_cyclist(results,model,threshold);
% Estrazione punti interni alle bb + pcd traiettoria
[pcd_list, pcd_traiettoria,center_list] = postprocessing_functions.extract_points_from_bb(path, results_filtered);
% salvataggio pcd sole bici in cartella pcd_classification
postprocessing_functions.export_bike_pcd(pcd_list,root,test,bike_type);

%% 0. Show results bounding box in point cloud
close all;
lim = 50;
postprocessing_functions.show_results(path,results_filtered,threshold,lim);
%% 00. Mostrare pcd solo ciclista + bici
path_pcd_bici = "/Users/cristiansacco/workspaces/lidar/mmdetection3d/pcd_classification/mtb/test"+test;
inference_functions.show_pcd_from_path(path_pcd_bici);
%% 1. Visualizzazione traiettoria
close all;
postprocessing_functions.get_trajectory(pcd_list,center_list);

%% 2. Analisi dinamica: Calcolo velocita' e distanza percorsa
[covered_distance, speed_array, speed_max,speed_mean] = postprocessing_functions.get_distance_and_speed(pcd_list);
disp("Covered Distance: " + covered_distance + " m");
disp("Speed (max): " + speed_max + " km/h");
disp("Speed (mean): " + speed_mean + " km/h");

%% 3. Analisi statica: Inclinazione bici
[ground_equation_list, bike_equation_list, angle_list] = postprocessing_functions.get_inclination(path,results_filtered, pcd_list);
%% 3a. plot each pcd with planes
clc;close all;
postprocessing_functions.plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list,angle_list);
%% 3b. plot all pcd with planes
clc;close all;
postprocessing_functions.plot_pcd_ground_sequence(ground_equation_list,bike_equation_list,pcd_list,angle_list);
%% 4. Classificazione 2 features: bici corsa/mountain bike

postprocessing_functions.classification(path,results_filtered,pcd_list);
%% 999. Misc:
close all;

% 1. grafico scores inferenza
figure(1);
media_punteggi = mean([results_filtered.scores]);
plot([results_filtered.scores],YDataSource = '[results_filtered.scores]');
linkdata on;
str_mean_value = "Average score: " + media_punteggi;
yline(media_punteggi,'r--',str_mean_value);
ylabel("[score]");
title("[Scores over acquisition]");
ylim([0,1])

hold on;

% 2. grafico punti per pcd -> diminuiscono con pcd lontane
figure(2);
pts_sizes = zeros(size(pcd_list,1),1);
for i =1 : size(pcd_list,1)
    if ~isempty(pcd_list{i})
        pts_sizes(i) = size(pcd_list{i}.Location,1);
    end
end
plot(pts_sizes)
ylabel("[points]");
title("Points of cyclist per frame");
ylim([0,max(pts_sizes) + 500])

