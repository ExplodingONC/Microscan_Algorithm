classdef SensorSignal
    %SENSORSIGNAL 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        % physical
        resolution = [72 96]
        downsample_ratio = 10
        shift_vector = [0 0]
        T_0 = 50e-9
        lightspeed = 3e8;
        % signal
        F1_VTX1
        F1_VTX2
        F2_VTX1
        F2_VTX2
        F3_VTX1
        F3_VTX2
        F4_VTX1
        F4_VTX2
        delta_F1
        delta_F2
        intensity
    end
    
    methods
        function obj = SensorSignal(resolution, downsample_ratio)
            %SENSORSIGNAL 构造此类的实例
            %   此处显示详细说明
            obj.resolution = resolution;
            obj.downsample_ratio = downsample_ratio;
        end
        
        function [depth_map] = CalculateDistance(obj, varargin)
            %CALCULATEDISTANCE 此处显示有关此方法的摘要
            %   此处显示详细说明
            if nargin > 1
                padding_val = varargin{1};
            else
                padding_val = Inf;
            end
            depth_map = (obj.delta_F1 > 0) .* (obj.delta_F2 ./ (abs(obj.delta_F1) + abs(obj.delta_F2)) + 1) * 1/4 * obj.lightspeed * obj.T_0...
                      + (obj.delta_F1 <= 0) .* (-obj.delta_F2 ./ (abs(obj.delta_F1) + abs(obj.delta_F2)) + 3) * 1/4 * obj.lightspeed * obj.T_0;
            depth_map = fillmissing(depth_map, 'constant', padding_val);
        end

        function [obj] = minus(obj, obj1)
            %SCALEUP 此处显示有关此方法的摘要
            %   此处显示详细说明
            obj.F1_VTX1 = obj.F1_VTX1 - obj1.F1_VTX1; obj.F1_VTX1 = (obj.F1_VTX1>1e-16) .* obj.F1_VTX1;
            obj.F1_VTX2 = obj.F1_VTX2 - obj1.F1_VTX2; obj.F1_VTX2 = (obj.F1_VTX2>1e-16) .* obj.F1_VTX2;
            obj.F2_VTX1 = obj.F2_VTX1 - obj1.F2_VTX1; obj.F2_VTX1 = (obj.F2_VTX1>1e-16) .* obj.F2_VTX1;
            obj.F2_VTX2 = obj.F2_VTX2 - obj1.F2_VTX2; obj.F2_VTX2 = (obj.F2_VTX2>1e-16) .* obj.F2_VTX2;
            obj.F3_VTX1 = obj.F3_VTX1 - obj1.F3_VTX1; obj.F3_VTX1 = (obj.F3_VTX1>1e-16) .* obj.F3_VTX1;
            obj.F3_VTX2 = obj.F3_VTX2 - obj1.F3_VTX2; obj.F3_VTX2 = (obj.F3_VTX2>1e-16) .* obj.F3_VTX2;
            obj.F4_VTX1 = obj.F4_VTX1 - obj1.F4_VTX1; obj.F4_VTX1 = (obj.F4_VTX1>1e-16) .* obj.F4_VTX1;
            obj.F4_VTX2 = obj.F4_VTX2 - obj1.F4_VTX2; obj.F4_VTX2 = (obj.F4_VTX2>1e-16) .* obj.F4_VTX2;
            % diffencial value
            obj.delta_F1 = obj.F1_VTX2 - obj.F1_VTX1 + obj.F3_VTX1 - obj.F3_VTX2;
            obj.delta_F2 = obj.F2_VTX2 - obj.F2_VTX1 + obj.F4_VTX1 - obj.F4_VTX2;
            % intensity value
            obj.intensity = obj.F1_VTX1 + obj.F1_VTX1 + obj.F2_VTX1 + obj.F2_VTX2...
                          + obj.F3_VTX1 + obj.F3_VTX2 + obj.F4_VTX1 + obj.F4_VTX2;
        end
    
        function [scaled_obj] = Scale(obj, scale)
            %SCALE 此处显示有关此方法的摘要
            %   此处显示详细说明
            arguments
                obj SensorSignal
                scale {mustBeNumeric, mustBeFinite, mustBePositive}
            end
            if scale >= 1
                scaled_obj = ScaleUp(obj, scale);
            elseif scale < 1
                scaled_obj = ScaleDown(obj, scale);
            end
        end

        function [scaled_obj] = ScaleUp(obj, scale)
            %SCALEUP 此处显示有关此方法的摘要
            %   此处显示详细说明
            scaled_obj = obj;
            scaled_obj.resolution = obj.resolution * scale;
            scaled_obj.downsample_ratio = obj.downsample_ratio / scale;
            scaled_obj.shift_vector = obj.shift_vector * scale;
            scaled_obj.F1_VTX1 = imresize(obj.F1_VTX1, scale, "nearest");
            scaled_obj.F1_VTX2 = imresize(obj.F1_VTX2, scale, "nearest");
            scaled_obj.F2_VTX1 = imresize(obj.F2_VTX1, scale, "nearest");
            scaled_obj.F2_VTX2 = imresize(obj.F2_VTX2, scale, "nearest");
            scaled_obj.F3_VTX1 = imresize(obj.F3_VTX1, scale, "nearest");
            scaled_obj.F3_VTX2 = imresize(obj.F3_VTX2, scale, "nearest");
            scaled_obj.F4_VTX1 = imresize(obj.F4_VTX1, scale, "nearest");
            scaled_obj.F4_VTX2 = imresize(obj.F4_VTX2, scale, "nearest");
            % diffencial value
            scaled_obj.delta_F1 = scaled_obj.F1_VTX2 - scaled_obj.F1_VTX1 + scaled_obj.F3_VTX1 - scaled_obj.F3_VTX2;
            scaled_obj.delta_F2 = scaled_obj.F2_VTX2 - scaled_obj.F2_VTX1 + scaled_obj.F4_VTX1 - scaled_obj.F4_VTX2;
            % intensity value
            scaled_obj.intensity = scaled_obj.F1_VTX1 + scaled_obj.F1_VTX1 + scaled_obj.F2_VTX1 + scaled_obj.F2_VTX2...
                                 + scaled_obj.F3_VTX1 + scaled_obj.F3_VTX2 + scaled_obj.F4_VTX1 + scaled_obj.F4_VTX2;
        end

        function [scaled_obj] = ScaleDown(obj, scale)
            %SCALEDOWN 此处显示有关此方法的摘要
            %   此处显示详细说明
            scaled_obj = obj;
            scaled_obj.resolution = obj.resolution * scale;
            scaled_obj.downsample_ratio = obj.downsample_ratio / scale;
            scaled_obj.shift_vector = obj.shift_vector * scale;
            % have to manually obtain local mean value
            window = [0, scaled_obj.downsample_ratio - 1];
            sample_y = 1 : scaled_obj.downsample_ratio : obj.resolution(1);
            sample_X = 1 : scaled_obj.downsample_ratio : obj.resolution(2);
            % F1_VTX1
            scaled_obj.F1_VTX1 = movmean(scaled_obj.F1_VTX1, window, 1);
            scaled_obj.F1_VTX1 = movmean(scaled_obj.F1_VTX1, window, 2);
            scaled_obj.F1_VTX1 = scaled_obj.F1_VTX1(sample_y, sample_X);
            % F1_VTX2
            scaled_obj.F1_VTX2 = movmean(scaled_obj.F1_VTX2, window, 1);
            scaled_obj.F1_VTX2 = movmean(scaled_obj.F1_VTX2, window, 2);
            scaled_obj.F1_VTX2 = scaled_obj.F1_VTX2(sample_y, sample_X);
            % F2_VTX1
            scaled_obj.F2_VTX1 = movmean(scaled_obj.F2_VTX1, window, 1);
            scaled_obj.F2_VTX1 = movmean(scaled_obj.F2_VTX1, window, 2);
            scaled_obj.F2_VTX1 = scaled_obj.F2_VTX1(sample_y, sample_X);
            % F2_VTX2
            scaled_obj.F2_VTX2 = movmean(scaled_obj.F2_VTX2, window, 1);
            scaled_obj.F2_VTX2 = movmean(scaled_obj.F2_VTX2, window, 2);
            scaled_obj.F2_VTX2 = scaled_obj.F2_VTX2(sample_y, sample_X);
            % F3_VTX1
            scaled_obj.F3_VTX1 = movmean(scaled_obj.F3_VTX1, window, 1);
            scaled_obj.F3_VTX1 = movmean(scaled_obj.F3_VTX1, window, 2);
            scaled_obj.F3_VTX1 = scaled_obj.F3_VTX1(sample_y, sample_X);
            % F3_VTX2
            scaled_obj.F3_VTX2 = movmean(scaled_obj.F3_VTX2, window, 1);
            scaled_obj.F3_VTX2 = movmean(scaled_obj.F3_VTX2, window, 2);
            scaled_obj.F3_VTX2 = scaled_obj.F3_VTX2(sample_y, sample_X);
            % F4_VTX1
            scaled_obj.F4_VTX1 = movmean(scaled_obj.F4_VTX1, window, 1);
            scaled_obj.F4_VTX1 = movmean(scaled_obj.F4_VTX1, window, 2);
            scaled_obj.F4_VTX1 = scaled_obj.F4_VTX1(sample_y, sample_X);
            % F4_VTX2
            scaled_obj.F4_VTX2 = movmean(scaled_obj.F4_VTX2, window, 1);
            scaled_obj.F4_VTX2 = movmean(scaled_obj.F4_VTX2, window, 2);
            scaled_obj.F4_VTX2 = scaled_obj.F4_VTX2(sample_y, sample_X);
            % diffencial value
            scaled_obj.delta_F1 = scaled_obj.F1_VTX2 - scaled_obj.F1_VTX1 + scaled_obj.F3_VTX1 - scaled_obj.F3_VTX2;
            scaled_obj.delta_F2 = scaled_obj.F2_VTX2 - scaled_obj.F2_VTX1 + scaled_obj.F4_VTX1 - scaled_obj.F4_VTX2;
            % intensity value
            scaled_obj.intensity = scaled_obj.F1_VTX1 + scaled_obj.F1_VTX1 + scaled_obj.F2_VTX1 + scaled_obj.F2_VTX2...
                                 + scaled_obj.F3_VTX1 + scaled_obj.F3_VTX2 + scaled_obj.F4_VTX1 + scaled_obj.F4_VTX2;
        end
    end
end
