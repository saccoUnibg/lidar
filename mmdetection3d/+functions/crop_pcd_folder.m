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
            pcd_fileName = fullfile(pcdPath, sprintf('pcd_%03d.pcd', i));
            pcwrite(ptCloud,pcd_fileName);
        end
        disp(" Crop pcd folder: --- OK ---")
    else
        warning("Cartella gia' presente: %s",pcdPath);
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function cropped_pcd = crop_pcd(pcd)
    xmin = 0.0;     % Minimum value along X-axis.
    xmax = 69.12;   % Maximum value along X-axis.
    
    ymin = -39.68;  % Minimum value along Y-axis.
    ymax = 39.68;   % Maximum value along Y-axis.
   
    zmin = -5.0;    % Minimum value along Z-axis.
    zmax = 5.0;     % Maximum value along Z-axis.
    
    % pcd = functions.preprocess_pcd(pcd);
    pos = find( pcd.Location(:,1) < xmax ...
                & pcd.Location(:,1) > xmin ...
                & pcd.Location(:,2) < ymax ...
                & pcd.Location(:,2) > ymin ...
                & pcd.Location(:,3) < zmax ...
                & pcd.Location(:,3) > zmin); 
    
    pcd = select(pcd, pos, 'OutputSize', 'full');
    cropped_pcd = removeInvalidPoints(pcd);

    distance = 25;
    value = 0.2;
    cropped_pcd = downsample_pcd(cropped_pcd,distance,value);
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function pcd_downsampled = downsample_pcd(pcd,distance,value)

    idxNear = pcd.Location(:,2) < distance;  % Y = avanti
    ptNear = select(pcd, idxNear);
    
    % Downsample dei punti vicini considerando un solo punto per ogni cubo di
    % 0.2 di lato
    ptNearDS = pcdownsample(ptNear, 'gridAverage', value);
    
    % Punti lontani li tengo così
    idxFar = pcd.Location(:,2) >= distance;
    ptFar = select(pcd, idxFar);
    
    % Combino le due point cloud
    mergedLocs = [ptNearDS.Location; ptFar.Location];
    mergedInt = [ptNearDS.Intensity; ptFar.Intensity];
    pcd_downsampled = pointCloud(mergedLocs, 'Intensity', mergedInt);
end