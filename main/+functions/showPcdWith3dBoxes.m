function showPcdWith3dBoxes(ptCld,bboxes,labels,classNames,colors)
    % Validate the length of classNames and colors are the same
    assert(numel(classNames) == numel(colors), 'ClassNames and Colors must have the same number of elements.');
    
    % Get unique categories from labels
    uniqueCategories = categories(labels); 

    % Create a mapping from category to color
    colorMap = containers.Map(uniqueCategories, colors); 
    labelColor = cell(size(labels));

    % Populate labelColor based on the mapping
    for i = 1:length(labels)
        labelColor{i} = colorMap(char(labels(i)));
    end

    figure;
    ax = pcshow(ptCld,"ColorSource","Intensity"); 
    showShape('cuboid', bboxes, 'Parent', ax, 'Opacity', 0.1, ...
        'Color', labelColor, 'LineWidth', 0.5);

    for i = 1:size(bboxes,1)
        center = bboxes(i,1:3);           % centro del box
        height = bboxes(i,6);             % altezza del box
        labelStr = string(labels(i));     % etichetta
    
        % Sposta il testo sopra il box lungo Z
        text(center(1)-2, center(2), center(3) + height/2 + 2, labelStr, ...
             'Parent', ax, ...
             'FontSize', 10, ...
             'FontWeight', 'bold', ...
             'Color', labelColor{i});
    end

    zoom(ax,1.5);
    
    axis on
    grid on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end