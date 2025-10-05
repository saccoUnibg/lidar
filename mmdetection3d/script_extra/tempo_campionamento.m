clc;clear; close all;

path = "/Users/cristiansacco/workspaces/lidar/tests/test99_second";
csv_path = path + "/0_csv";

files = dir(fullfile(csv_path, '*.csv'));


allData = cell(numel(files),1);

for k = 1:numel(files)
    filename = fullfile(csv_path, files(k).name);
    T = readtable(filename);              % legge con header
    allData{k} = T.timestamp;             % colonna per nome
end
%% calcolo vettore minimi
mins = cellfun(@min,allData)
%% Stampa timestamps
for i = 1 : size(min_timestamp_list,1)
    fprintf('%.15f\n', min_timestamp_list(i));
end
%% calcolo delle differenze
diff_timestamp = diff(mins);
% la funzione diff restituisce un vettore di differenze tra elementi
% consecutivi

%% media e varianza dei tempi di campionamento
mean_diff = mean(diff_timestamp);
var_diff = var(diff_timestamp);
disp("Media e varianza")
fprintf('%.15f\n', mean_diff)
fprintf('%.15f\n', var_diff)
