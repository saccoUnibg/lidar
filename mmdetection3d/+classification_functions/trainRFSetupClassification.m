function results = trainRFSetupClassification(X, y, info)
% TRAINRFSETUPCLASSIFICATION
%   Addestra un classificatore Random Forest (Bagged Trees)
%   per distinguere bici_corsa vs mtb usando X, y e info.
%
% INPUT:
%   X    - matrice nCampioni x nFeature
%   y    - vettore categorical (nCampioni x 1) con 'bici_corsa'/'mtb'
%   info - struct array con almeno il campo .testFolder
%
% OUTPUT (struct results):
%   .Mdl          - modello RF addestrato su TUTTO il dataset
%   .yPredCV      - predizioni in cross-validation leave-one-test-folder-out
%   .confMat      - matrice di confusione (righe = vero, colonne = predetto)
%   .labels       - ordine delle etichette nella confMat
%   .accuracy     - accuratezza media in CV

    % --- 0) Assicuriamoci che y sia categorical con le due classi giuste ---
    if ~iscategorical(y)
        y = categorical(y);
    end
    cats = categories(y);
    if numel(cats) ~= 2 || ~all(ismember({'bici_corsa','mtb'}, cats))
        y = categorical(cellstr(y), {'bici_corsa','mtb'});
    end

    n = size(X,1);

    % --- 1) Definizione dei gruppi (test-folder) ---
    groups = {info.testFolder}.';   % cell array n x 1 con 'test01','test02',...
    uniqueGroups = unique(groups);

    % userò un cell array per le predizioni, poi le converto a categorical
    yPredCell = cell(n,1);

    % --- 2) Cross-validation leave-one-test-folder-out ---
    for ig = 1:numel(uniqueGroups)
        thisGroup = uniqueGroups{ig};

        idxTest  = strcmp(groups, thisGroup);
        idxTrain = ~idxTest;

        Xtrain = X(idxTrain, :);
        yTrain = y(idxTrain);

        Xtest  = X(idxTest, :);

        % Random Forest (Bagged Trees) con opzioni base (compatibili)
        % NumLearningCycles = numero di alberi (100 è un buon valore di partenza)
        MdlFold = fitcensemble(Xtrain, yTrain, ...
            'Method', 'Bag', ...
            'NumLearningCycles', 100);

        % predizioni sul fold di test
        yPredFold = predict(MdlFold, Xtest);   % categorical
        yPredCell(idxTest) = cellstr(yPredFold);
    end

    % converto le predizioni finali in categorical
    yPredCV = categorical(yPredCell, {'bici_corsa','mtb'});

    % --- 3) Matrice di confusione e accuratezza ---
    [confMat, labels] = confusionmat(y, yPredCV);
    accuracy = sum(yPredCV == y) / numel(y);

    % --- 4) Modello finale addestrato su TUTTI i dati ---
    MdlFull = fitcensemble(X, y, ...
        'Method', 'Bag', ...
        'NumLearningCycles', 100);

    % --- 5) Salvataggio risultati in struct ---
    results = struct();
    results.Mdl      = MdlFull;
    results.yPredCV  = yPredCV;
    results.confMat  = confMat;
    results.labels   = labels;
    results.accuracy = accuracy;
end