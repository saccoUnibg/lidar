function detect_pcd(ptCloud,threshold,title)
    disp(title)
    classNames = {'Car','Truck'};
    colors = {'green','magenta'};
    
    pretrainedDetector = load('pretrainedPointPillarsDetector.mat','detector');
    detector = pretrainedDetector.detector;
    
    [bboxes,score,labels] = detect(detector,ptCloud,"Threshold",threshold);
    
    if isempty(bboxes)
        disp("Nessun oggetto rilevato.");
    else
        disp("Oggetti rilevati: " + size(bboxes,1));
        for i = 1:numel(score)
            disp("  Score: " + score(i) + " (" + string(labels(i))+")");
        end
    end
    functions.showPcdWith3dBoxes(ptCloud,bboxes,labels,classNames,colors);
end