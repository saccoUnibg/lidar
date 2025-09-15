function results = process_json_folder(path)
    jsonPath = path + "/3_json/preds";
    if ~isfolder(jsonPath)
        error('La cartella non esiste: %s', jsonPath);
    end

    jsonFiles = dir(fullfile(jsonPath, '*.json'));

    if isempty(jsonFiles)
        warning('Nessun file JSON trovato in %s', jsonPath);
        results = [];
        return;
    end

    % Array vuoto
    results(numel(jsonFiles)) = struct( ...
        'fileName', '', ...
        'boxes',    [], ...
        'labels',   [], ...
        'scores',   []);

    for k = 1:numel(jsonFiles)
        jsonFile = fullfile(jsonPath, jsonFiles(k).name);

        % Estrazione info da singolo json
        [boxes, labels, scores] = functions.get_results(jsonFile);

        % Inserisci nei campi della struct
        results(k).fileName = jsonFiles(k).name;
        results(k).boxes    = boxes;
        results(k).labels   = labels;
        results(k).scores   = scores;
    end
end