function show_pcd_from_path(path)

    lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
    numFiles = size(lidarData.Files,1);

    for i = 1 : numFiles
        figure(i);
        pointCloud = lidarData.read();
        pcshow(pointCloud);
        title(['Point Cloud from File ' num2str(i)]);
        hold on;

    end

end