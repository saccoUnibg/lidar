function results_filtered = filter_cyclist(results)
    
results_filtered = results; % copia la struct

for i = 1:length(results)
    ind = results(i).labels == 1;
    results_filtered(i).boxes = results(i).boxes(ind, :);
    results_filtered(i).scores = results(i).scores(ind);
    results_filtered(i).labels = results(i).labels(ind);
end

    disp("Filter cyclist: --- OK ---")
end