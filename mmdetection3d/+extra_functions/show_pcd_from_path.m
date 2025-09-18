function show_pcd_from_path(path)

    pcdPath = path + "/0_original";
    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    numFiles = size(lidarData.Files,1);

    for i = 1 : numFiles
        pointCloud = lidarData.read();
        pcshow(pointCloud);
        title(['Point Cloud from File ' num2str(i)]);
        pause(0.1); % Pause to allow visualization
    end

end