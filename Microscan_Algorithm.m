%% start
    
    clearvars; clc;
    all_fig = findall(0, 'type', 'figure');
    close(all_fig);
    clearvars all_fig;
    start = tic;
    tic;

%% parameters

    % sensor
    res_X = 96; res_Y = 72;
    scene_ratio = 10;
    oversample_ratio = 20;
    % timing sequence
    T_0 = 50e-9;    % VTX1 = VTX2 = light_pulse = T_0, light_offset = T_0/2
    % other
    lightspeed = 3e8;
    % requirement
    accuracy = [5e-3 100e-3]; % accuracy requirement for the result

%% depth map
    
    dist_bk_upper = 10;
    dist_bk_lower = Inf;
    dist_ft = 1;

    % background
    scene_X = (res_X+2) * scene_ratio; scene_Y = (res_Y+2) * scene_ratio;
    depth_map = dist_bk_lower * ones(scene_Y, scene_X);
    depth_map(1:scene_Y/2,1:scene_X) = dist_bk_upper;
    % add details
    depth_map(211:530,101:105) = dist_ft;
    depth_map(211:530,201:210) = dist_ft;
    depth_map(211:530,301:315) = dist_ft;
    depth_map(211:530,401:420) = dist_ft;
    depth_map(211:530,501:525) = dist_ft;
    depth_map(211:530,601:630) = dist_ft;
    depth_map(211:530,701:735) = dist_ft;
    depth_map(211:530,801:840) = dist_ft;
    depth_map = imresize(depth_map, oversample_ratio/scene_ratio, "nearest");
    fprintf("Generate depth map. Time: %fs\n", toc); tic;

%% reference high-res signal
    
    distance_sample = 0:0.01:15;
    sample_signal = generate_sensor_signal_collimate(size(distance_sample), 1, [0 0], [0 0], distance_sample, T_0);
    reference_signal = generate_sensor_signal([res_Y res_X] * oversample_ratio, 1, [0 0], [0 0], depth_map, T_0);
    fprintf("Generate reference signal. Time: %fs\n", toc); tic;

%% physical signal

    offset = [0.0 0.0];
    physical_signal_1 = generate_sensor_signal([res_Y res_X], oversample_ratio, offset, [-0.25 -0.25], depth_map, T_0);
    physical_signal_2 = generate_sensor_signal([res_Y res_X], oversample_ratio, offset, [0.25 -0.25], depth_map, T_0);
    physical_signal_3 = generate_sensor_signal([res_Y res_X], oversample_ratio, offset, [-0.25 0.25], depth_map, T_0);
    physical_signal_4 = generate_sensor_signal([res_Y res_X], oversample_ratio, offset, [0.25 0.25], depth_map, T_0);
    fprintf("Generate physical signal. Time: %fs\n", toc); tic;

%% super-res process

    superres_signal_linear = superres_process_linear...
        (physical_signal_1,physical_signal_2,physical_signal_3,physical_signal_4);
    superres_signal_fourier = superres_process_fourier...
        (physical_signal_1,physical_signal_2,physical_signal_3,physical_signal_4);
    superres_signal_iterative = superres_process_iterative...
        (physical_signal_1,physical_signal_2,physical_signal_3,physical_signal_4, 0.5, [50 accuracy]);
    superres_signal_supp_iter = superres_process_suppressed_iterative...
        (physical_signal_1,physical_signal_2,physical_signal_3,physical_signal_4, 0.5, [50 accuracy], [1 0.25]);
    fprintf("Super-res process. Time: %fs\n", toc); tic;
    
%% calculation

    % reference
    distance_calc_ref = CalculateDistance(reference_signal, Inf);
    % original
    distance_calc_raw_1 = CalculateDistance(physical_signal_1, Inf);
    distance_calc_raw_2 = CalculateDistance(physical_signal_2, Inf);
    distance_calc_raw_3 = CalculateDistance(physical_signal_3, Inf);
    distance_calc_raw_4 = CalculateDistance(physical_signal_4, Inf);
    % super-res linear
    distance_calc_linear = CalculateDistance(superres_signal_linear, Inf);
    % super-res fourier
    distance_calc_fourier = CalculateDistance(superres_signal_fourier, Inf);
    % super-res iterative
    distance_calc_iterative = CalculateDistance(superres_signal_iterative, Inf);
    % super-res iterative
    distance_calc_supp_iter = CalculateDistance(superres_signal_supp_iter, Inf);

    fprintf("Retrieve depth map. Time: %fs\n", toc); tic;

%% display

    close all;

    figure('Name','Comparison','NumberTitle','off','Position',[60 75 1800 900]);

    % original scene
    subplot(3,4,1);
    imagesc(distance_calc_ref, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Original");
    subplot(3,4,2);
    imshow(reference_signal.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Original intensity");

    % raw point cloud
    subplot(3,4,3);
    imagesc(distance_calc_raw_1, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Physical");
    subplot(3,4,4);
    imshow(physical_signal_1.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Physical intensity");

    % super-res linear
    subplot(3,4,5);
    imagesc(distance_calc_linear, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Super-res linear");
    subplot(3,4,6);
    imshow(superres_signal_linear.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Super-res linear intensity");

    % super-res fourier
    subplot(3,4,7);
    imagesc(distance_calc_fourier, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Super-res fourier");
    subplot(3,4,8);
    imshow(superres_signal_fourier.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Super-res fourier intensity");

    % super-res iterative
    subplot(3,4,9);
    imagesc(distance_calc_iterative, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Super-res iterative");
    subplot(3,4,10);
    imshow(superres_signal_iterative.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Super-res iterative intensity");

    % super-res iterative
    subplot(3,4,11);
    imagesc(distance_calc_supp_iter, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Super-res suppressed iterative");
    subplot(3,4,12);
    imshow(superres_signal_supp_iter.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Super-res iterative intensity");

    % principle
    figure('Name','Signal Sample','NumberTitle','off');
    hold on;
    plot(distance_sample, sample_signal.delta_F1, "-", 'LineWidth',2);
    plot(distance_sample, sample_signal.delta_F2, "-", 'LineWidth',2);
    plot(distance_sample, 0.5*max(sample_signal.delta_F1)*ones(size(distance_sample)), "--k", 'LineWidth',1);
    plot(distance_sample, 0.5*min(sample_signal.delta_F1)*ones(size(distance_sample)), "--k", 'LineWidth',1);
    hold off;
    grid on;
    legend("\Delta F1","\Delta F2", "Location","northeast");

    fprintf("Result display. Time: %fs\n", toc); tic;

%% end
    
    fprintf( '\n' );
    toc(start);
    fprintf( '\n' );
