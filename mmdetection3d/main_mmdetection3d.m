%% 
clc;clear; close all;

% Mac
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')

% Ubuntu
% cd('home/cal/Documents/Cristian_S/mmdetection3d')

% importlib = py.importlib.import_module('importlib');
% lidarViewer
% lidarLabeler
% matlab.codetools.requiredFilesAndProducts('main_mmdetection3d.m')'

%% Struttura folder
% /mmdetection3d
%   /tests
%       /test00
%           /0_original
%           /1_pcd
%           /2_bin
%           /3_json/preds
%       /test01
%           /0_original
%           /1_pcd
%           /2_bin
%           /3_json/preds
%   run_batch.py
%   

%% Scelta cartella di test da convertire
% Per Mac:
path = "/Users/cristiansacco/workspaces/lidar/tests/test99_second";
% Per Ubuntu:
% path = "pcd_tests/test99";

%% 0. crop pcd
functions.crop_pcd_folder(path);

%% 1. Export .pcd -> .bin
functions.export_bin_files(path);

%% 2. Inferenza: script ".py"
% [status, out] = system('python3 prova.py --input "Hello World!" ');

input_path = path + "/2_bin";
output_path = path + "/3_json";

cmd = " python3 run_batch.py --input " + input_path + " --output " + output_path;
disp("--- Comando python eseguito: " + cmd);
[status, out] = system(cmd);
disp(out)

%% 3a. import json e proiezione bounding box
results = functions.process_json_folder(path);
save("workspace_results.mat");

%% Workflow -> pointpillars
% load results + set path + filter results
clc;clear; close all;
load("workspaces/workspace_pointpillars.mat")
path = "/Users/cristiansacco/workspaces/lidar/tests/test99_pointpillars";
model = "pointpillars"
% filter cyclists results
results_filtered = functions.filter_cyclist(results,model);

%% Workflow -> SECOND
% load results + set path + filter results
clc;clear; close all;
load("workspaces/workspace_second.mat")
path = "/Users/cristiansacco/workspaces/lidar/tests/test99_second";
model = "second"

results_filtered = functions.filter_cyclist(results,model);

%% Show results
% show results
threshold = 0.1;
functions.show_results(path,results_filtered,threshold);

%% Estrazione punti interni alla bb
pcd_list = functions.extract_points_from_bb(path, results_filtered);

%% Estrazione velocita'
% Calculate speed based on extracted points
speed_data = functions.calculate_speed(pcd_list);

