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