%% 
clc;clear; close all;
importlib = py.importlib.import_module('importlib');
cd('/Users/cristiansacco/workspaces/lidar/mmdetection3d')

% lidarViewer
% lidarLabeler
%% Struttura folder
%   /test00
%      |
%       /1_pcd
%       /2_bin
%       /3_json/preds

%   /test01
%      |
%       /1_pcd
%       /2_bin
%       /3_json/preds
%   ...

%% Scelta cartella di test da convertire
path = "/Users/cristiansacco/workspaces/lidar/tests/test01";
%% 0. crop pcd

%% 1. Export .pcd -> .bin da path
functions.export_bin_files(path);

%% 2. Inferenza tramite script .py
[status, out] = system('python3 script_inference.py');
disp(out)
% guarda ----> pyrunfile
%% 3. import json e proiezione bounding box
results = functions.process_json_folder(path);

%% 4: Visualizzazione bb su pcd (da ottimizzare)

threshold = 0.5;
functions.show_results(path,results,threshold);
% jsonFile = "/Users/cristiansacco/workspaces/lidar/tests/test01/3_json/preds/bin_001.json";
% pointCloudFile = "/Users/cristiansacco/workspaces/lidar/tests/test01/1_pcd/test01 (Frame 0040).pcd";
% threshold = 0.5;
% functions.show_bb_over_pcd(jsonFile,pointCloudFile,threshold);

