function show(ptCloud,title_pcd)
    figure(1)
    pcshow(ptCloud,"ColorSource","Intensity");
    title(title_pcd)
    axis on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

