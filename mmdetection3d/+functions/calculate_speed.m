function [speed_array,speed_mean] = calculate_speed(pcd_list)

    % 1. Per ogni pcd trovo il centro dei punti;
    % 2. Salvo il centro in un vettore di centri "centers"
    size_list = size(pcd_list,1);
    centers = zeros(size_list, 3);

    for i = 1: size_list
        if ~isempty(pcd_list{i,1})
            centers(i, :) = find_center(pcd_list{i,1});
        end
    end

    count = 1;

    % 3. Calcolo la distanza e quindi la velocità per ogni segmento
    % 0.1s  <-> 10Hz
    % 0.05s <-> 20Hz
    f = 10; % 10Hz or 20 Hz -> è possibile usare tale valore data l'estrema precisione del sensore
    
    time_interval = 1/f;
    
    distances = zeros(size_list - 1, 1);
    speed_array = zeros(size_list - 1, 1);
    for i = 1:size_list - 1
        c1 = centers(i, :);
        if c1(1) == 0 & c1(2) == 0
            continue; % Skip to the next iteration if c1 is empty
        end
        c2 = centers(i+1, :);
        if c2(1) == 0 & c2(2) == 0
            count = count + 1;
            continue;
        end
        count = 1;
        distances(i) = norm(centers(i+1, :) - centers(i, :));

        speed_array(i) = distances(i)/(time_interval*count);
        speed_array(i) = speed_array(i) * 3.66;

    end
    speed_mean = mean(speed_array);
    % 4. Calcolo velocità media
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