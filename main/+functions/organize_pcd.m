function ptCloudOrganized= organize_pcd(ptCloud)

    % - https://it.mathworks.com/help/lidar/ug/object-detection-using-pointpillars-network.html
    % Qua dice di fare pcorganize su parametri lidar 

    % - https://it.mathworks.com/help/lidar/ug/unorgaized-to-organized-pointcloud-conversion.html#UnorganizedToOrganizedConversionOfPointCloudsExample-6
    % openExample('lidar/UnorganizedToOrganizedConversionOfPointCloudsExample')
    % Da qui prendo i parametri del Pandar64

    % https://arxiv.org/pdf/2112.12610
    % Qua dice che il pandaset usato per l'addestramento del modello è
    % stato realizzato con un Pandar64 -> II.A "Data Collection", pg. 2,
    % cerca "Pandar64"

    % vResolution = 64; parametro presente ma non utilizzato     
    hAngResolution = 0.2;
    vbeamAngles = [15.0000   11.0000    8.0000    5.0000    3.0000    2.0000    1.8333    1.6667    1.5000    1.3333    1.1667    1.0000    0.8333    0.6667 ...
                0.5000    0.3333    0.1667         0   -0.1667   -0.3333   -0.5000   -0.6667   -0.8333   -1.0000   -1.1667   -1.3333   -1.5000   -1.6667 ...
               -1.8333   -2.0000   -2.1667   -2.3333   -2.5000   -2.6667   -2.8333   -3.0000   -3.1667   -3.3333   -3.5000   -3.6667   -3.8333   -4.0000 ...
               -4.1667   -4.3333   -4.5000   -4.6667   -4.8333   -5.0000   -5.1667   -5.3333   -5.5000   -5.6667   -5.8333   -6.0000   -7.0000   -8.0000 ...
               -9.0000  -10.0000  -11.0000  -12.0000  -13.0000  -14.0000  -19.0000  -25.0000];

    hResolution = round(360/hAngResolution);
    params = lidarParameters(vbeamAngles,hResolution);
    ptCloudOrganized = pcorganize(ptCloud,params);
end