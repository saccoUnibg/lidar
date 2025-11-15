function results = trainSVMSetupClassification(X, y, info)
% TRAINSVMSETUPCLASSIFICATION
%   Addestra un classificatore SVM per distinguere bici_corsa vs mtb
%   usando le feature X e le etichette y.
%
% INPUT:
%   X    - matrice nCampioni x nFeature
%   y    - vettore categorical (nCampioni x 1) con 'bici_corsa'/'mtb'
%   info - struct array con almeno il campo .testFolder
%
% OUTPUT (struct results):
%   .Mdl          - modello SVM addestrato su TUTTO il dataset
%   .mu, .sigma   - parametri di standardizzazione
%   .yPredCV      - predizioni in cross-validation leave-one-test-folder-out
%   .confMat      - matrice di confusione (righe = vero, colonne = predetto)
%   .labels       - ordine delle etichette nella confMat
%   .accuracy     - accuratezza media in CV

    % Assicuriamoci che y sia categorical con le due classi
    if ~iscategorical(y)
        y = categorical(y);
    end
    % Se le categorie non coincidono, le riordiniamo/definiamo
    cats = categories(y);
    if numel(cats) ~= 2 || ~all(ismember({'bici_corsa','mtb'}, cats))
        y = categorical(cellstr(y), {'bici_corsa','mtb'});
    end

    % --------- 1) Standardizzazione delle feature ---------
    mu = mean(X, 1);
    sigma = std(X, 0, 1);
    sigma(sigma == 0) = 1;   % per evitare divisione per zero
    Xn = (X - mu) ./ sigma;

    n = size(Xn,1);

    % --------- 2) Definizione dei gruppi (test-folder) ---------
    groups = {info.testFolder}.';   % cell array n x 1 con 'test01','test02',...
    uniqueGroups = unique(groups);

    % userò un cell array per le predizioni, poi le converto a categorical
    yPredCell = cell(n,1);

    % --------- 3) Cross-validation leave-one-test-folder-out ---------
    for ig = 1:numel(uniqueGroups)
        thisGroup = uniqueGroups{ig};

        idxTest  = strcmp(groups, thisGroup);
        idxTrain = ~idxTest;

        Xtrain = Xn(idxTrain, :);
        yTrain = y(idxTrain);

        Xtest  = Xn(idxTest, :);

        % SVM binaria con kernel RBF (niente opzioni strane)
        MdlFold = fitcsvm(Xtrain, yTrain, ...
            'KernelFunction', 'rbf');   % opzioni minime -> più compatibili

        % predizioni sul fold di test
        yPredFold = predict(MdlFold, Xtest);   % categorical
        yPredCell(idxTest) = cellstr(yPredFold);
    end

    % converto le predizioni finali in categorical
    yPredCV = categorical(yPredCell, {'bici_corsa','mtb'});

    % --------- 4) Matrice di confusione e accuratezza ---------
    [confMat, labels] = confusionmat(y, yPredCV);
    accuracy = sum(yPredCV == y) / numel(y);

    % --------- 5) Modello finale addestrato su TUTTI i dati ---------
    MdlFull = fitcsvm(Xn, y, ...
        'KernelFunction', 'rbf');   % anche qui modello semplice

    % --------- 6) Salvataggio risultati in struct ---------
    results = struct();
    results.Mdl      = MdlFull;
    results.mu       = mu;
    results.sigma    = sigma;
    results.yPredCV  = yPredCV;
    results.confMat  = confMat;
    results.labels   = labels;
    results.accuracy = accuracy;
end