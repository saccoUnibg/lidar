function ptCloudRotated = rotate_pcd(ptCloud,angle)
            % NB: angolo in RAD
            Rz =[ cos(angle), -sin(angle),  0;
                  sin(angle),  cos(angle),  0;
                      0,           0,       1  ];

            xyz = ptCloud.Location;            % Nx3
            intensity = ptCloud.Intensity;     % Nx1
            xyz_rotated = (Rz * xyz')';
            ptCloudRotated = pointCloud(xyz_rotated, 'Intensity', intensity);
end