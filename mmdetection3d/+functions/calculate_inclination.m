function ground_equation_list = calculate_inclination(path, results_filtered, pcd_list)
    
    % 1. segmentazione punti del terreno
    ground_list = segment_ground(path);

    % 2. Filtro punti terreno appartenenti alla sola bounding box
    pcd_ground_list_filtered = filter_ground_points(ground_list,results_filtered);

    % 3. Calcolo equazione piano terreno
    ground_equation_list = get_ground_equation(pcd_ground_list_filtered);

    % 4. Calcolo equazione piano passante per punti bicicletta
    bike_equation_list = get_bike_equation(pcd_list);
    plot_pcd_ground(ground_equation_list,pcd_list);
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
%  ---- 3b: creazione funzione obiettivo ----
function f = funzione_obiettivo(theta, x, y, z)
    z_hat = theta(1)*x + theta(2)*y + theta(3);

    r = z - z_hat;

    f = sqrt(mean(r.^2));
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

        obj = @(theta) funzione_obiettivo(theta, x, y, z);
        
        theta0 = double([0; 0; 0]); % punto iniziale da cui partire per l'ottimizzazione
        theta_ottimi = fmincon(obj,theta0);
        bike_equation_list(i,:) = theta_ottimi;
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%  ---- Extra ----
% Plot esempio
function plot_pcd_ground(ground_equation_list,pcd_list)
    close all;
    for i = 1 : size(pcd_list,1)
        figure(i)
        pcd = pcd_list{i};
        pts = pcd.Location();
        pcshow(pcd,"ColorSource","Intensity");
        hold on;
        % piano terreno
        vector1 = ground_equation_list(i,:);
        a = vector1(1); b = vector1(2); c = vector1(3);
        xrange = linspace(min(pts(:,1)), max(pts(:,1)) , 20);
        yrange = linspace(min(pts(:,2)), max(pts(:,2)), 20);
        
        [xg, yg] = meshgrid(xrange, yrange);
        zg = a*xg + b*yg + c;
        
        surf(xg, yg, zg, 'FaceAlpha',0.8, 'EdgeColor','none');
        colormap parula
        xlabel('X'); ylabel('Y'); zlabel('Z');
        title(sprintf('Bici + piano: (i: %d)',i));
        grid on; view(3);
        % piano bicicletta



    end
end