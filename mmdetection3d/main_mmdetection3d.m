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
path = "/Users/cristiansacco/workspaces/lidar/tests/test99_1";
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
%% 3b. import workspace (per lavorare su Mac)


% ----> !!! ricordati di salvare anche cartella di test !!! <----
load("workspace_results.mat")

%% 4. Filtro risultati per sola classe Cyclist

results_filtered = functions.filter_cyclist(results);

%% 4a. Show results
threshold = 0.35;
functions.show_results(path,results_filtered,threshold);

%% 4b. Salvataggio scores modello utilizzato
% functions.save_scores(results, "SECOND")

%% 5. Estrazione punti interni alla bb
threshold = 0.35;
functions.extract_points_from_bb(path, results_filtered);
