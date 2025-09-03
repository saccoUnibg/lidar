function [ptCloudProcessed] = preprocess_pcd(ptCloud)
    
    % elevation_threshold = 0.05;
    elevation_threshold = 0.3;
    ptCloud = removeInvalidPoints(ptCloud);
    ptCloud = functions.organize_pcd(ptCloud);
    [~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloud,2,"ElevationThreshold",elevation_threshold);
    
end