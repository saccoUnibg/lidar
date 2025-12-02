function ax = get_trajectory(pcd_list,center_list)
    disp("Plot trajectory: --- Start ---");

    % elimino righe pcd_list e center_list vuote
    pcd_list(any(cellfun(@isempty, pcd_list), 2), :) = [];
    center_list(any(center_list == 0, 2), :) = [];
    
    figure;
    ax = axes;
    view(ax, 3);   % forza la visione 3D
    hold(ax, 'on');

    for i = 1: size(pcd_list,1)
        if mod(i,2)==0
            pcshow(pcd_list{i},"ColorSource","Intensity","MarkerSize",20,"Parent",ax);
            hold on;
        else
            % center_list(i,:) = [0];
        end
    end
    % center_list(all(center_list==0,2),:) = [];
    plot3(ax,center_list(:,1), center_list(:,2), center_list(:,3),'r-', 'LineWidth', 2);
    
    % --- CAMERA SETTINGS ---
    lidarPos = [0 -2 3];         % posizione (LiDAR nell'origine)
    viewDir  = [1 0.5 -0.25];       % rotazione a sinistra (0.2 = lieve)
    upDir    = [0 0 1];         % Z è l'alto

    campos(ax, lidarPos);
    camtarget(ax, lidarPos + viewDir);
    camup(ax, upDir);

    camproj(ax, 'perspective');
    camva(ax, 25);              % scena più ampia (default ~20–25)

    
    set(gcf,'color','w');
    set(gca,'color','w');
    set(gca, 'XColor', [0.15 0.15 0.15], 'YColor', [0.15 0.15 0.15], 'ZColor', [0.15 0.15 0.15])
    title(ax,"Trajectory")
    disp("Plot trajectory: --- OK ---");
end
