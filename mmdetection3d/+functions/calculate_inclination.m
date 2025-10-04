function ground_equation_list = calculate_inclination(path, results_filtered, pcd_list)
    
    % 1. segmentazione punti del terreno
    ground_list = segment_ground(path);

    % 2. Filtro punti terreno appartenenti alla sola bounding box
    pcd_ground_list_filtered = filter_ground_points(ground_list,results_filtered);

    % 3. Calcolo equazione piano terreno
    ground_equation_list = get_ground_equation(pcd_ground_list_filtered);

    % 4. Calcolo equazione piano passante per punti bicicletta
    bike_equation_list = get_bike_equation(pcd_list);
    plot_pcd_ground(ground_equation_list,bike_equation_list,pcd_list);
    % 5. Calcolo angolo tra piani

    disp("Calculate inclination: --- OK ---");
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%  ---- 1 ----
function pcd_ground_list = segment_ground(path)
    
    pcdPath = path + "/0_original";

    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    reset(lidarData);
    numFiles = size(lidarData.Files,1);
    pcd_ground_list = cell(numFiles,1);

    for i = 1:numFiles
        
        ptCloud = read(lidarData);
        elevation_threshold = 0.05; % 5cm da terra
        ptCloud = removeInvalidPoints(ptCloud);
        [~,~,ptCloudGround] = segmentGroundSMRF(ptCloud,2,"ElevationThreshold",elevation_threshold);
        pcd_ground_list{i} = ptCloudGround;
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 2 ----
function pcd_ground_list_filtered = filter_ground_points(ground_list,results_filtered)

    numFiles = size(results_filtered,2);
    pcd_ground_list_filtered = cell(numFiles,1);

    for i = 1 : numFiles
        B = results_filtered(i).boxes;
            % --- parse box ---
        cx = B(1); cy = B(2); cz = B(3);
        sx = B(4); sy = B(5); sz = B(6);
        yaw = B(7);
    
        C = [cx; cy; cz];
        halfSizes = [sx; sy; sz] / 2;
    
        % rotazione attorno a Z
        c = cos(yaw); s = sin(yaw);
        R = [ c -s  0;
              s  c  0;
              0  0  1];
        
        pcIn = ground_list{i};

        % estrai punti XYZ
        Pxyz = pcIn.Location;
    
        % porta i punti nel frame della box
        Plocal = (R.' * (Pxyz.' - C)).';
    
        % test AABB nel frame locale
        idxInside = abs(Plocal(:,1)) <= halfSizes(1) + 1 & ...
                    abs(Plocal(:,2)) <= halfSizes(2) + 1 & ...
                    abs(Plocal(:,3)) <= halfSizes(3) + 3;
    
        % seleziona subset
        Psel = Pxyz(idxInside, :);
    
        Isel = pcIn.Intensity(idxInside);
        pcInside = pointCloud(Psel, 'Intensity', Isel);
        pcd_ground_list_filtered{i} = pcInside;
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 3 ----

function ground_equation_list = get_ground_equation(pcd_ground_list_filtered)
    numFiles = size(pcd_ground_list_filtered,1);
    ground_equation_list = zeros(numFiles,3); % ogni equazione ha 3 parametri
    for i = 1 : numFiles
        ptCloud = pcd_ground_list_filtered{i};
        pts = ptCloud.Location();
        
        % z = ax + by + c -> devo stimare a, b, c
        % creo una funzione di costo, che valuto con RMSE come differenza
        % tra z_hat stimato e z reale
        % --> io voglio andare a minimizzare la differenza tra questi due
        % valori, e' un processo di ottimizzazione come quelli visti in MAO
        
        x = pts(:,1); y = pts(:,2); z = pts(:,3);

        x = double(x);
        y = double(y);
        z = double(z);

        obj = @(theta) funzione_obiettivo(theta, x, y, z);
        
        theta0 = double([0; 0; 0]); % punto iniziale da cui partire per l'ottimizzazione
        theta_ottimi = fmincon(obj,theta0);
        ground_equation_list(i,:) = theta_ottimi;
    end

end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 4 ----
function bike_equation_list = get_bike_equation(pcd_list)
    
    numFiles = size(pcd_list,1);
    bike_equation_list = zeros(numFiles,3); % ogni equazione ha 3 parametri
    for i = 1 : numFiles
        pcd = pcd_list{i};
        pts = pcd.Location();
        x = pts(:,1); y = pts(:,2); z = pts(:,3);

        x = double(x);
        y = double(y);
        z = double(z);

        obj = @(theta) funzione_obiettivo(theta, x,y,z);
        
        theta0 = double([0; 0; 0]); % punto iniziale da cui partire per l'ottimizzazione
        theta_ottimi = fmincon(obj,theta0);
        bike_equation_list(i,:) = theta_ottimi;
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- creazione funzione obiettivo ----
function f = funzione_obiettivo(theta, x, y, z)
    z_hat = theta(1)*x + theta(2)*y + theta(3);

    r = z - z_hat;

    f = sqrt(mean(r.^2));
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra ----
% Plot esempio
function plot_pcd_ground(ground_equation_list, bike_equation_list, pcd_list)
    close all;
    for i = 1 : size(pcd_list,1)   % se pcd_list è cella colonna; altrimenti usa numel(pcd_list)
        figure(i); clf;
        pcd = pcd_list{i};
        pts = pcd.Location();

        % nuvola di punti
        pcshow(pcd, "ColorSource", "Intensity");
        hold on;

        % griglia comune per entrambi i piani (copre l'estensione dei punti)
        xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
        yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
        [xg, yg] = meshgrid(xrange, yrange);

        % ===== piano terreno: z = a*x + b*y + c =====
        g = ground_equation_list(i,:);
        a1 = g(1); b1 = g(2); c1 = g(3);
        zg = a1*xg + b1*yg + c1;

        hGround = surf(xg, yg, zg, ...
            'FaceAlpha', 0.55, ...
            'EdgeColor','none', ...
            'FaceColor', [0.20 0.70 0.30]);   % verde

        % ===== piano bici: z = a*x + b*y + c =====
        bq = bike_equation_list(i,:);
        if all(isfinite(bq)) && numel(bq) >= 3
            a2 = bq(1); b2 = bq(2); c2 = bq(3);
            zb = a2*xg + b2*yg + c2;

            hBike = surf(xg, yg, zb, ...
                'FaceAlpha', 0.45, ...
                'EdgeColor','none', ...
                'FaceColor', [0.85 0.33 0.10]);  % arancio/rosso
        else
            hBike = [];   % niente piano bici in questo frame
        end

        % estetica
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title(sprintf('Piani terreno & bici + PCD (i = %d)', i));
        grid on; view(3); axis tight; daspect([1 1 1]);

        % legenda (mostra solo gli handle validi)
        L = ["Terreno","Bici"];
        H = [hGround, hBike];
        H = H(~arrayfun(@isempty,H));     % rimuove vuoti
        L = L(1:numel(H));
        if ~isempty(H), legend(H, L, 'Location','best'); end
    end
end