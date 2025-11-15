function [X, y, featureNames, info] = estraiFeaturePCD(rootDir)
% ESTRAIFEATUREPCD Estrae feature da tutte le PCD nel dataset
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
% Richiede Computer Vision Toolbox (pcread).

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

            % tutti i file pcd
            pcdFiles = dir(fullfile(testFolder, '*.pcd'));

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
% Feature pensate per ~1400 PCD totali:
%   - nPoints
%   - centroid_x,y,z
%   - bbox_dx, bbox_dy, bbox_dz
%   - bbox_volume
%   - point_density = nPoints / bbox_volume
%   - autovalori lambda1,2,3 (covarianza)
%   - linearity, planarity, scattering, omnivariance,
%     anisotropy, eigenentropy
%   - meanZ, stdZ, minZ, maxZ
%   - horizontal_extent (XY), slenderness, flatness

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
    % 1) feature semplici
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

    % XY extent e rapporti forma
    rangeX = bboxSize(1);
    rangeY = bboxSize(2);
    height = bboxSize(3);

    horizontalExtent = sqrt(rangeX^2 + rangeY^2);
    if horizontalExtent <= 0
        horizontalExtent = eps;
    end

    slenderness = height / horizontalExtent;       % alto vs largo
    flatness    = horizontalExtent / (height+eps); % "sdraiato"

    % ---------------------------
    % 2) feature PCA/covarianza
    % ---------------------------
    C = cov(P);                     % matrice 3x3
    [~,D] = eig(C);
    lambda = sort(diag(D), 'descend');  % lambda1 >= lambda2 >= lambda3

    % correzione numerica
    lambda(lambda < 0) = 0;

    % normalizzo per somma = 1 (per alcune misure)
    lambdaSum = sum(lambda);
    if lambdaSum == 0
        lambdaNorm = [1; 0; 0];
    else
        lambdaNorm = lambda / lambdaSum;
    end

    lambda1 = lambda(1);
    lambda2 = lambda(2);
    lambda3 = lambda(3);

    % shape features
    if lambda1 <= 0
        linearity    = 0;
        planarity    = 0;
        scattering   = 0;
        omnivariance = 0;
        anisotropy   = 0;
    else
        linearity    = (lambda1 - lambda2) / lambda1;
        planarity    = (lambda2 - lambda3) / lambda1;
        scattering   = lambda3 / lambda1;
        omnivariance = (lambda1*lambda2*lambda3)^(1/3);
        anisotropy   = (lambda1 - lambda3) / lambda1;
    end
    eigenentropy = -sum(lambdaNorm .* log(lambdaNorm + eps));

    % ---------------------------
    % 3) feature lungo z (altezza)
    % ---------------------------
    z = P(:,3);
    meanZ = mean(z);
    stdZ  = std(z);
    minZ  = min(z);
    maxZ  = max(z);

    % ---------------------------
    % costruisco il vettore finale
    % ---------------------------
    feat.values = [ ...
        nPoints, ...
        centroid, ...                 % cx, cy, cz
        bboxSize, ...                 % dx, dy, dz
        bboxVol, ...
        pointDensity, ...
        lambda1, lambda2, lambda3, ...
        linearity, planarity, scattering, ...
        omnivariance, anisotropy, eigenentropy, ...
        meanZ, stdZ, minZ, maxZ, ...
        horizontalExtent, slenderness, flatness ...
    ];
end

% =========================================================================
function names = definisciNomiFeature()
% Definisce i nomi (in ordine) delle feature usate in calcolaFeaturePointCloud

    names = { ...
        'nPoints', ...
        'centroid_x', 'centroid_y', 'centroid_z', ...
        'bbox_dx', 'bbox_dy', 'bbox_dz', ...
        'bbox_volume', ...
        'point_density', ...
        'lambda1', 'lambda2', 'lambda3', ...
        'linearity', 'planarity', 'scattering', ...
        'omnivariance', 'anisotropy', 'eigenentropy', ...
        'meanZ', 'stdZ', 'minZ', 'maxZ', ...
        'horizontal_extent', 'slenderness', 'flatness' ...
    };
end