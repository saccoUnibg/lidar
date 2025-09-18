function results_filtered = filter_cyclist(results,model)
    
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
    for i = 1:length(bboxes_all)
        B = bboxes_all{i};
        if ~isempty(B)
            B = B(1,:);
            x_new = B(5);
            y_new = B(4);
            B(4) = x_new;
            B(5) = y_new;

            results_filtered(i).boxes = B;
        else
            continue
        end
    end
end
    disp("Filter cyclist: --- OK ---")
end