function show_results(path,results,threshold,lim)
    disp("Show results: --- Start ---")
    pcdPath = path + "/1_pcd";
    bboxes_all = {results.boxes}';
    scores_all = {results.scores}';
    % labels_all = {results.labels}';


    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    reset(lidarData);
    numFiles = size(lidarData.Files,1) - lim;
    for i = 1 : numFiles
        ptCloud = read(lidarData);
        B = bboxes_all{i};   % Nx7
        S = scores_all{i};   % Nx1
        % L = labels_all{i};

        % Filtro per results con detection su pcd, skip altrimenti
        if ~isempty(S) & S > threshold
            S = S(1, :);
        else
            continue
        end
        
        % Filtro per soglia
        if S>threshold
            B = B(1, :);
        else
            continue
        end
        showPcdWith3dBoxes(ptCloud, B,S,i);
    end
    disp("Show results: --- OK ---")
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function showPcdWith3dBoxes(pcd, B,S,iter)

    % --- plot pcd
    figure; pcshow(pcd,"ColorSource","Intensity"); hold on; axis equal; grid on;
    xlabel X; ylabel Y; zlabel Z; title(sprintf('Point cloud con bounding boxes: %d',iter));
    
    % --- disegna box filtrate
    for i = 1:size(B,1)

        c   = B(1:3);
        d   = B(4:6);
        yaw = B(7);
        
        C = orientedBBoxCorners(c, d, yaw);
        drawBox(C, [1 0 0], 1.5);
        % punto sopra la box (sul centro, sopra l'asse z)

        pos = c + [0 0 d(3)/2 + 1.5];  % 0.2 = offset per non sovrapporsi
        
        % scritta sopra la box
        bounding_box_name = "Cyclist: " + num2str(S);
        text(pos(1), pos(2), pos(3), bounding_box_name, ...
             'Color','red','FontSize',13, ...
             'FontWeight','bold', 'HorizontalAlignment','center');
        iter = iter + 1;
    end
    hold off;
    set(gcf,'color','w');
    set(gca,'color','w');
    set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function C = orientedBBoxCorners(center, dims, yaw)
    % center: [cx cy cz], dims: [dx dy dz] (lunghezze lato), yaw rad (intorno a Z)

    dx = dims(1)/2; dy = dims(2)/2; dz = dims(3)/2;

    local = [ ...
        -dx -dy -dz;
         dx -dy -dz;
         dx  dy -dz;
        -dx  dy -dz;
        -dx -dy  dz;
         dx -dy  dz;
         dx  dy  dz;
        -dx  dy  dz];
    Rz = [  cos(yaw) -sin(yaw)  0;
            sin(yaw) cos(yaw)   0; 
            0           0       1];

    C = (local * Rz.') + center; % 8x3
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function drawBox(C, color, lw)
    % C: 8x3 corner coordinates nell'ordine definito sopra
    edges = [1 2; 2 3; 3 4; 4 1; 5 6; 6 7; 7 8; 8 5; 1 5; 2 6; 3 7; 4 8];
    for e = 1:size(edges,1)
        p = C(edges(e,1),:); q = C(edges(e,2),:);
        line([p(1) q(1)],[p(2) q(2)],[p(3) q(3)], 'Color', color, 'LineWidth', lw);
    end
end
