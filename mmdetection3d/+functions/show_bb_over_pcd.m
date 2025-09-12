function show_bb_over_pcd(jsonFile, pointCloudFile,threshold)
% SHOW_MMDET3D_BOXES Visualizza le bounding box 3D dal JSON di MMDetection3D
% jsonFile: path al JSON con campi labels_3d, scores_3d, bboxes_3d
% pointCloudFile: path a .pcd o .bin (KITTI) opzionale (puoi passare "" per non caricare)
% classNames: cell array di nomi classe (ordine come nel config), es: {'Car','Pedestrian','Cyclist'}
classNames = {'Pedestrian','Cyclist','Car'};

% --- 1) Carica predizioni ---
raw = jsondecode(fileread(jsonFile));
labels = raw.labels_3d(:);
scores = raw.scores_3d(:);
boxes  = raw.bboxes_3d;  % Nx7: [x y z dx dy dz yaw]

% --- 2) Mostra il point cloud, se fornito ---
clf; hold on; axis equal; grid on;
pcshow(pointCloudFile,"ColorSource","Intensity");
hold on;
title('MMDetection3D predictions'); xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);

% --- 3) Colori per classe ---
C = lines(max(3, numel(classNames))); % tavolozza base

% --- 4) Disegna ogni box con colore per classe e etichetta/score ---
n = size(boxes,1);
for i = 1:n
    if scores(i) < threshold
        continue;
    end
    clsId = labels(i) + 1; % JSON usa 0-based; MATLAB è 1-based
    if clsId < 1 || clsId > numel(classNames)
        clsName = sprintf('cls%d', clsId-1);
        col = [0 0 0];
    else
        clsName = classNames{clsId};
        col = C(mod(clsId-1, size(C,1))+1, :);
    end

    b = boxes(i,:); % [x y z dx dy dz yaw]
    corners = orientedBoxCorners(b);
    drawBoxEdges(corners, col, 1.5);

    % Etichetta (classe e score) vicino al centro box
    text(b(1), b(2), b(3), sprintf('%s (%.2f)', clsName, scores(i)), ...
        'Color', col, 'FontWeight','bold', 'HorizontalAlignment','center');
end

hold off;

end

% ===== helpers =====

function corners = orientedBoxCorners(b)
% b = [x y z dx dy dz yaw], yaw attorno a Z (radianti)
x=b(1); y=b(2); z=b(3);
dx=b(4); dy=b(5); dz=b(6);
yaw=b(7);

% vertici in frame locale (8x3)
hx=dx/2; hy=dy/2; hz=dz/2;
local = [ ...
   hx,  hy,  hz;
   hx,  hy, -hz;
   hx, -hy, -hz;
   hx, -hy,  hz;
  -hx,  hy,  hz;
  -hx,  hy, -hz;
  -hx, -hy, -hz;
  -hx, -hy,  hz];

% rotazione attorno a Z
R = [cos(yaw) -sin(yaw) 0;
     sin(yaw)  cos(yaw) 0;
     0         0        1];

corners = (R * local')' + [x y z];
end

function drawBoxEdges(corners, col, lw)
% Disegna le 12 spigoli del cubo orientato
edges = [1 2; 2 3; 3 4; 4 1;  ... % top/bottom dipende dall'ordinamento; va bene così per visualizzare
         5 6; 6 7; 7 8; 8 5;
         1 5; 2 6; 3 7; 4 8];
for e = 1:size(edges,1)
    p1 = corners(edges(e,1),:);
    p2 = corners(edges(e,2),:);
    plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], '-', 'Color', col, 'LineWidth', lw);
end
end