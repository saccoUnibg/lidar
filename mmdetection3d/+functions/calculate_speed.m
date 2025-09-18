function speed_data = calculate_speed(pcd_list)
    % 1. Per ogni pcd trovo il centro dei punti;
    % 2. Salvo il centro in un vettore di centri
    % 3. Calcolo la distanza e quindi la velocità per ogni segmento
    % 4. Calcolo velocità media
    
    size_list = size(pcd_list,1);
    centers = zeros(size_list, 3); % Preallocate for centers
    
    for i = 1: size_list
        if ~isempty(pcd_list{i,1})
            centers(i, :) = find_center(pcd_list{i,1});
        end
    end
    
    speed_data = 1;
    disp("Speed data: --- OK ---")
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function c = find_center(ptCloud)
    
    numPoints = size(ptCloud.Location(),1);
    x_sum = 0;
    y_sum = 0;
    z_sum = 0;


    for i = 1 : numPoints
        x_sum = x_sum + ptCloud.Location(i,1);
        y_sum = y_sum + ptCloud.Location(i,2);
        z_sum = z_sum + ptCloud.Location(i,3);
    end

    x_mean = x_sum/numPoints;
    y_mean = y_sum/numPoints;
    z_mean = z_sum/numPoints;

    c = [x_mean y_mean z_mean];
end