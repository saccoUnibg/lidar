function show_results(path,results,threshold)
    
    pcdPath = path + "/1_pcd";  
    bboxes = {results.boxes}';

    lidarData = fileDatastore(pcdPath,'ReadFcn',@(x) pcread(x));
    reset(lidarData);
    numFiles = size(lidarData.Files,1);
    for i = 1:numFiles
        ptCloud = read(lidarData);
        bboxes_file = bboxes(i);
        functions.showPcdWith3dBoxes(ptCloud,bboxes_file);
    end


end