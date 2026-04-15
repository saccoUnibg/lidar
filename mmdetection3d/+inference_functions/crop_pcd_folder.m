function crop_pcd_folder(path)
    originalPath = path + "/0_original";
    pcdPath = path + "/1_pcd";

    if ~exist(pcdPath, 'dir')
        lidarData = fileDatastore(originalPath,'ReadFcn',@(x) pcread(x));
        reset(lidarData);
        mkdir(pcdPath);
        numFiles = size(lidarData.Files,1);
        for i = 1:numFiles
            ptCloud = read(lidarData);
            ptCloud = crop_pcd(ptCloud);
            ptCloudProcessed = preprocess_pcd(ptCloud);
            pcd_fileName = fullfile(pcdPath, sprintf('pcd_%03d.pcd', i));
            pcwrite(ptCloudProcessed,pcd_fileName,"Encoding","ascii");
        end
        disp(" Crop pcd folder: --- OK ---")
    else
        warning("Cartella gia' presente: %s",pcdPath);
    end
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ptCloud = crop_pcd(pcd)
    xmin = 0.0;     % Minimum value along X-axis.
    xmax = 40;   % Maximum value along X-axis.
    
    ymin = -20;  % Minimum value along Y-axis.
    ymax = 20;   % Maximum value along Y-axis.
   
    zmin = -5.0;    % Minimum value along Z-axis.
    zmax = 5.0;     % Maximum value along Z-axis.
    
    % pcd = functions.preprocess_pcd(pcd);
    pos = find( pcd.Location(:,1) < xmax ...
                & pcd.Location(:,1) > xmin ...
                & pcd.Location(:,2) < ymax ...
                & pcd.Location(:,2) > ymin ...
                & pcd.Location(:,3) < zmax ...
                & pcd.Location(:,3) > zmin); 
    
    ptCloud = select(pcd, pos, 'OutputSize', 'full');
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function [ptCloudProcessed] = preprocess_pcd(ptCloud)
    
    % elevation_threshold = 0.05;
    % elevation_threshold = 0.3;
    % downsample and denoise ptCloud
    ptCloud = pcdownsample(ptCloud, 'gridAverage', 0.1); % Downsample the point cloud
    ptCloud = pcdenoise(ptCloud); % Denoise the point cloud
    elevation_threshold = 0.05; % 5cm da terra
    ptCloud = removeInvalidPoints(ptCloud);
    [~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloud,2,"ElevationThreshold",elevation_threshold);
    
end