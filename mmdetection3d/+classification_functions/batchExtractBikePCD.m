function batchExtractBikePCD(rootFolder)
% batchExtractBikePCD  Elabora tutte le PCD in bici_corsa e mtb
% e salva la versione con soli punti della bicicletta.
%
% INPUT:
%   rootFolder   - path alla cartella root (es. 'pcd_classification')
%
% Esempio:
%   batchExtractBikePCD('pcd_classification');

    % nomi delle due classi
    classNames = {'bici_corsa', 'mtb'};

    for ic = 1:numel(classNames)
        classDir = fullfile(rootFolder, classNames{ic});

        if ~isfolder(classDir)
            warning('Cartella non trovata: %s (salto)\n', classDir);
            continue;
        end

        % tutte le sottocartelle testXX
        testDirs = dir(fullfile(classDir, 'test*'));
        testDirs = testDirs([testDirs.isdir]);  % solo directory

        for it = 1:numel(testDirs)
            testPath = fullfile(classDir, testDirs(it).name);
            fprintf('Processo cartella: %s\n', testPath);

            % tutti i file .pcd
            pcdFiles = dir(fullfile(testPath, '*.pcd'));

            % IGNORA i file che sono già filtrati
            names = {pcdFiles.name};
            isFiltered = contains(names, '_filtered');
            pcdFiles = pcdFiles(~isFiltered);

            if isempty(pcdFiles)
                fprintf('  Nessun file .pcd non filtrato trovato in %s\n', testPath);
                continue;
            end

            for ip = 1:numel(pcdFiles)
                inFile = fullfile(testPath, pcdFiles(ip).name);
                [~, baseName, ext] = fileparts(inFile);

                % nome output: aggiungo _filtered
                outFile = fullfile(testPath, [baseName, '_filtered', ext]);

                % se esiste già, salto
                if isfile(outFile)
                    fprintf('  Esiste già, salto: %s\n', outFile);
                    continue;
                end

                fprintf('  Leggo: %s\n', inFile);
                ptCloud = pcread(inFile);

                % estrazione dei soli punti bici
                bikeCloud = get_bike_pcd(ptCloud);

                fprintf('  Scrivo: %s\n', outFile);
                pcwrite(bikeCloud, outFile);
            end
        end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function bike_pcd = get_bike_pcd(pcd)
% get_bike_pcd  Estrae i soli punti appartenenti alla bicicletta
% usando k-means su quota (Z) e intensità.
%
% INPUT:
%   pcd      - oggetto pointCloud completo (bici + rider)
%
% OUTPUT:
%   bike_pcd - oggetto pointCloud con soli punti della bicicletta

    % estraggo coordinate e quota
    P = pcd.Location;        % Nx3
    P = reshape(P, [], 3);   % nel caso fosse organizzata
    z = P(:,3);

    % intensità (se assente, metto zeri)
    I = pcd.Intensity;
    if isempty(I)
        I = zeros(size(z));
    else
        I = double(I(:));
    end

    % standardizzazione delle feature [Z, Intensity]
    zf = (z - mean(z)) / max(std(z), eps);
    If = (I - mean(I)) / max(std(I), eps);

    X = [zf, If];

    % k-means robusto / riproducibile
    rng(1);
    idx = kmeans(X, 2, 'Replicates', 5, 'MaxIter', 500, 'Start', 'plus');

    % cluster bici = quello con quota media più bassa
    muZ = [mean(z(idx == 1)), mean(z(idx == 2))];
    [~, bikeLbl] = min(muZ);

    % seleziono solo i punti bici
    bikeIdx = (idx == bikeLbl);
    bike_pcd = select(pcd, find(bikeIdx));

    % opzionale: visualizzazione di debug
    % figure;
    % pcshow(bike_pcd, "ColorSource", "Intensity", "MarkerSize", 20);
end