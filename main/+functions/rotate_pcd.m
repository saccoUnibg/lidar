function ptCloudRotated = rotate_pcd(ptCloud,angle)

theta = deg2rad(angle);  % ad esempio ruota di 90° in senso antiorario
R = [cos(theta) -sin(theta) 0;
     sin(theta)  cos(theta) 0;
     0           0          1];

rotatedXYZ = (R * ptCloud.Location')';
ptCloudRotated = pointCloud(rotatedXYZ, 'Intensity', ptCloud.Intensity);
end