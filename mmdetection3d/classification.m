%% 0. first steps: conta pcd totali per ogni classe
clc; clear; close all;
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d/pcd_classification';
stats = classification_functions.countPCD(root);
%% 1. estrazione features
[X, y, featureNames, info] = classification_functions.estraiFeaturePCD(root);

% qualche check veloce
size(X)
tabulate(y)

%% 2. classificazione tramite SVM

results = classification_functions.trainSVMSetupClassification(X, y, info);

% risultati validazione
fprintf('\n=== RISULTATI CROSS-VALIDATION (leave-one-test-folder-out) ===\n');
fprintf('Accuracy media: %.2f %%\n', results.accuracy * 100);

% loss:
loss = 1 - results.accuracy;
fprintf('Loss (errore medio): %.3f\n', loss);

% Matrice di confusione

figure;
confusionchart(results.confMat, cellstr(results.labels));
title(sprintf('Confusion matrix - Accuracy = %.2f %%', results.accuracy*100));


confMat = results.confMat;
labels  = cellstr(results.labels);

% assumiamo ordine: 1 = bici_corsa, 2 = mtb
idxBiciCorsa = find(strcmp(labels, 'bici_corsa'));
idxMTB       = find(strcmp(labels, 'mtb'));

TP_corsa = confMat(idxBiciCorsa, idxBiciCorsa);
FN_corsa = sum(confMat(idxBiciCorsa, :)) - TP_corsa;
FP_corsa = sum(confMat(:, idxBiciCorsa)) - TP_corsa;

TP_mtb = confMat(idxMTB, idxMTB);
FN_mtb = sum(confMat(idxMTB, :)) - TP_mtb;
FP_mtb = sum(confMat(:, idxMTB)) - TP_mtb;

precision_corsa = TP_corsa / (TP_corsa + FP_corsa);
recall_corsa    = TP_corsa / (TP_corsa + FN_corsa);

precision_mtb = TP_mtb / (TP_mtb + FP_mtb);
recall_mtb    = TP_mtb / (TP_mtb + FN_mtb);

F1_corsa = 2 * precision_corsa * recall_corsa / (precision_corsa + recall_corsa);
F1_mtb   = 2 * precision_mtb * recall_mtb / (precision_mtb + recall_mtb);

fprintf('\n=== Metriche per classe ===\n');
fprintf('bici_corsa: Precision = %.2f, Recall = %.2f, F1 = %.2f\n', ...
    precision_corsa, recall_corsa, F1_corsa);
fprintf('mtb       : Precision = %.2f, Recall = %.2f, F1 = %.2f\n', ...
    precision_mtb, recall_mtb, F1_mtb);

%% 3. Classificazione con random forest

resultsRF = classification_functions.trainRFSetupClassification(X, y, info);

fprintf('\n=== RANDOM FOREST (Bagged Trees) - CV leave-one-test-folder-out ===\n');
fprintf('Accuracy media RF: %.2f %%\n', resultsRF.accuracy * 100);
lossRF = 1 - resultsRF.accuracy;
fprintf('Loss RF (errore medio): %.3f\n', lossRF);

% Matrice di confusione RF

figure;
confusionchart(resultsRF.confMat, cellstr(resultsRF.labels));
title(sprintf('Random Forest - Confusion matrix - Accuracy = %.2f %%', ...
    resultsRF.accuracy*100));

% Metriche per classe (RF)

confMatRF = resultsRF.confMat;
labelsRF  = cellstr(resultsRF.labels);

idxBiciCorsa_RF = find(strcmp(labelsRF, 'bici_corsa'));
idxMTB_RF       = find(strcmp(labelsRF, 'mtb'));

TP_corsa_RF = confMatRF(idxBiciCorsa_RF, idxBiciCorsa_RF);
FN_corsa_RF = sum(confMatRF(idxBiciCorsa_RF, :)) - TP_corsa_RF;
FP_corsa_RF = sum(confMatRF(:, idxBiciCorsa_RF)) - TP_corsa_RF;

TP_mtb_RF = confMatRF(idxMTB_RF, idxMTB_RF);
FN_mtb_RF = sum(confMatRF(idxMTB_RF, :)) - TP_mtb_RF;
FP_mtb_RF = sum(confMatRF(:, idxMTB_RF)) - TP_mtb_RF;

precision_corsa_RF = TP_corsa_RF / (TP_corsa_RF + FP_corsa_RF);
recall_corsa_RF    = TP_corsa_RF / (TP_corsa_RF + FN_corsa_RF);

precision_mtb_RF = TP_mtb_RF / (TP_mtb_RF + FP_mtb_RF);
recall_mtb_RF    = TP_mtb_RF / (TP_mtb_RF + FN_mtb_RF);

F1_corsa_RF = 2 * precision_corsa_RF * recall_corsa_RF / ...
              (precision_corsa_RF + recall_corsa_RF);
F1_mtb_RF   = 2 * precision_mtb_RF * recall_mtb_RF / ...
              (precision_mtb_RF + recall_mtb_RF);

fprintf('\n=== Metriche per classe - Random Forest ===\n');
fprintf('bici_corsa (RF): Precision = %.2f, Recall = %.2f, F1 = %.2f\n', ...
    precision_corsa_RF, recall_corsa_RF, F1_corsa_RF);
fprintf('mtb       (RF): Precision = %.2f, Recall = %.2f, F1 = %.2f\n', ...
    precision_mtb_RF, recall_mtb_RF, F1_mtb_RF);