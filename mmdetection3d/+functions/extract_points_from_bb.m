function [pcd_list, pcd_traiettoria,center_list] = extract_points_from_bb(path,results)
    
    disp("Extract points from BB: --- Start ---")

    pcdPath = path + "/0_original";
    bboxes_all = {results.boxes}';
    scores_all = {results.scores}';

    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    reset(lidarData);
    numFiles = size(lidarData.Files,1);
    pcd_list = cell(numFiles,1);
    center_list = zeros(numFiles,3);

    allPts = [];
    allIntensities = [];
    for i = 1:numFiles
        
        ptCloud = read(lidarData);
        elevation_threshold = 0.05; % 5cm da terra
        ptCloud = removeInvalidPoints(ptCloud);
        [~,ptCloud,~] = segmentGroundSMRF(ptCloud,2,"ElevationThreshold",elevation_threshold);


        if i == 1
            allPts = [allPts; ptCloud.Location()];
            allIntensities = [allIntensities; ptCloud.Intensity()];
        end
        B = bboxes_all{i};   % Nx7
        S = scores_all{i};  % Extract scores for the current bounding box
        if ~isempty(B)
            B = B(1, :);
        else
            continue
        end

        % estraggo point cloud punti dentro bb
        pcIn = pointsInOrientedBox(ptCloud,B);
        pcd_list{i} = pcIn;
        center_list(i,1) = B(1);
        center_list(i,2) = B(2);
        center_list(i,3) = B(3);

        % Estrazione traiettoria
        if mod(i,4) == 0
            allPts = [allPts; pcIn.Location()];
            allIntensities = [allIntensities;pcIn.Intensity()];
        end
        
    end
    pcd_traiettoria = pointCloud(allPts,"Intensity",allIntensities);
    
    disp("Extract points from BB: --- OK ---")
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function pcInside = pointsInOrientedBox(pcIn, box)
    % --- parse box ---
    cx = box(1); cy = box(2); cz = box(3);
    sx = box(4); sy = box(5); sz = box(6);
    yaw = box(7);

    C = [cx; cy; cz];
    halfSizes = [sx; sy; sz] / 2;

    % rotazione attorno a Z
    c = cos(yaw); s = sin(yaw);
    R = [ c -s  0;
          s  c  0;
          0  0  1];

    % estrai punti XYZ
    Pxyz = pcIn.Location;

    % porta i punti nel frame della box
    Plocal = (R.' * (Pxyz.' - C)).';

    % test AABB nel frame locale
    idxInside = abs(Plocal(:,1)) <= halfSizes(1) + 0.25 & ...
                abs(Plocal(:,2)) <= halfSizes(2) + 0.25 & ...
                abs(Plocal(:,3)) <= halfSizes(3) + 0.5;

    % seleziona subset
    Psel = Pxyz(idxInside, :);

    Isel = pcIn.Intensity(idxInside);
    pcInside = pointCloud(Psel, 'Intensity', Isel);

end

