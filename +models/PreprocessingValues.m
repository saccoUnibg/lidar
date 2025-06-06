classdef PreprocessingValues 
    properties
        max_distance
        denoise_threshold
        downsample_threshold
        elevation_threshold
    end
    
    methods
        function obj = PreprocessingValuesConstructor(max_distance,denoise_threshold,downsample_threshold,elevation_threshold)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.max_distance = max_distance;
            obj.denoise_threshold = denoise_threshold;
            obj.downsample_value = downsample_threshold;
            obj.elevation_threshold = elevation_threshold;
        end

        function obj = PreprocessingValues()
        end
    end
end

