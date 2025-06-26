function [ptCloud] = import_pcd(folderPath,pcd_index)

% - rimozione righe nulle
% - rimozione punti oltre "max_distance"
% - denoise
% - downsample
% - ground segmentation 
files = dir(fullfile(folderPath, '*.pcd'));
filePath = fullfile(folderPath, files(pcd_index).name);
ptCloud = pcread(filePath);
end

