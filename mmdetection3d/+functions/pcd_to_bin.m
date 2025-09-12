function pcd_to_bin(pcdFile,binFileName)
    xyz = pcdFile.Location;          % N x 3
    if ~isempty(pcdFile.Intensity)
        refl = pcdFile.Intensity;    % N x 1
    else
        refl = ones(size(xyz,1),1,'single'); % se manca intensità
    end
    
    % Intensity per mmdetection3d va in [0;1]
    if max(refl) > 1.001
        refl = refl ./ max(refl); % Normalizzo su valore max
    end

    % Costruisci matrice Nx4
    data = [single(xyz), single(refl)];
    
    % Scrivi in formato KITTI .bin
    fid = fopen(binFileName,'wb','ieee-le');
    fwrite(fid, data', 'single');   % trasposto per scrittura corretta
    fclose(fid);
end