function results_filtered = filter_cyclist(results,model,threshold)
    disp("Filter cyclist: --- Start ---")

    results_filtered = results; % copia la struct
    
    for i = 1:length(results)
        ind = results(i).labels == 1;
        results_filtered(i).boxes = results(i).boxes(ind, :);
        results_filtered(i).scores = results(i).scores(ind);
        results_filtered(i).labels = results(i).labels(ind);
    end
    
    % invert x and y of bb
    if strcmp(model,"second")
        bboxes_all = {results_filtered.boxes}';
        scores_all = {results_filtered.scores}';
        labels_all = {results_filtered.labels}';
        
        B_previous = zeros(7,1);

        for i = 1:length(bboxes_all)
            
            B = bboxes_all{i};
            S = scores_all{i};
            L = labels_all{i};
    
            if ~isempty(B)
                B = B(1,:);
                S = S(1,:);
                L = L(1,:);
                
                B(3)= B(3) + 1.7/2; % altezza sensore per db KITTI
                % Si, lo so, basta una variabile sola per fare swap, ma
                % cosi' e' piu' chiara
                x_new = B(5);
                y_new = B(4);
                B(4) = x_new;
                B(5) = y_new;

                B(7) = - B(7);

                if i>1 && abs(B_previous(4) - B(5)) < 0.2 && ~isempty(B_previous)
                    x_new = B(5);
                    y_new = B(4);
                    B(4) = x_new;
                    B(5) = y_new;
                end

                B_previous = B;
                
                results_filtered(i).boxes = B;
                results_filtered(i).scores = S;
                results_filtered(i).labels = L;
                
            else
                continue
            end
        end
    end
    % Normalizzo yaw
    results_filtered = normalize_yaw(results_filtered);
    
    % elimino righe per cui scores e' inferiore alla threshold
    % Eliminate entries with scores below the threshold
        for i = length(results_filtered):-1:1
            if results_filtered(i).scores < threshold
                results_filtered(i).boxes = []; % Remove entry
                results_filtered(i).labels = []; % Remove entry
                results_filtered(i).scores = []; % Remove entry

            end
        end

    disp("Filter cyclist: --- OK ---")
end
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results_filtered = normalize_yaw(results_filtered)

    % 1. Estraggo valori in gradi e li plotto per vedere incongruenze
    boxes_list = {results_filtered.boxes}';

    vector_size = size(boxes_list,1);
    yaw_list = zeros(vector_size,1); % Initialize yaw_list
    
    for i = 1 : vector_size
        if ~isempty(boxes_list{i})
   
            yaw_value_deg = rad2deg(boxes_list{i}(1,7));
            yaw_list(i,1) = yaw_value_deg;  % deg

        end
    end
    plot(yaw_list(:,1))

    % 2. Applico normalizzazione e plotto per vedere differenza con quello
    % precedente

    yaw_prev = 0;
    
    for i = 1:size(yaw_list,1)
        yaw_temp = yaw_list(i,1);
    
        if yaw_temp == 0
            continue;  % salta se è zero
        end
    
        if yaw_prev == 0
            yaw_prev = yaw_temp;  % primo valore valido
            continue;
        end
    
        diff = yaw_prev - yaw_temp;
    
        if diff < -90
            yaw_temp = yaw_temp - 180;
        elseif diff > 90
            yaw_temp = yaw_temp + 180;
        end
    
        yaw_list(i,1) = yaw_temp;
        yaw_prev = yaw_temp;
    end
    
    hold on;
    plot(yaw_list(:,1))

    legend("Non normalizzata","Normalizzata")
    % 3. Inserisco dentro risultato il valore corretto in rad
    for i = 1:size(yaw_list,1)
        if ~isempty(boxes_list{i})
            results_filtered(i).boxes(1,7) = deg2rad(yaw_list(i,1)); % Convert to radians
        end
    end


end