function detect_pcd(ptCloud,detector, threshold,title)
    disp(title)
    classNames = detector.ClassNames;
    colors = {'green','magenta'};
    
    [bboxes,score,labels] = detect(detector,ptCloud,"Threshold",threshold);
    
    if isempty(bboxes)
        disp("Nessun oggetto rilevato.");
    else
        disp("Oggetti rilevati: " + size(bboxes,1));
        for i = 1:numel(score)
            disp("  ("+string(i)+") Score: " + score(i) + " (" + string(labels(i))+")");
        end
    end
    functions.showPcdWith3dBoxes(ptCloud,bboxes,labels,classNames,colors,title);
end