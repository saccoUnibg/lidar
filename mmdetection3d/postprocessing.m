%% 2. Postprocessing
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')
clc;clear; close all;

% --- Workspace filename ---
% workspace_filename = "workspaces/workspace_pointpillars.mat";
workspace_filename = "workspaces/workspace_second_modified.mat";

load(workspace_filename);

% --- Model name ---
% model = "pointpillars"
model = "second";

% --- Path ---
% path = "/Users/cristiansacco/workspaces/lidar/tests/test99_pointpillars";
path = "/Users/cristiansacco/workspaces/lidar/tests/test99_second";

% Filter cyclists results
results_filtered = functions.filter_cyclist(results,model);

%% Show results
close all;
threshold = 0.1;
functions.show_results(path,results_filtered,threshold);

%% Estrazione punti interni alle bb + pcd traiettoria
[pcd_list, pcd_traiettoria,center_list] = functions.extract_points_from_bb (path, results_filtered);

%% Visualizzazione traiettoria
close all;
functions.plot_trajectory(pcd_list,center_list);

%% Calcolo velocita'
% Calculate speed based on extracted points
[speed_array, speed_mean] = functions.calculate_speed(pcd_list);

disp("Speed (mean): " + speed_mean + " km/h");

%% Inclinazione bici
functions.calculate_inclination(pcd_list);
%% Classificazione bici corsa/mountain bike

%% ricava lista yaw da results_filtered
boxes_list = {results_filtered.boxes}';
scores_list = {results_filtered.scores}';
vector_size = size(boxes_list,1);
yaw_list = zeros(vector_size,5); % Initialize yaw_list
yaw_list_modified = yaw_list;
for i = 1 : vector_size
    if ~isempty(boxes_list{i})

        yaw_value = boxes_list{i}(1,7);
        % boxes_list{i}(1,7) = yaw_value + deg2rad(180);
        % results_filtered(i).boxes = boxes_list{i};

        yaw_value_deg = rad2deg(yaw_value);

        yaw_list(i,1) = yaw_value_deg;   % gradi
        yaw_list(i,2) = scores_list{i}(1,1); % score
        yaw_list(i,3) = yaw_value;
        if yaw_value_deg <200
            yaw_list(i,4) = yaw_value_deg; % gradi ma normalizzati
        else
            yaw_list(i,4) = yaw_value_deg+1;
        end
        yaw_list(i,5) = deg2rad(yaw_list(i,4)); % adjusted yaw value
        results_filtered(i).boxes(1,7) = yaw_list(i,5);

    end
end
plot(yaw_list(:,4))