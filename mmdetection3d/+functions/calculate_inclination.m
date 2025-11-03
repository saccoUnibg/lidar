function [ground_equation_list, bike_equation_list, angle_list] = calculate_inclination(path, results_filtered, pcd_list)
    disp("Calculate inclination: --- Start ---");

    % 1. Segmentazione punti del terreno
    ground_list = segment_ground(path);

    % 2. Filtro punti terreno appartenenti alla sola bounding box
    pcd_ground_list_filtered = filter_ground_points(ground_list,results_filtered);

    % 3. Calcolo equazione piano terreno
    ground_equation_list = get_ground_equation(pcd_ground_list_filtered);

    % 4. Calcolo equazione piano passante per punti bicicletta
    bike_equation_list = get_bike_equation(pcd_list);

    % 5. Calcolo angolo tra piani
    angle_list = evaluate_angle(ground_equation_list,bike_equation_list);

    %plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list,angle_list);
    %plot_pcd_ground_sequence(ground_equation_list,bike_equation_list,pcd_list,angle_list);


    disp("Calculate inclination: --- OK ---");
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 1. Segmentazione punti del terreno ----
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
%  ---- 2. Filtro punti terreno appartenenti alla sola bounding box ----
function pcd_ground_list_filtered = filter_ground_points(ground_list,results_filtered)

    numFiles = size(results_filtered,2);
    pcd_ground_list_filtered = cell(numFiles,1);

    for i = 1 : numFiles
        B = results_filtered(i).boxes;
        if ~isempty(B)
                % --- parse box ---
            cx = B(1); cy = B(2); cz = B(3);
    
            sx = B(4)*(1+0.1); % allargo 10% la bb
            sy = B(5)*(1+0.1);
            sz = B(6)*(1+0.1);
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
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 3. Calcolo equazione piano terreno ----
function ground_equation_list = get_ground_equation(pcd_ground_list_filtered)
    numFiles = size(pcd_ground_list_filtered,1);
    ground_equation_list = zeros(numFiles,4); % ogni equazione ha 3 parametri
    for i = 1 : numFiles
        ptCloud = pcd_ground_list_filtered{i};
        if ~isempty(ptCloud)
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
            % trasformo equazione da esplicita a implicita
            ground_equation_list(i,1) = theta_ottimi(1);
            ground_equation_list(i,2) = theta_ottimi(2);
            ground_equation_list(i,3) = -1;
            ground_equation_list(i,4) = theta_ottimi(3);
        end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 4. Calcolo equazione piano passante per punti bicicletta ----
function bike_equation_list = get_bike_equation(pcd_list)
    
    numFiles = size(pcd_list,1);
    bike_equation_list = zeros(numFiles,4); % ogni equazione ha 3 parametri
    for i = 1 : numFiles
        pcd = pcd_list{i};
        % points = pcd.Location;
        if ~isempty(pcd)
            figure(i);
            pcshow(pcd,"ColorSource","Intensity");
            bike_pcd = get_bike_pcd(pcd);
            
            maxDistance = 0.1;
            [model, ~, ~] = pcfitplane(bike_pcd, maxDistance);
            
            % model.Normal      -> [a b c]
            % model.Parameters  -> [a b c d] dell'equazione ax+by+cz+d=0
            abcd = model.Parameters;
    
            bike_equation_list(i,:) = abcd;
        else
            bike_equation_list(i,:) = [0 0 0 0];
        end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- 5. Calcolo angolo tra piani ----
function angle_list = evaluate_angle(ground_equation_list,bike_equation_list)
        numFiles = size(ground_equation_list,1);
        angle_list = zeros(numFiles,1);
        for i = 1 : numFiles
            abcd_g = ground_equation_list(i,1:3);
            abcd_b = bike_equation_list(i,1:3);

            ng = abcd_g / norm(abcd_g);
            nb = abcd_b / norm(abcd_b);

            alpha = atan2d(norm(cross(ng, nb)), abs(dot(ng, nb)));  % angolo tra le normali
            theta = 90 - alpha; 
            angle_list(i) = theta;
        end
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra: creazione funzione obiettivo ----
function f = funzione_obiettivo(theta, x, y, z)
    z_hat = theta(1)*x + theta(2)*y + theta(3);

    r = z - z_hat;

    f = sqrt(mean(r.^2));
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra: segmentazione bici vs ciclista tramite intensità point cloud ----

function bike_pcd = get_bike_pcd(pcd)
% Restituisce:
%   bike_pcd  : pointCloud con soli punti bici
%   idx_remap : vettore Nx1 con etichette {1=bici, 2=rider} stabili

    P = pcd.Location;                % Nx3 (non organizzata)
    z = P(:,3);

    I = pcd.Intensity;
    if isempty(I), I = zeros(size(z)); end
    I = double(I(:));

    % Feature: [Z, Intensity] standardizzate
    zf = (z - mean(z)) / std(z);
    If = (I - mean(I)) / max(std(I), eps);
    X = [zf, If];

    % k-means con risultato riproducibile
    rng(1);
    idx = kmeans(X, 2, 'Replicates', 5, 'MaxIter', 500, 'Start', 'plus');

    % Decidi quale cluster è la bici: quello con Z media più bassa
    muZ = [mean(z(idx==1)), mean(z(idx==2))];
    [~, bikeLbl] = min(muZ);

    % RIMAPPA: bici -> 1, rider -> 2 (etichette stabili)
    idx_remap = ones(size(idx));
    idx_remap(idx ~= bikeLbl) = 2;

    % Seleziona la bici
    bike_pcd = select(pcd, find(idx_remap == 1));
    % figure;
    % pcshow(bike_pcd,"ColorSource","Intensity","MarkerSize",20);

