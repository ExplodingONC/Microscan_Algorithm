function [signal] = sensor_downscale(signal)
%SENSOR_DOWNSCALE 此处显示有关此函数的摘要
%   此处显示详细说明

    downscale_ratio = signal.downsample_ratio;

    if downscale_ratio > 1
        signal.F1_VTX1 = image_downscale(signal.F1_VTX1, downscale_ratio);
        signal.F1_VTX2 = image_downscale(signal.F1_VTX2, downscale_ratio);
        signal.F2_VTX1 = image_downscale(signal.F2_VTX1, downscale_ratio);
        signal.F2_VTX2 = image_downscale(signal.F2_VTX2, downscale_ratio);
        signal.F3_VTX1 = image_downscale(signal.F3_VTX1, downscale_ratio);
        signal.F3_VTX2 = image_downscale(signal.F3_VTX2, downscale_ratio);
        signal.F4_VTX1 = image_downscale(signal.F4_VTX1, downscale_ratio);
        signal.F4_VTX2 = image_downscale(signal.F4_VTX2, downscale_ratio);
    end

    signal.delta_F1 = signal.F1_VTX2 - signal.F1_VTX1 + signal.F3_VTX1 - signal.F3_VTX2;
    signal.delta_F2 = signal.F2_VTX2 - signal.F2_VTX1 + signal.F4_VTX1 - signal.F4_VTX2;

    % intensity value
    signal.intensity = signal.F1_VTX1 + signal.F1_VTX1 + signal.F2_VTX1 + signal.F2_VTX2...
                            + signal.F3_VTX1 + signal.F3_VTX2 + signal.F4_VTX1 + signal.F4_VTX2;

end


function [img_out] = image_downscale(img_in, downscale_ratio)
%IMAGE_DOWNSCALE 此处显示有关此函数的摘要
%   此处显示详细说明

    arguments
        img_in (:,:)
        downscale_ratio {mustBeNumeric, mustBeFinite, mustBePositive}
    end
    
    [height_in,width_in] = size(img_in);
    height = floor(height_in / downscale_ratio);
    width = floor(width_in / downscale_ratio);
    
    % don't use imresize-nearest, since avg value is needed here
    img_out = zeros(height, width);
    for y = 1:height
        for x = 1:width
            sample = img_in( (y-1)*downscale_ratio+1 : ((y))*downscale_ratio ,...
                             (x-1)*downscale_ratio+1 : ((x))*downscale_ratio );
            img_out(y,x) = mean(sample, "all");
        end
    end

end