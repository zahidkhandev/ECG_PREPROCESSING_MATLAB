function ppg_salient_point_old(ppg_signal, fs, filter_order, low_cutoff, high_cutoff)

    ppg_derivative_1 = diff(ppg_signal);
    t_derivative_1 = (1:length(ppg_derivative_1)) / fs; 
    
    ppg_derivative_2 = diff(ppg_derivative_1);
    t_derivative_2 = (1:length(ppg_derivative_2)) / fs;
    
    [b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');
    
    filtered_vpg = filtfilt(b, a, ppg_derivative_1);
    
    filtered_apg = filtfilt(b, a, ppg_derivative_2);

    systolic_peaks = findSystolicPeak(ppg_signal);
    onset_points = findOnsetPoints(ppg_signal, systolic_peaks, 2);
    
    figure;
    
    subplot(3,1,1);
    plot((0:length(ppg_signal)-1) / fs, ppg_signal);
    title('Original PPG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold on;
    plot(systolic_peaks / fs, ppg_signal(systolic_peaks), 'rx');
    plot(onset_points / fs, ppg_signal(onset_points), 'bo');
    legend('PPG Signal', 'Systolic Peaks', 'Onset Points');

    % Plot the filtered VPG and APG
    subplot(3,1,2);
    plot(t_derivative_1, filtered_vpg);
    title('Filtered First Derivative - Velocity Plethysmograph (VPG)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold on;
    plot(t_derivative_1(systolic_peaks), filtered_vpg(systolic_peaks), 'rx');
    plot(t_derivative_1(onset_points), filtered_vpg(onset_points), 'bx');
    legend('VPG', 'Systolic Peaks', 'Onset Points');
    
    subplot(3,1,3);
    plot(t_derivative_2, filtered_apg);
    title('Filtered Second Derivative - Acceleration Plethysmogram (APG)');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold on;
    plot(t_derivative_2(systolic_peaks), filtered_apg(systolic_peaks), 'rx');
    plot(t_derivative_2(onset_points), filtered_apg(onset_points), 'bx');
    legend('APG', 'Systolic Peaks', 'Onset Points');
end



function systolic_peaks = findSystolicPeak(ppg_signal)
    threshold = 500;
    [~, systolic_peaks] = findpeaks(ppg_signal, 'MinPeakHeight', threshold);
end

function onset_points = findOnsetPoints(ppg_signal, systolic_peaks, window_size)
    onset_points = zeros(size(systolic_peaks));
    for i = 1:length(systolic_peaks)
        if i == 1
            start_idx = 1;
        else
            start_idx = systolic_peaks(i-1) + 1;
        end
        end_idx = systolic_peaks(i) - window_size;
        if end_idx < start_idx
            end_idx = start_idx;
        end
        [~, min_idx] = min(ppg_signal(start_idx:end_idx));
        onset_points(i) = start_idx + min_idx - 1;
    end
end

