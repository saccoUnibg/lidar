%% 1. Inference
clc;clear; close all;
% Mac
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')
% Ubuntu
% cd('home/cal/Documents/Cristian_S/mmdetection3d')

%% Struttura folder
% /mmdetection3d
%   /tests
%       /test00
%           /0_original
%           /1_pcd
%           /2_bin
%           /3_json/preds
%           "results.mat"
%       /test01
%           /0_original
%           /1_pcd
%           /2_bin
%           /3_json/preds
%           "results.mat"
%   run_batch.py
%% 
extra_functions.show_pcd_from_path(path);
%% Scelta cartella di test da convertire
% Mac:
path = "/Users/cristiansacco/workspaces/lidar/tests/test17";
% Ubuntu:
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