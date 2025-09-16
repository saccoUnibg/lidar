%% 
clc;clear; close all;

% Mac
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')

% Ubuntu
cd('home/cal/Documents/Crstian_S/mmdetection3d')

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
% path = "/Users/cristiansacco/workspaces/lidar/tests/test25";
% Per Ubuntu:
path = "pcd_tests/test99";

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
%% 3. import json e proiezione bounding box
results = functions.process_json_folder(path);

%% 4: Visualizzazione bb su pcd (da ottimizzare)
threshold = 0.5;
functions.show_results(path,results,threshold);
% jsonFile = "/Users/cristiansacco/workspaces/lidar/tests/test01/3_json/preds/bin_001.json";
% pointCloudFile = "/Users/cristiansacco/workspaces/lidar/tests/test01/1_pcd/test01 (Frame 0040).pcd";
% threshold = 0.5;
% functions.show_bb_over_pcd(jsonFile,pointCloudFile,threshold);
