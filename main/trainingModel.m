%% Setup iniziale
clc
clear
close all
cd('/Users/cristiansacco/workspaces/lidar/main')
%% tools
% lidarViewer
% lidarLabeler("1_files_pcd/training_pcd/")
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
%% PointPillars model import
pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
fprintf('Range coordinate del modello:\n')
disp(detector.PointCloudRange)

%% trainingData
load("gTruth/gTruth_trainingPcd.mat");

% 1. Trova tutti i file .pcd
folderPCD = gTruth.DataSource.SourceName;
filesStruct = dir(fullfile(folderPCD, '*.pcd'));
pcdFiles = sort(fullfile({filesStruct.folder}, {filesStruct.name})');

% 2. Verifica coerenza
assert(height(gTruth.LabelData) == numel(pcdFiles), ...
    'Mismatch tra .pcd e gTruth');

% 3. Preparazione
N = numel(pcdFiles);
labelNames = gTruth.LabelDefinitions.Name;  % es. {'Cyclist'}
labelTable = gTruth.LabelData;

% 4. Inizializza contenitori
validFileNames = {};
labelColumns = cell(1, numel(labelNames));  % una cella per colonna

% 5. Loop per costruire righe valide (con almeno 1 bounding box)
for i = 1:N
    hasBox = false;
    tempBoxes = cell(1, numel(labelNames));

    for k = 1:numel(labelNames)
        boxK = labelTable{i, labelNames{k}}{1};  % Mx9 matrix
        tempBoxes{k} = boxK;
        if ~isempty(boxK)
            hasBox = true;
        end
    end

    if hasBox
        validFileNames{end+1,1} = pcdFiles{i};
        for k = 1:numel(labelNames)
            labelColumns{k}{end+1,1} = tempBoxes{k};
        end
    end
end

% 6. Costruzione della tabella finale
labelData = table(validFileNames, 'VariableNames', {'ptCloudFilename'});
for k = 1:numel(labelNames)
    labelData.(labelNames{k}) = labelColumns{k};
end

%% refactor table size
tableSize = 20;
labelData = labelData(1:tableSize, :);

%% Transfer learning
%Le --anchor boxes-- non indicano dove si trovano gli oggetti nel point cloud,
% ma rappresentano le dimensioni tipiche (forma e scala) degli oggetti che 
% vuoi rilevare, usate come prototipi durante la fase di training.

% POINT CLOUD RANGE
xMin = 0.0;     % Minimum value along X-axis.
yMin = -39.68;  % Minimum value along Y-axis.
zMin = -5.0;    % Minimum value along Z-axis.
xMax = 69.12;   % Maximum value along X-axis.
yMax = 39.68;   % Maximum value along Y-axis.
zMax = 5.0;     % Maximum value along Z-axis.
xStep = 0.16;   % Resolution along X-axis.
yStep = 0.16;   % Resolution along Y-axis.
pointCloudRange = [xMin xMax yMin yMax zMin zMax];

% ANCHORBOXES -> [l, w, h, c, a]
% opzione 1: a mano
% anchorBoxes = {
%     [1.8, 0.6, 1.7, 0.85, 0;   % frontale
%     1.8, 0.6, 1.7, 0.85, pi/2];   % laterale
% };
% opzione 2: funzione estimate (non funzionante al momento, va configurato
% il datastore)
anchorBoxes = estimateAnchorBoxes(labelData,2);

% opzione 3: 

anchorBoxes = calculateAnchorsPointPillars()


classNames = {'Cyclist'};

cyclistDetector = pointPillarsObjectDetector(detector.Network,pointCloudRange,classNames,anchorBoxes);

%% training

options = trainingOptions("adam","ExecutionEnvironment","auto","ResetInputNormalization",false, ...
    "BatchNormalizationStatistics","moving","OutputNetwork","last-iteration");
[newDetector,info] = trainPointPillarsObjectDetector(labelData,cyclistDetector,options)