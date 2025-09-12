function results = process_json_folder(path)
    jsonPath = path + "/json";
    if ~isfolder(jsonPath)
        error('La cartella non esiste: %s', path);
    end

    jsonFiles = dir(fullfile(path, '*.json'));

    if isempty(jsonFiles)
        warning('Nessun file JSON trovato in %s', path);
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
        jsonPath = fullfile(path, jsonFiles(k).name);

        % Estrazione info da singolo json
        [boxes, labels, scores] = functions.get_bb(jsonPath);

        % Inserisci nei campi della struct
        results(k).fileName = jsonFiles(k).name;
        results(k).boxes    = boxes;
        results(k).labels   = labels;
        results(k).scores   = scores;
    end
end