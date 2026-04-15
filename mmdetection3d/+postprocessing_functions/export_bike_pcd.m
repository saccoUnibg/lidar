function export_bike_pcd(pcd_list,root,test,bike_type)
    disp("Export bike pcd: --- Start ---");

    bikes_pcd_path = root + "/" + "pcd_classification" + "/" + bike_type + "/" + "test" + test;

    if exist(bikes_pcd_path,"dir")
        warning("Cartella gia' esistente, controllare: " + bikes_pcd_path);
        return
    end
    mkdir(bikes_pcd_path);
    for i = 1 : size(pcd_list,1)
        if ~isempty(pcd_list{i})
            pcd_fileName = fullfile(bikes_pcd_path, sprintf('pcd_bike_%03d.pcd', i));
            pcwrite(pcd_list{i},pcd_fileName,"Encoding","ascii");
        end
    end

    disp("Export bike pcd: --- OK ---");

end