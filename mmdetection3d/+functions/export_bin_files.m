function export_bin_files(path)
    
    pcdPath = path + "/1_pcd";  
    binPath = path + "/2_bin";

    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    
    if ~exist(binPath, 'dir')
        try
            mkdir(binPath);
            reset(lidarData);
            numFiles = size(lidarData.Files,1);
            for i = 1:numFiles
                ptCloud = read(lidarData);
                % functions.show_pcd(ptCloud,"pcd");

                % operazione da controllare: posso fornirli raw?
                % ptCloud = functions.preprocess_pcd(ptCloud);
    
                % OPERAZIONE DA CONTROLLARE: devo ruotarli?
                % rotationAngles = [0 0 90];
                % translation = [0 0 0];
                % tform = rigidtform3d(rotationAngles,translation);
                % ptCloudRotated = pctransform(ptCloud, tform);
                
                % salvataggio pcd in fullPath
                bin_FileName = fullfile(binPath, sprintf('bin_%03d.bin', i));
                functions.pcd_to_bin(ptCloud,bin_FileName)
            end
        catch ME
            rmdir(fullPath,'s');
            disp("Errore nella creazione files .bin, ripetere l'operazione");
            disp(ME.message);
        end
    else
        disp("Cartella gia' presente, non e' stato sovrascritto nulla (forse devi cambiare path?)");
    end
end