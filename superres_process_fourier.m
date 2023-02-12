function [superres_signal] = superres_process_fourier(signal_1, signal_2, signal_3, signal_4)
%SUPERRES_PROCESS 此处显示有关此函数的摘要
%   此处显示详细说明

    % signal
    resolution = signal_1.resolution * 2;
    downsample_ratio = signal_1.downsample_ratio / 2;
    superres_signal = SensorSignal(resolution, downsample_ratio);
    superres_signal.shift_vector = [0 0];
    superres_signal.T_0 = signal_1.T_0;

    intensity_threshold = superres_signal.T_0 * superres_signal.lightspeed;

    % super-res
    superres_signal.F1_VTX1 = img_superres_process_fourier(signal_1.F1_VTX1, signal_2.F1_VTX1, signal_3.F1_VTX1, signal_4.F1_VTX1);
    superres_signal.F1_VTX2 = img_superres_process_fourier(signal_1.F1_VTX2, signal_2.F1_VTX2, signal_3.F1_VTX2, signal_4.F1_VTX2);
    superres_signal.F2_VTX1 = img_superres_process_fourier(signal_1.F2_VTX1, signal_2.F2_VTX1, signal_3.F2_VTX1, signal_4.F2_VTX1);
    superres_signal.F2_VTX2 = img_superres_process_fourier(signal_1.F2_VTX2, signal_2.F2_VTX2, signal_3.F2_VTX2, signal_4.F2_VTX2);
    superres_signal.F3_VTX1 = img_superres_process_fourier(signal_1.F3_VTX1, signal_2.F3_VTX1, signal_3.F3_VTX1, signal_4.F3_VTX1);
    superres_signal.F3_VTX2 = img_superres_process_fourier(signal_1.F3_VTX2, signal_2.F3_VTX2, signal_3.F3_VTX2, signal_4.F3_VTX2);
    superres_signal.F4_VTX1 = img_superres_process_fourier(signal_1.F4_VTX1, signal_2.F4_VTX1, signal_3.F4_VTX1, signal_4.F4_VTX1);
    superres_signal.F4_VTX2 = img_superres_process_fourier(signal_1.F4_VTX2, signal_2.F4_VTX2, signal_3.F4_VTX2, signal_4.F4_VTX2);

    % diffencial value
    superres_signal.delta_F1 = superres_signal.F1_VTX2 - superres_signal.F1_VTX1 + superres_signal.F3_VTX1 - superres_signal.F3_VTX2;
    superres_signal.delta_F2 = superres_signal.F2_VTX2 - superres_signal.F2_VTX1 + superres_signal.F4_VTX1 - superres_signal.F4_VTX2;
    % intensity value
    superres_signal.intensity = superres_signal.F1_VTX1 + superres_signal.F1_VTX1 + superres_signal.F2_VTX1 + superres_signal.F2_VTX2...
                              + superres_signal.F3_VTX1 + superres_signal.F3_VTX2 + superres_signal.F4_VTX1 + superres_signal.F4_VTX2;

end


function [superres_frame] = img_superres_process_fourier(physical_frame_1, physical_frame_2, physical_frame_3, physical_frame_4)
%SUPERRES_PROCESS 此处显示有关此函数的摘要
%   此处显示详细说明

    res = size(physical_frame_1);
    superres_freq = zeros(2*res);
    % casting matrix
    cast_mat = [1,1,1,1; 1i,-1i,1i,-1i; 1i,1i,-1i,-1i; -1,1,1,-1];

    % go into frequency domain
    freq_1 = fftshift( fft2( physical_frame_1 ) );
    freq_2 = fftshift( fft2( physical_frame_2 ) );
    freq_3 = fftshift( fft2( physical_frame_3 ) );
    freq_4 = fftshift( fft2( physical_frame_4 ) );
    % super-res freq retrieve
    for n = 1 : res(1)
        y = n + res(1)/2;
        for m = 1 : res(2)
            x = m + res(2)/2;
            aliased_signal = [freq_1(n,m);...
                              freq_2(n,m) * exp( -1i*pi/2 * (m/res(2)-1/2) );...
                              freq_3(n,m) * exp( -1i*pi/2 * (n/res(1)-1/2) );...
                              freq_4(n,m) * exp( -1i*pi/2 * (m/res(2)+n/res(1)-1) ) ];
            casted = cast_mat \ aliased_signal;
            superres_freq( mod(y-1,2*res(1))+1, mod(x-1,2*res(2))+1 ) = casted(1);
            superres_freq( mod(y-1,2*res(1))+1, mod(x-1-res(2),2*res(2))+1 ) = casted(2);
            superres_freq( mod(y-1-res(1),2*res(1))+1, mod(x-1,2*res(2))+1 ) = casted(3);
            superres_freq( mod(y-1-res(1),2*res(1))+1, mod(x-1-res(2),2*res(2))+1 ) = casted(4);
        end
    end
    % back into normal domain
    superres_frame = abs( ifft2( ifftshift( superres_freq ) ) );
    % noise threshold
    superres_frame = (superres_frame>1e-10) .* superres_frame;
end
