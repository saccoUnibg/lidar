function [X, y, featureNames, info] = estraiFeaturePCD(rootDir)
% ESTRAIFEATUREPCD Estrae feature da tutte le PCD *_bike nel dataset
%
%   [X, y, featureNames, info] = classification_functions.estraiFeaturePCD(rootDir)
%
% INPUT:
%   rootDir   - cartella radice del dataset, es:
%               'pcd_classification'
%
% OUTPUT:
%   X             - matrice (nCampioni x nFeature)
%   y             - vettore etichette (categorical) con valori
%                   'bici_corsa' o 'mtb'
%   featureNames  - cell array di nomi delle feature (1 x nFeature)
%   info          - struct array con informazioni su ogni campione
%                   (classe, testFolder, fileName, fullPath)
%
% NOTA:
%   Considera SOLO i file che terminano con *_bike.pcd

    if nargin < 1
        rootDir = 'pcd_classification';
    end

    % nomi delle classi (devono corrispondere alle sottocartelle)
    classi = {'bici_corsa', 'mtb'};

    % inizializzazione container
    X = [];
    y = categorical([]);
    info = struct( ...
        'classe', {}, ...
        'testFolder', {}, ...
        'fileName', {}, ...
        'fullPath', {} );

    featureNames = {};

    % loop sulle due classi
    for ic = 1:numel(classi)
        classeName = classi{ic};
        classFolder = fullfile(rootDir, classeName);

        if ~isfolder(classFolder)
            warning('Cartella non trovata: %s (salto)', classFolder);
            continue;
        end

        % tutte le cartelle testXX
        testDirs = dir(fullfile(classFolder, 'test*'));
        testDirs = testDirs([testDirs.isdir]);  % solo directory

        for it = 1:numel(testDirs)
            testName = testDirs(it).name;
            testFolder = fullfile(classFolder, testName);

            % --- MODIFICA QUI ---
            % prima: pcdFiles = dir(fullfile(testFolder, '*.pcd'));
            % adesso prendo solo i file *_bike.pcd
            pcdFiles = dir(fullfile(testFolder, '*_filtered.pcd'));

            for ip = 1:numel(pcdFiles)
                fileName = pcdFiles(ip).name;
                fullPath = fullfile(testFolder, fileName);

                try
                    % legge la point cloud
                    ptCloud = pcread(fullPath);

                    % calcola le feature per una singola point cloud
                    feat = calcolaFeaturePointCloud(ptCloud);

                    % la prima volta inizializzo featureNames
                    if isempty(X)
                        featureNames = feat.names;
                    end

                    % accumulo il vettore di feature (riga)
                    X = [X; feat.values(:).'];  %#ok<AGROW>

                    % accumulo etichetta
                    y = [y; categorical({classeName})]; %#ok<AGROW>

                    % salvo info aggiuntive
                    info(end+1).classe     = classeName; %#ok<AGROW>
                    info(end).testFolder   = testName;
                    info(end).fileName     = fileName;
                    info(end).fullPath     = fullPath;

                catch ME
                    warning('Errore con file %s: %s', fullPath, ME.message);
                end
            end
        end
    end
end

% =========================================================================
function feat = calcolaFeaturePointCloud(ptCloud)
% CALCOLAFEATUREPOINTCLOUD Calcola un set di feature da un oggetto pointCloud
%
%   feat.names  - cell array con i nomi delle feature
%   feat.values - vettore riga con i valori corrispondenti
%
% Feature usate:
%   - nPoints
%   - centroid_x,y,z
%   - bbox_volume
%   - point_density = nPoints / bbox_volume
%   - meanZ, stdZ, minZ, maxZ

    % estraggo le coordinate (N x 3)
    P = ptCloud.Location;
    P = reshape(P, [], 3);              % nel caso di point cloud organizzata
    % rimuovo eventuali NaN/Inf
    P = P(all(isfinite(P),2), :);

    feat.names  = definisciNomiFeature();
    nFeature    = numel(feat.names);

    if size(P,1) < 3
        % troppo pochi punti: riempio con NaN
        feat.values = nan(1, nFeature);
        return;
    end

    % ---------------------------
    % 1) feature geometriche base
    % ---------------------------
    nPoints   = size(P,1);
    centroid  = mean(P,1);          % [cx, cy, cz]
    minP      = min(P,[],1);
    maxP      = max(P,[],1);
    bboxSize  = maxP - minP;        % [dx, dy, dz]
    bboxVol   = prod(bboxSize);

    if bboxVol <= 0
        bboxVol = eps;
    end

    pointDensity = nPoints / bboxVol;

    % ---------------------------
    % 2) feature lungo z (altezza)
    % ---------------------------
    z = P(:,3);
    meanZ = mean(z);
    stdZ  = std(z);
    minZ  = min(z);
    maxZ  = max(z);

    % ---------------------------
    % vettore finale (ordine = names)
    % ---------------------------
    feat.values = [ ...
        nPoints, ...
        centroid, ...                 % cx, cy, cz
        bboxVol, ...
        pointDensity, ...
        meanZ, stdZ, minZ, maxZ ...
    ];
end

% =========================================================================
function names = definisciNomiFeature()
% Definisce i nomi (in ordine) delle feature usate in calcolaFeaturePointCloud

    names = { ...
        'nPoints', ...
        'centroid_x', 'centroid_y', 'centroid_z', ...
        'bbox_volume', ...
        'point_density', ...
        'meanZ', 'stdZ', 'minZ', 'maxZ' ...
    };
end