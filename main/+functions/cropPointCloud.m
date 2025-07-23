function croppedPointCloudObj = cropPointCloud(lidarData,pcRange,invertiPointCloud)
    reset(lidarData)
    xmin = pcRange(1,1);
    xmax = pcRange(1,2);
    ymin = pcRange(1,3);
    ymax = pcRange(1,4);
    zmin = pcRange(1,5);
    zmax = pcRange(1,6);
    
    numFiles = size(lidarData.Files,1);
    croppedPointCloudObj = cell(size(numFiles));
    
    for i = 1:numFiles
        ptCloud = read(lidarData);
        if invertiPointCloud ==1
            ptCloud = functions.rotate_pcd(ptCloud,pi);
        end

        ptCloud = functions.organize_pcd(ptCloud);

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
        % ptCloud = functions.rotate_pcd(ptCloud,pi/2);

        processedData = removeInvalidPoints(ptCloud);
        croppedPointCloudObj{i,1} = processedData;
        
    end
end

