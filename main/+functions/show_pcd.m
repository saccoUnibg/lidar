function show_pcd(ptCloud,title_pcd)

    figure()
    ax = pcshow(ptCloud,"ColorSource","Intensity");
    set(ax,'XLim',[-50 50],'YLim',[-40 40]);
    title(title_pcd)
    axis on
    grid on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
end

