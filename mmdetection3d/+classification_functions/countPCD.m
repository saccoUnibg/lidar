function stats = countPCD(rootDir)
% COUNTPDC Conta quante PCD ci sono nel dataset
%
%   stats = classification_functions.countPCD(rootDir)
%
% OUTPUT (stats):
%   .totali              = numero totale di pcd
%   .perClasse.(classe)  = numero pcd per classe
%   .perTest.(classe).(testXX) = numero pcd per test folder

    if nargin < 1
        rootDir = 'pcd_classification';
    end

    classi = {'bici_corsa', 'mtb'};
    
    stats.totali = 0;
    stats.perClasse = struct();
    stats.perTest = struct();

    for ic = 1:numel(classi)

        classeName = classi{ic};
        classFolder = fullfile(rootDir, classeName);

        if ~isfolder(classFolder)
            warning('Cartella non trovata: %s', classFolder);
            continue;
        end

        stats.perClasse.(classeName) = 0;
        stats.perTest.(classeName) = struct();

        % cartelle test*
        testDirs = dir(fullfile(classFolder, 'test*'));
        testDirs = testDirs([testDirs.isdir]);

        for it = 1:numel(testDirs)

            testName = testDirs(it).name;
            testFolder = fullfile(classFolder, testName);

            % file .pcd
            pcdFiles = dir(fullfile(testFolder, '*.pcd'));
            n = numel(pcdFiles);

            % aggiorno statistiche
            stats.totali = stats.totali + n;
            stats.perClasse.(classeName) = stats.perClasse.(classeName) + n;
            stats.perTest.(classeName).(testName) = n;
        end
    end
end