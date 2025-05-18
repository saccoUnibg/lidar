function [ptCloudProcessed] = preprocessing(ptCloud)
%PREPROCESSING Summary of this function goes here
% --- Denoise ---
ptCloudDenoise = pcdenoise(ptCloud,"Threshold",0.75);
% pcshow(pcdDenoise,"ColorSource","Intensity");
% title('Denoise')

% --- Downsample ---
ptCloudDownSampled = pcdownsample(ptCloudDenoise,"random",0.75);
% pcshow(ptCloudDownSampled,"ColorSource","Intensity");
% title('Downsampled')

% --- Ground Segmentation ---
[~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloudDownSampled,2,"ElevationThreshold",0.1);

pcshow(ptCloudProcessed,"ColorSource","Intensity");
title ('Processed Point Cloud - Ground removed')
end

