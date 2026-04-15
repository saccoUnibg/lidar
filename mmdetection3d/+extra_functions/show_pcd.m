function show_pcd(ptCloud, title_pcd)

    figure()
    ax = pcshow(ptCloud,"ColorSource","Intensity","MarkerSize",15);
    set(ax,'XLim',[-80 80],'YLim',[-80 80]);   % scena più ampia
    title(title_pcd)
    axis on
    grid on
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    
    lidarPos = [-5 -3 1.7];
    
    % Direzione di vista:
    %  - x > 0  → guarda in avanti
    %  - y > 0  → guarda leggermente verso destra (dalla tua posizione laterale sinistra)
    %  - z < 0  → guarda leggermente verso il basso
    viewDir  = [1 0.3 -0.1];
    
    upDir    = [0 0 1];   % Z resta l'alto
    
    campos(ax, lidarPos);
    camtarget(ax, lidarPos + viewDir);
    camup(ax, upDir);
    
    camproj(ax, 'perspective');
    camva(ax, 25);

    colormap(ax, turbo);

    set(gcf,'color','w');
    set(gca,'color','w');
    set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
end