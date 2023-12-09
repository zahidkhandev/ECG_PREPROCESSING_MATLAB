function ppg_salient_point(ppg, fs, t)

    vpg = diff(ppg);
    vpg_t = t(2:end); 
    
    apg = diff(vpg);
    apg_t = t(3:end);

    ppg_outline = isoutlier(ppg);

    mean_ppg = mean(ppg);

    threshold = 200;
    [~, systolic_peaks] = findpeaks(ppg, 'MinPeakHeight', threshold);
    
    onset_points = findOnsetPoints(ppg, systolic_peaks, 2);

    [w, x, y, z] = findVPGPoints(vpg, fs);

    figure;
    subplot(2,1,1);
    plot((0:length(ppg)-1) / fs, ppg);
    title('Original PPG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold on;
    plot(systolic_peaks / fs, ppg(systolic_peaks), 'rx');
    plot(onset_points / fs, ppg(onset_points), 'bo');
    legend('PPG Signal', 'Systolic Peaks', 'Onset Points');
    
    subplot(2,1,2);
    plot(vpg_t, vpg);
    hold on;
    plot(vpg_t(w), vpg(w), 'ro', 'MarkerFaceColor', 'r'); % w in red
    %plot(vpg_t(x), vpg(x), 'gx', 'MarkerFaceColor', 'g'); % x in green
    plot(vpg_t(y), vpg(y), 'bs', 'MarkerFaceColor', 'b'); % y in blue
    plot(vpg_t(z), vpg(z), 'ms', 'MarkerFaceColor', 'm'); % z in magenta
    legend('VPG Signal', 'w', 'y', 'z');
    title('VPG Signal with Identified Points');
    xlabel('Time (s)');
    ylabel('Amplitude');
    hold off;

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


function [w, x, y, z] = findVPGPoints(vpg, fs)
    % Find w (highest point in each cycle)
    [~, w] = findpeaks(vpg);

    % Find x (point where slope changes)
    vpg_derivative = diff(vpg);
    [~, x] = findpeaks(abs(vpg_derivative));

    % Find y (lowest point)
    [~, y] = findpeaks(-vpg);

    % Find z (nearest highest point to y)
    z = zeros(size(y));
    for i = 1:length(y)
        [~, idx] = max(vpg(1:y(i))); % Search left of y
        z(i) = idx;
    end
end
