function [superres_signal] = superres_process_iterative(signal_1, signal_2, signal_3, signal_4, step, term_con)
%SUPERRES_PROCESS 此处显示有关此函数的摘要
%   此处显示详细说明

    % start point borrowed from linear method result
    superres_signal_linear = superres_process_linear(signal_1, signal_2, signal_3, signal_4);
    depth_map_iter = CalculateDistance(superres_signal_linear);
    depth_map_iter = padarray(depth_map_iter, [2 2], 'replicate', 'both');

    % iterations
    for iter = 1:term_con(1)
        old_depth_map = depth_map_iter;
        % simulate projected signal
        iter_signal_1 = generate_sensor_signal(signal_1.resolution, 2, [0 0], (signal_1.shift_vector-signal_1.shift_vector), depth_map_iter, signal_1.T_0);
        iter_signal_2 = generate_sensor_signal(signal_2.resolution, 2, [0 0], (signal_2.shift_vector-signal_1.shift_vector), depth_map_iter, signal_2.T_0);
        iter_signal_3 = generate_sensor_signal(signal_3.resolution, 2, [0 0], (signal_3.shift_vector-signal_1.shift_vector), depth_map_iter, signal_3.T_0);
        iter_signal_4 = generate_sensor_signal(signal_4.resolution, 2, [0 0], (signal_4.shift_vector-signal_1.shift_vector), depth_map_iter, signal_4.T_0);
        % calculate difference
        %   linear diff is pointless here, as signal strength is not a linear product of distance
        %   both ref signal and iter signal will be required by back projection process
        % back projection
        iter_err_1 = imtranslate_general(imresize(back_projection(signal_1,iter_signal_1), 2, "nearest"), 2*(signal_1.shift_vector-signal_1.shift_vector), 'FillValues',0);
        iter_err_2 = imtranslate_general(imresize(back_projection(signal_2,iter_signal_2), 2, "nearest"), 2*(signal_2.shift_vector-signal_1.shift_vector), 'FillValues',0);
        iter_err_3 = imtranslate_general(imresize(back_projection(signal_3,iter_signal_3), 2, "nearest"), 2*(signal_3.shift_vector-signal_1.shift_vector), 'FillValues',0);
        iter_err_4 = imtranslate_general(imresize(back_projection(signal_4,iter_signal_4), 2, "nearest"), 2*(signal_4.shift_vector-signal_1.shift_vector), 'FillValues',0);
        % update
        iter_err_total = (iter_err_1 + iter_err_2 + iter_err_3 + iter_err_4) / 4;
        iter_err_total = padarray(iter_err_total, [2 2], 'replicate', 'both');
        depth_map_iter = depth_map_iter + step*iter_err_total;
        % termination condition
        if iter > 1
            old_max_total_err = max_total_err;
            old_avg_total_err = avg_total_err;
        end
        avg_total_err = mean(abs(iter_err_total),"all");
        max_total_err = (1+log(4)) * max(abs(iter_err_total),[],"all"); % since requirement is for 1/4 pixel, multiply by 4 here
        fprintf("Iteration %3d, total avg err: %.2fmm, max err: %.2fmm.\n", iter, 1e3*avg_total_err, 1e3*max_total_err);
        if avg_total_err < term_con(2) && max_total_err < term_con(3)
            break % accuracy satisfied
        end
        if iter > 1 && avg_total_err > 1.5 * old_avg_total_err
            depth_map_iter = old_depth_map;
            break % no longer convergence
        end
    end

    % output
    superres_signal = generate_sensor_signal(signal_1.resolution*2, 1, [0 0], [0 0], depth_map_iter, signal_1.T_0);
    superres_signal.shift_vector = signal_1.shift_vector;

end

% custom back-projection
%   careful when cal_dist returns zero
function dist_diff = back_projection(sig_ref, sig_iter)
    dist_ref = CalculateDistance(sig_ref);
    dist_iter = CalculateDistance(sig_iter);
    % valid if both returns a valid distance
    valid_mask = isfinite(dist_ref) & isfinite(dist_iter);
    % need compensation if reference is out of range but iteration still valid
    compensation_mask = ~isfinite(dist_ref) & isfinite(dist_iter);
    % generate difference for iteration
    dist_diff = dist_ref - dist_iter;
    dist_diff(~valid_mask) = 0;
    dist_diff(compensation_mask) = Inf;
end
