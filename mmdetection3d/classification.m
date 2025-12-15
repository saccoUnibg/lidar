%% 0. first steps: conta pcd totali per ogni classe
clc; clear; close all;
root = '/Users/cristiansacco/workspaces/lidar/mmdetection3d/pcd_classification';
stats = classification_functions.countPCD(root);

%% 00. salvataggio pcd sola bici tramite kmeans
classification_functions.batchExtractBikePCD(root)
%% comparison tra bici mtb e bici_corsa solo telaio
% bici mtb      -> test06, frame 28 (filtered), test07, frame 18 (filtered)
% bici da corsa -> test07, frame 038 (filtered)

figure(1)
bike_type = "bici_corsa";
bike_type = "mtb";
test = "01";
frame = "024";
pcd_path = "/Users/cristiansacco/workspaces/lidar/mmdetection3d/pcd_classification/" + bike_type + "/" + "test" + test + "/pcd_bike_" + frame + "_filtered.pcd";
pcshow(pcd_path,"ColorSource","Intensity",MarkerSize=40)
colormap(hot);

set(gcf,'color','w');
set(gca,'color','w');
set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
%% 1. estrazione features
[X, y, featureNames, info] = classification_functions.estraiFeaturePCD(root);

% qualche check veloce
size(X)
tabulate(y)
%% plot features
close all;
Xabs = abs(X);   % valore assoluto della feature
figure('Color','w');
tiledlayout(3,4);

for i = 1:nFeature
    nexttile;
    hold on;

    plot(find(y=='bici_corsa'), Xabs(y=='bici_corsa',i), 'ro');
    plot(find(y=='mtb'),        Xabs(y=='mtb',i),        'bx');

    title(strrep(featureNames{i}, '_','\_'));
    ylabel('Valore assoluto');
    xlabel('Indice campione');
    grid on;
end
%%
% individua le colonne dei centroidi
% Trovo gli indici delle feature centroid_x,y,z
idx_cx = find(strcmp(featureNames, 'centroid_x'));
idx_cy = find(strcmp(featureNames, 'centroid_y'));
idx_cz = find(strcmp(featureNames, 'centroid_z'));

C = X(:, [idx_cx idx_cy idx_cz]);  % matrice Nx3 dei centroidi

% Normalizzazione z-score (necessaria per confrontare bene le scale)
[Cz, muC, sigmaC] = zscore(C);

cx = Cz(:,1);
cy = Cz(:,2);
cz = Cz(:,3);

figure('Color','w');
hold on; grid on;

scatter3(cx(y=='bici_corsa'), cy(y=='bici_corsa'), cz(y=='bici_corsa'), ...
    60, 'r', 'filled');

scatter3(cx(y=='mtb'), cy(y=='mtb'), cz(y=='mtb'), ...
    60, 'b', 'filled');

xlabel('centroid\_x (normalizzato)');
ylabel('centroid\_y (normalizzato)');
zlabel('centroid\_z (normalizzato)');

title('Centroidi normalizzati delle point cloud');
legend('bici\_corsa', 'mtb');

axis equal;
view(40,25);
%%  - - - - PLOT PCA - - - - - - -  - - - - -  - - -
close all;

% 1) Togliamo righe con NaN/Inf
validRows = all(isfinite(X), 2);
X = X(validRows, :);
y = y(validRows);

% 2) Standardizzazione (z-score: media 0, varianza 1)
[Xz, mu, sigma] = zscore(X);

% 3) PCA sui dati standardizzati
[coeff, score, latent, tsquared, explained] = pca(Xz);

figure('Color','w');
gscatter(score(:,1), score(:,2), y, 'rb', 'ox');
xlabel(sprintf('PC1 (%.1f%%%% var)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%%% var)', explained(2)));
title('PCA (dati standardizzati)');
grid on;
axis equal;
% opzionale: taglio outlier su ogni feature (es. oltre 3 deviazioni std)
isOut = any(abs(Xz) > 3, 2);
Xz_clean = Xz(~isOut, :);
y_clean  = y(~isOut);

[coeff, score, ~, ~, explained] = pca(Xz_clean);

figure('Color','w');
gscatter(score(:,1), score(:,2), y_clean, 'rb', 'ox');
xlabel(sprintf('PC1 (%.1f%%%%)', explained(1)));
ylabel(sprintf('PC2 (%.1f%%%%)', explained(2)));
title('PCA (z-score, senza outlier)');
grid on; axis equal;
%% tSNE
% t-SNE a 2 dimensioni
% usiamo i dati standardizzati senza outlier
Xembed = Xz_clean;

Ytsne = tsne(Xembed, 'NumDimensions', 2, ...
                        'Perplexity', 30, ...
                        'Standardize', false);  % già standardizzati

figure('Color','w');
gscatter(Ytsne(:,1), Ytsne(:,2), y_clean, 'rb', 'ox');
xlabel('t-SNE dim 1');
ylabel('t-SNE dim 2');
title('t-SNE delle feature estratte');
grid on;

%% 
% Standardizzazione
[Xz, mu, sigma] = zscore(X);

% t-SNE corretto
Ytsne = tsne(Xz, ...
    'NumDimensions', 2, ...
    'Perplexity', 30, ...
    'Exaggeration', 20, ...
    'LearnRate', 200, ...
    'Verbose', 1);

figure('Color','w');
gscatter(Ytsne(:,1), Ytsne(:,2), y, 'rb', 'ox');
grid on;
xlabel('t-SNE dim 1');
ylabel('t-SNE dim 2');
title('t-SNE (feature normalizzate)');
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
forcedLabels = {'race bike', 'mtb'};
cm = confusionchart(results.confMat, forcedLabels);
title(sprintf('Confusion matrix - Accuracy = %.2f %%', results.accuracy*100));

cm.FontSize = 24;

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
% Forza le etichette
forcedLabels = {'race bike', 'mtb'};
cmRF = confusionchart(resultsRF.confMat, forcedLabels);

% Titolo
cmRF.Title = sprintf('Random Forest - Confusion matrix - Accuracy = %.2f %%', ...
    resultsRF.accuracy * 100);

% Font grande
cmRF.FontSize = 24;

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
