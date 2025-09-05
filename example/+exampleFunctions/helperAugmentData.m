function data = helperAugmentData(data)
    % Apply random scaling, rotation and translation.
    pc = data{1};
    
    minAngle = -45;
    maxAngle = 45;
    
    % Define outputView based on the grid-size and XYZ limits.
    outView = imref3d([32,32,32],[-100,100],...
        [-100,100],[-100,100]);
    
    
    theta = minAngle + rand(1,1)*(maxAngle - minAngle);
    tform = randomAffine3d('Rotation',@() deal([0,0,1],theta),...
        'Scale',[0.95,1.05],...
        'XTranslation',[0,0.2],...
        'YTranslation',[0,0.2],...
        'ZTranslation',[0,0.1]);
    
    % Apply the transformation to the point cloud.
    ptCloudTransformed = pctransform(pc,tform);
    
    % Apply the same transformation to the boxes.
    bbox = data{2};
    [bbox,indices] = bboxwarp(bbox,tform,outView);
    if ~isempty(indices)
        data{1} = ptCloudTransformed;
        data{2} = bbox;
        data{3} = data{1,3}(indices,:);
    end

end