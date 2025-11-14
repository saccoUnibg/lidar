function best_pcd = export_best_pcd(pcd_list,root,test,bike_type)
    disp("Export best pcd: --- Start ---");
    count = 0;
    index = 0;
    for i = 1 : size(pcd_list,1)
        if ~isempty(pcd_list{i})
            pcd_size = size(pcd_list{i}.Location,1)
            if count < pcd_size
                count = pcd_size;
                index = i;
            end
        end
    end

    best_pcd = pcd_list{index};
    % Export the best point cloud data to a file
    full_path = root + "/pcd_classification/" + bike_type + "/best_" + test + ".pcd";
    if ~exist(full_path,"file")
        disp("Export best pcd: --- Created ---");
        pcwrite(best_pcd, full_path );
    end
    disp("Export best pcd: --- OK ---");

end