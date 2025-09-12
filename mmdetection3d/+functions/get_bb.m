function [boxes,labels,scores] = get_bb(jsonFile)

raw = jsondecode(fileread(jsonFile));

labels = raw.labels_3d(:);
scores = raw.scores_3d(:);
boxes  = raw.bboxes_3d;  % Nx7: [x y z dx dy dz yaw]
end