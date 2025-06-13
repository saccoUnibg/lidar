function show(ptCloud)
    figure(1)
    pcshow(ptCloud,"ColorSource","Intensity");
    axis on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

