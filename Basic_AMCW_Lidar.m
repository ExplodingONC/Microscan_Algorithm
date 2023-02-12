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

%% reference
    
    reference_signal = generate_sensor_signal([res_Y res_X] * oversample_ratio, 1, [0 0], [0 0], depth_map, T_0);

%% downsampled

    offset = [0 0];
    physical_signal = generate_sensor_signal([res_Y res_X], oversample_ratio, offset, [0 0], depth_map, T_0);

%% calculation

    % reference
    distance_calc_ref = CalculateDistance(reference_signal, Inf);
    % original
    distance_calc_raw = CalculateDistance(physical_signal, Inf);

%% display

    figure('Name','Comparison','NumberTitle','off','Position',[150 150 1000 800]);
    
    % original scene
    subplot(2,2,1);
    imagesc(distance_calc_ref, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Original");
    subplot(2,2,2);
    imshow(reference_signal.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Original intensity");

    % raw point cloud
    subplot(2,2,3);
    imagesc(distance_calc_raw, [0 T_0*lightspeed]);
    colormap(gca,flipud(parula));
    colorbar;
    daspect([1 1 1]);
    title("Physical");
    subplot(2,2,4);
    imshow(physical_signal.intensity,[0 Inf]);
    colorbar;
    daspect([1 1 1]);
    title("Physical intensity");

%% end
    
    fprintf( '\n' );
    toc(start);
    fprintf( '\n' );
