function [ptCloudProcessed] = preprocessingFunction(ptCloud,max_distance,denoise_threshold,downsample_threshold,elevation_threshold)
    
ptCloudProcessed = cleanPointCloud(ptCloud,max_distance);
ptCloudProcessed = preprocessing(ptCloudProcessed,denoise_threshold,downsample_threshold,elevation_threshold);  
end
% -------------------------------------------------------------------------

function [ptCloudClean] = cleanPointCloud(ptCloud,max_distance)
    pts = ptCloud.Location;

    % Estrae l'intensità se disponibile
    if ~isempty(ptCloud.Intensity)
        intensity = ptCloud.Intensity;
    else
        intensity = [];
    end

    % Rimuove righe con NaN
    valid = ~any(isnan(pts), 2);

    % Rimuove righe completamente nulle (es. [0 0 0])
    valid = valid & any(pts ~= 0, 2);

    % Calcola la distanza euclidea da origine (0,0,0)
    dist = sqrt(sum(pts.^2, 2));

    % Mantiene solo i punti entro "max_distance" metri
    valid = valid & (dist <= max_distance);

    % Applica i filtri ai punti
    ptsFiltered = pts(valid, :);

    % Applica i filtri all'intensità (se esiste)
    if ~isempty(intensity)
        intensityFiltered = intensity(valid);
        ptCloudClean = pointCloud(ptsFiltered, 'Intensity', intensityFiltered);
    else
        ptCloudClean = pointCloud(ptsFiltered);
    end
end

% -------------------------------------------------------------------------

function [ptCloudProcessed] = preprocessing(ptCloud,denoise_threshold,downsample_threshold,elevation_threshold)
%PREPROCESSING Summary of this function goes here
% --- Denoise ---
ptCloudDenoise = pcdenoise(ptCloud,"Threshold",denoise_threshold);
% --- Downsample ---
ptCloudDownSampled = pcdownsample(ptCloudDenoise,"random",downsample_threshold);
% --- Ground Segmentation ---
[~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloudDownSampled,2,"ElevationThreshold",elevation_threshold);
end

% -------------------------------------------------------------------------

