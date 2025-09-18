function [pcd_list, pcd_traiettoria] = extract_points_from_bb(path,results)
    

    pcdPath = path + "/1_pcd";
    bboxes_all = {results.boxes}';
    scores_all = {results.scores}';

    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    reset(lidarData);
    numFiles = size(lidarData.Files,1);
    pcd_list = cell(numFiles,1);

    allPts = [];
    allIntensities = [];
    for i = 1:numFiles
        
        ptCloud = read(lidarData);
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

        % Estrazione traiettoria
        if mod(i,3) == 0
            allPts = [allPts; pcIn.Location()];
            allIntensities = [allIntensities;pcIn.Intensity()];
        end
        
    end
    pcd_traiettoria = pointCloud(allPts,"Intensity",allIntensities);
    
    disp("Show results: --- OK ---")
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
                abs(Plocal(:,3)) <= halfSizes(3) + 1;

    % seleziona subset
    Psel = Pxyz(idxInside, :);

    Isel = pcIn.Intensity(idxInside);
    pcInside = pointCloud(Psel, 'Intensity', Isel);

end

