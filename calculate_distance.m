function [depth_map] = calculate_distance(sensor_signal, lightspeed, T_0)
%CALCULATE_DISTANCE 此处显示有关此函数的摘要
%   此处显示详细说明

    depth_map = (sensor_signal.delta_F1 > 0) .* (sensor_signal.delta_F2 ./ (abs(sensor_signal.delta_F1) + abs(sensor_signal.delta_F2)) + 1) * 1/4 * lightspeed * T_0...
              + (sensor_signal.delta_F1 <= 0) .* (-sensor_signal.delta_F2 ./ (abs(sensor_signal.delta_F1) + abs(sensor_signal.delta_F2)) + 3) * 1/4 * lightspeed * T_0;

end

