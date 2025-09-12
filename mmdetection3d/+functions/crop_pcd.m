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



