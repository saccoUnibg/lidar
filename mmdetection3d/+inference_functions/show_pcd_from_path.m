function show_pcd_from_path(path)

    lidarData = fileDatastore(path,'ReadFcn',@(x) pcread(x));
    numFiles = size(lidarData.Files,1);

    for i = 1 : numFiles
        figure(i);
        pointCloud = lidarData.read();
        pcshow(pointCloud,"ColorSource","Intensity","MarkerSize",20);
        set(gcf,'color','w');
        set(gca,'color','w');
        set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
        hold on;
    end

end