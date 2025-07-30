function croppedPointCloudObj = cropPointCloud(lidarData)
    reset(lidarData)
    xmin = 0.0;     % Minimum value along X-axis.
    xmax = 69.12;   % Maximum value along X-axis.
    
    ymin = -39.68;  % Minimum value along Y-axis.
    ymax = 39.68;   % Maximum value along Y-axis.
   
    zmin = -5.0;    % Minimum value along Z-axis.
    zmax = 5.0;     % Maximum value along Z-axis.
    
    xStep = 0.16;   % Resolution along X-axis.
    yStep = 0.16;   % Resolution along Y-axis.

    voxelSize = [xStep yStep];
    
    numFiles = size(lidarData.Files,1);
    croppedPointCloudObj = cell(size(numFiles));

    for i = 1:numFiles
        ptCloud = read(lidarData);
        
        ptCloud = preprocessing(ptCloud);

        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Rototraslazione

        rotationAngles = [0 0 90];
        translation = [xmax/2 0 0];
        % translation = [0 0 0];
        tform = rigidtform3d(rotationAngles,translation);
        ptCloud = pctransform(ptCloud,tform);
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

        if(numel(size(ptCloud.Location)) == 3)
            % Organized point cloud
            [x,y] = find( ptCloud.Location(:,:,1) < xmax ...
                                & ptCloud.Location(:,:,1) > xmin ...
                                & ptCloud.Location(:,:,2) < ymax ...
                                & ptCloud.Location(:,:,2) > ymin ...
                                & ptCloud.Location(:,:,3) < zmax ...
                                & ptCloud.Location(:,:,3) > zmin);    
            ptCloud = select(ptCloud, x, y, 'OutputSize', 'full'); 
        else
            % Unorganized point cloud
            pos = find( ptCloud.Location(:,1) < xmax ...
                & ptCloud.Location(:,1) > xmin ...
                & ptCloud.Location(:,2) < ymax ...
                & ptCloud.Location(:,2) > ymin ...
                & ptCloud.Location(:,3) < zmax ...
                & ptCloud.Location(:,3) > zmin);    
            ptCloud = select(ptCloud, pos, 'OutputSize', 'full');
        end

        processedData = removeInvalidPoints(ptCloud);
        croppedPointCloudObj{i,1} = processedData;
        
    end
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function [ptCloudProcessed] = preprocessing(ptCloud)
    
    elevation_threshold = 0.05;
    ptCloud = removeInvalidPoints(ptCloud);
    ptCloud = functions.organize_pcd(ptCloud);
    [~,ptCloudProcessed,~] = segmentGroundSMRF(ptCloud,2,"ElevationThreshold",elevation_threshold);
    
end