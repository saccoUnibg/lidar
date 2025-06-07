function [ptCloudSeen] = ptCloudVisible(ptCloudProcessed)
    xyz = ptCloudProcessed.Location;
    intensity = ptCloudProcessed.Intensity;

    inRange = ...
    xyz(:,1) >= 0 & xyz(:,1) <= 69.12 & ...
    xyz(:,2) >= -39.68 & xyz(:,2) <= 39.68 & ...
    xyz(:,3) >= -5 & xyz(:,3) <= 5;

    ptCloudSeen = pointCloud(xyz(inRange, :), 'Intensity', intensity(inRange));
    
end


