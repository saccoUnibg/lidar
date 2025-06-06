%% a.b. PointNet++

openExample 'deeplearning_shared/PointCloudClassificationUsingPointNetPlusDeepLearningExample'
% NON VA
openExample 'deeplearning_shared/AerialLidarSemanticSegmentationUsingPointNetExample'
% Classi allenate presenti nell'esempio

%% c. PointSeg model

openExample('deeplearning_shared/LidarSemanticSegmentationUsingPointSegExample')
% SCARICO MODELLO E LO CARICO
% disp('Downloading pretrained network (14 MB)...');
% pretrainedURL = 'https://www.mathworks.com/supportfiles/lidar/data/trainedPointSegNet.mat';
% websave('trainedPointSegNet.mat', pretrainedURL);

pretrainedNetwork = load('trainedPointSegNet.mat');
net = pretrainedNetwork.net;
I = PointSeg_PointCloudToImage(ptCloudProcessed);
predictedResult = semanticseg(ptCloudProcessed, net);
semanticseg()

% PROBLEMA: richiede point cloud organizzata (si può risolvere);
% problema: classi non idonee

%% d. SqueezeSegV2
openExample('deeplearning_shared/LidarSemanticSegmentationUsingSqueezeSegV2Example')
load("trainedSqueezesegV2NetPandaset.mat","net");

% PROBLEMA: richiede point cloud organizzata (si può risolvere); inoltre,
% dalla pagina si vede che cyclist o bike non c'è; ---> c'è pedestrian però

%% e. Salsanext
open ('/Users/cristiansacco/workspaces/pretrained-salsanext/salsaNextSemanticSegmentationExample.m')

% problema: point cloud unorganized -> si può risolvere
% problema: classi non idonee

%% g. Complex-YoloV4
open ('/Users/cristiansacco/workspaces/Lidar-object-detection-using-complex-yolov4/complexYOLOv4PredictionExample.m');

%% onnx model pointpillars

lidarLabeler