function plot_trajectory(pcd_list,center_list)
    disp("Plot trajectory: --- Start ---");

    % elimino righe pcd_list e center_list vuote
    pcd_list(any(cellfun(@isempty, pcd_list), 2), :) = [];
    center_list(any(center_list == 0, 2), :) = [];

    % elimina le righe dove tutti gli elementi sono 0

    for i = 1: size(pcd_list,1)
        if mod(i,2)==0
            pcshow(pcd_list{i},"ColorSource","Intensity");
            hold on;
        else
            center_list(i,:) = [0];
        end
    end
    center_list(all(center_list==0,2),:) = [];
    plot3(center_list(:,1), center_list(:,2), center_list(:,3),'r-', 'LineWidth', 2);
    hold off;
    title("Trajectory")
    disp("Plot trajectory: --- OK ---");
end
