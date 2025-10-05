%% Setup iniziale
clc; clear; close all
cd('/Users/cristiansacco/workspaces/lidar/main')
%% tools
% lidarViewer
% lidarLabeler
% openExample('deeplearning_shared/Lidar3DObjectDetectionUsingPointPillarsExample')
%% 1. 'trainingData' -> I metodo: creazione tabella da gTruth manualmente

% 1. Upload gTruth con bounding box e path dei pcd
gTruthPath = "/Users/cristiansacco/workspaces/lidar/1_files_pcd/0_transfer_learning/set_00/gTruth_set00.mat";
load(gTruthPath);

% 2. Estrazione tutti nomi files .pcd da inserire nella table
folderPCD = gTruth.DataSource.SourceName;
filesStruct = dir(fullfile(folderPCD, '*.pcd'));
pcdFiles = fullfile({filesStruct.folder}, {filesStruct.name})';

% 3. Crea tabella con pcd (aggiungo dopo le bounding box delle classi)
t1 = cell2table(pcdFiles);

% 4. Prendo colonne della timetable
labelDataTable = timetable2table(gTruth.LabelData);
t2 = labelDataTable(:,2:3);

% 5. Unisco le due colonne
trainData = [t1 t2];

%% 1. 'trainingData' -> II metodo: creazione tabella da gTruth con funzione pre-esistente
% trainData = lidarObjectDetectorTrainingData(gTruth);
% ---> problema: restituisce solo 5 righe. è corretto che sia così?

%% 2. resize di 'trainingData' (per problemi di memoria)

idxEmpty = cellfun(@isempty, trainData.Cyclist) | cellfun(@isempty, trainData.Car);

trainingData = trainData(~idxEmpty, :);

% e' possibile ridurre la dimensione della tabella
% tableSize = 13;
% trainingData = trainingData(1:tableSize, :);

% NB: le righe della tabella per il transfer learning deve contenere label per ogni
% classe: se per una classe (es. Car) non sono presenti label in una point
% cloud, anche se ci sono label per ciclisti, andrà in errore il tl.
%% 3. Creazione detector object con classi, range e anchor boxes

% 1. pointCloudRange -> import rete preaddestrata
pretrainedDetector = load("pretrainedPointPillarsDetector.mat","detector");
detector = pretrainedDetector.detector;
fprintf('Range coordinate del modello preaddestrato:\n')
disp(detector.PointCloudRange)

% % POINT CLOUD RANGE
% xMin = -34.56;
% xMax = 34.56;
% 
% yMin = 0;
% yMax = 34.56;
% 
% zMin = -5.0;
% zMax = 5.0;
% 
% % Resolution along X-axis.
% xStep = 0.16;
% % Resolution along Y-axis.
% yStep = 0.16;
% pointCloudRange = [xMin xMax yMin yMax zMin zMax];

pointCloudRange = detector.PointCloudRange;

% ---> SE NON METTO LO STESSO RANGE, IL TRAINING FALLISCE!

fprintf('Range coordinate del nuovo modello da addestrare:\n')
disp(pointCloudRange);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% 2. ClassNames
classNames = gTruth.LabelDefinitions.Name; % {'Cyclist', 'Car'}

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% 3. AnchorBoxes -> opzione 1: funzione presa da esempio in cima (da
% mettere in functions nelle prossime iterazioni)

anchors = [];
% Calculate the anchors for each class label.
for ii = 1:numel(classNames)
    bboxCells = table2array(labelDataTable(:,ii+1));
    lwhValues = [];
    
    % Accumulate the lengths, widths, heights from the ground truth
    % labels.
    for i = 1 : height(bboxCells)
        if(~isempty(bboxCells{i}))
            lwhValues = [lwhValues; bboxCells{i}(:, 4:6)];
        end
    end
    
    % Calculate the mean for each. 
    meanVal = mean(lwhValues, 1);
    
    % With the obtained mean values, create two anchors with two 
    % yaw angles, 0 and 90.
%         classAnchors = [{num2cell([meanVal, -1.78, 0])}, {num2cell([meanVal, -1.78, pi/2])}];
    classAnchors = [[meanVal, -1.78, 0]; [meanVal, -1.78, pi/2]];
    
    anchors = [anchors; {classAnchors}];
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% 4. creazione detector
cyclistDetector = pointPillarsObjectDetector(detector.Network,pointCloudRange,classNames,anchors);

%% 4. training

options = trainingOptions("adam","ExecutionEnvironment","auto","ResetInputNormalization",false, ...
    "BatchNormalizationStatistics","moving","OutputNetwork","last-iteration");

[newDetector,info] = trainPointPillarsObjectDetector(trainingData,cyclistDetector,options)

%% 5. inference
cd('/Users/cristiansacco/workspaces/lidar/main')
% Load datastore
outputFolder = fullfile("/Users/cristiansacco/workspaces/lidar/1_files_pcd/");
path = fullfile(outputFolder,'test11/cropped');
lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
ptCloud = preview(lidarData);
functions.show_pcd(ptCloud,"Point Cloud - Input (Da ruotare?)");


disp("New detector!")
threshold = 0.4;
[bboxes,score,labels] = detect(newDetector,ptCloud,"Threshold",threshold);
functions.detect_pcd(ptCloud,newDetector,threshold,"Inferenza New Detector");
