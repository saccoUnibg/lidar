function ptCloud = bin_to_pcd(binFile)

    fid = fopen(binFile, 'rb');
    assert(fid ~= -1, 'Impossibile aprire: %s', binFile);
    
    data = fread(fid, inf, 'single=>single', 0, 'ieee-le');  % little-endian
    fclose(fid);
    
    assert(mod(numel(data), 4) == 0, 'Dimensioni non multiple di 4.');
    data = reshape(data, 4, []).';          % N x 4
    xyz  = data(:, 1:3);                     % N x 3
    refl = data(:, 4);
    
    ptCloud = pointCloud(xyz,"Intensity",refl);
end