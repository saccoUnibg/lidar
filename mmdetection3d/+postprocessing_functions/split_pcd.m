function split_pcd(pcd_list,index)
    close all;
    numFiles = size(pcd_list,1);

    for i = 1:numFiles
        if i == index
            ptCloud = pcd_list{i};
            if ~isempty(ptCloud)
                get_bike_pcd(ptCloud);
            end
        end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function get_bike_pcd(pcd)
% Restituisce:
%   bike_pcd  : pointCloud con soli punti bici
%   idx_remap : vettore Nx1 con etichette {1=bici, 2=rider} stabili

    P = pcd.Location;                % Nx3 (non organizzata)
    z = P(:,3);

    I = pcd.Intensity;

    if isempty(I)
        I = zeros(size(z));
    end
    
    I = double(I(:));

    % Feature: [Z, Intensity] normalizzate
    zf = (z - mean(z)) / std(z);
    If = (I - mean(I)) / max(std(I), eps);
    X = [zf, If];

    % k-means con risultato riproducibile
    rng(1);
    idx = kmeans(X, 2, 'Replicates', 5, 'MaxIter', 1000, 'Start', 'plus');

    % Decidi quale cluster è la bici: quello con Z media più bassa
    muZ = [mean(z(idx==1)), mean(z(idx==2))];
    [~, bikeLbl] = min(muZ);

    % RIMAPPA: bici -> 1, rider -> 2 (etichette stabili)
    idx_remap = ones(size(idx));
    idx_remap(idx ~= bikeLbl) = 2;

    % Seleziona la bici
    figure(1)
    pcshow(pcd,"ColorSource","Intensity","MarkerSize",70);
    set(gcf,'color','w');
    set(gca,'color','w');
    set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
    colormap(hot);            % scegli la colormap (jet, hot, parula, turbo, ecc.)


    bike_pcd = select(pcd, find(idx_remap == 1));
    user_pcd = select(pcd,find(idx_remap == 2));


    % figure(2)
    % pcshow(bike_pcd,"ColorSource","Intensity","MarkerSize",70);
    % set(gcf,'color','w');
    % set(gca,'color','w');
    % set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
    % colormap(hot);            % scegli la colormap (jet, hot, parula, turbo, ecc.)
    % 
    % 
    % figure(3)
    % pcshow(user_pcd,"ColorSource","Intensity","MarkerSize",70);
    % set(gcf,'color','w');
    % set(gca,'color','w');
    % set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
    % colormap(hot);            % scegli la colormap (jet, hot, parula, turbo, ecc.)

    
end