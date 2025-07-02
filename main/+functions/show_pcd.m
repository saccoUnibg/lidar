function show_pcd(ptCloud,title_pcd)
    close all
    figure(1)
    pcshow(ptCloud,"ColorSource","Intensity");
    title(title_pcd)
    axis on
    grid on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

