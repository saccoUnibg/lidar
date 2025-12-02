function ground_slope_list = get_ground_slope(ground_equation_list)
    numFiles = size(ground_equation_list,1);
    ground_slope_list = zeros(numFiles,1);
    for i = 1 : numFiles
        a = ground_equation_list(i,1);
        b = ground_equation_list(i,1);

        if(a==0 && b==0)
            continue;
        end

        theta = atan( sqrt(a^2 + b^2) );        % in radianti
        ground_slope_list(i) = rad2deg(theta);  % in gradi
    end
end