end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra: plot singola pcd con piani ----
function plot_pcd_ground_single(ground_equation_list, bike_equation_list, pcd_list,angle_list)

    for i = 1 : size(pcd_list,1)
        pcd = pcd_list{i};
        if ~isempty(pcd)
            figure(i); clf;
            
            pts = pcd.Location();
    
            % nuvola di punti
            pcshow(pcd, "ColorSource", "Intensity");
            hold on;
            % griglia comune per entrambi i piani (copre l'estensione dei punti)
            xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
            yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
            [xg, yg] = meshgrid(xrange, yrange);
    
            % ===== piano terreno: a*x + b*y + c*z + d = 0 =====
            g = ground_equation_list(i,:);
            a1 = g(1); b1 = g(2); c1 = g(3); d1 = g(4);
            zg = -(a1*xg + b1*yg + d1) / c1;
            % zg = a1*xg + b1*yg + c1;
    
            hGround = surf(xg, yg, zg, ...
                'FaceAlpha', 0.55, ...
                'EdgeColor','none', ...
                'FaceColor', [0.20 0.70 0.30]);   % verde
    
            % ===== piano bici: ax + by + cz + d = 0 =====
            bq = bike_equation_list(i,:);
    
            a = bq(1); b = bq(2); c = bq(3); d = bq(4);
        
            epsC = 1e-12;
            if abs(c) < epsC
                % niente plot per piani quasi verticali (eviti divisione per zero)
                hBike = [];
            else
                zb = -(a*xg + b*yg + d) / c;
    
                hBike = surf(xg, yg, zb, ...
                    'FaceAlpha', 0.45, ...
                    'EdgeColor','none', ...
                    'FaceColor',[0.85 0.33 0.10]);
            end
    
            xlabel('X'); ylabel('Y'); zlabel('Z');
            title(sprintf('Piani terreno & bici + PCD (i = %d)\n angle: %.2f', i, angle_list(i)));
            grid on; view(3); axis tight; daspect([1 1 1]);

            zlim([min(pts(:,3))-0.5 max(pts(:,3))+0.5]);
            L = ["Terreno","Bici"];
            H = [hGround, hBike];
            H = H(~arrayfun(@isempty,H));
            L = L(1:numel(H));
            % if ~isempty(H), legend(H, L, 'Location','best'); end
        end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra: plot sequenza ----
function plot_pcd_ground_sequence(ground_equation_list, bike_equation_list, pcd_list,angle_list)
    z_minimo = 999;
    z_massimo = -999;
    for i = 1 : size(pcd_list,1)
        pcd = pcd_list{i};
        if ~isempty(pcd)

            pts = pcd.Location();
    
            % nuvola di punti
            pcshow(pcd, "ColorSource", "Intensity");
            hold on;
    
            % griglia comune per entrambi i piani (copre l'estensione dei punti)
            xrange = linspace(min(pts(:,1)), max(pts(:,1)), 20);
            yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
            [xg, yg] = meshgrid(xrange, yrange);
    
            % ===== piano terreno: a*x + b*y + c*z + d = 0 =====
            g = ground_equation_list(i,:);
            a1 = g(1); b1 = g(2); c1 = g(3); d1 = g(4);
            zg = -(a1*xg + b1*yg + d1) / c1;
            % zg = a1*xg + b1*yg + c1;
    
            hGround = surf(xg, yg, zg, ...
                'FaceAlpha', 0.55, ...
                'EdgeColor','none', ...
                'FaceColor', [0.20 0.70 0.30]);   % verde
    
            % ===== piano bici: ax + by + cz + d = 0 =====
            bq = bike_equation_list(i,:);
    
            a = bq(1); b = bq(2); c = bq(3); d = bq(4);
        
            epsC = 1e-12;
            if abs(c) < epsC
                % niente plot per piani quasi verticali (eviti divisione per zero)
                hBike = [];
            else
                zb = -(a*xg + b*yg + d) / c;
    
                hBike = surf(xg, yg, zb, ...
                    'FaceAlpha', 0.45, ...
                    'EdgeColor','none', ...
                    'FaceColor',[0.85 0.33 0.10]);
            end
    
            xlabel('X'); ylabel('Y'); zlabel('Z');
            title(sprintf('Piani terreno & bici + PCD (i = %d)\n angle: %.2f', i, angle_list(i)));
            grid on; view(3); axis tight; daspect([1 1 1]);
    
            z_minimo = min(z_minimo,min(pts(:,3)) - 0.5);
            z_massimo = max(z_massimo,max(pts(:,3)) + 0.5);

            zlim([z_minimo z_massimo]);
            L = ["Terreno","Bici"];
            H = [hGround, hBike];
            H = H(~arrayfun(@isempty,H));
            L = L(1:numel(H));
            if ~isempty(H), legend(H, L, 'Location','best'); end
        end
    end
    
    zlim([z_minimo z_massimo]);

end