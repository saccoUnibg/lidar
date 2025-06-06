function [ptCloudProcessed] = preprocessingFunction(ptCloud,values)
    
ptCloudProcessed = cleanPointCloud(ptCloud,values.max_distance);
ptCloudProcessed = preprocessing(ptCloudProcessed,values);
    
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

    % Mantiene solo i punti entro 50 metri
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

function [ptCloudProcessed] = preprocessing(ptCloud,values)
%PREPROCESSING Summary of this function goes here
% --- Denoise ---
ptCloudDenoise = pcdenoise(ptCloud,"Threshold",values.denoise_threshold);
% pcshow(pcdDenoise,"ColorSource","Intensity");
% title('Denoise')

% --- Downsample ---
ptCloudDownSampled = pcdownsample(ptCloudDenoise,"random",values.downsample_threshold);
% pcshow(ptCloudDownSampled,"ColorSource","Intensity");
% title('Downsampled')

% --- Ground Segmentation ---
[~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloudDownSampled,2,"ElevationThreshold",values.elevation_threshold);

% pcshow(ptCloudProcessed,"ColorSource","Intensity");
% title ('Processed Point Cloud - Ground removed')

end

% -------------------------------------------------------------------------

