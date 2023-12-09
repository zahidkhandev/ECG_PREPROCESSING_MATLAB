function wavelet_peak(ecg, Fs, t)
    tx = t ./ Fs;
    wt = modwt(ecg, 10, 'db1');
    wtrec = zeros(size(wt));
    wtrec(4:5, :) = wt(4:5, :);
    y = imodwt(wtrec, 'db1');
    y = abs(y) .^ 2;
    avg = mean(y);
    y1=1.7*y;

    [Rpeaks, locs] = findpeaks(y, t, 'MinPeakHeight', 8 * avg, 'MinPeakDistance', 50);
    nohb = length(locs);
    timelimit = length(ecg) / Fs;
    hbpermin = (nohb * 60) / timelimit;
    disp(strcat('Heart Rate=', num2str(hbpermin)))

    % Calculate the duration of each cardiac cycle
    cycle_durations = zeros(1, nohb - 1);  % Initialize an array to store cycle durations

    for i = 2:nohb - 1
        % Calculate the time index of the current R-wave (Ri)
        Ri = locs(i);
    
        % Calculate the time index of the previous R-wave (Ri-1)
        Ri_minus_1 = locs(i - 1);
    
        % Calculate the time index of the next R-wave (Ri+1)
        Ri_plus_1 = locs(i + 1);
    
        % Calculate the duration of the current cardiac cycle (Ci)
        cycle_durations(i - 1) = (Ri_plus_1 - Ri_minus_1) / (2 * Fs);
    end

    % Display the durations of each cardiac cycle
    disp('Cardiac Cycle Durations:');
    disp(cycle_durations);
    
    % Calculate the average cardiac cycle duration
    avg_cycle_duration = mean(cycle_durations);
    disp(['Average Cardiac Cycle Duration: ' num2str(avg_cycle_duration) ' seconds']);
    
    % Calculate the sampling rate for each cardiac cycle
    sampling_rates = 1 ./ cycle_durations;
    
    % Calculate the number of samples between each cardiac cycle
    samples_between_cycles = diff(locs);
    
    % Create the x-axis values for the samples between cycles
    x_axis_samples = locs(2:end);
    
    % Define the window size for Q and S wave detection
    qrs_window_size = round(0.10 * Fs);  % 0.12 seconds at 360 Hz
    q_window_size = round(0.04 * Fs);  % 0.04 seconds at 360 Hz
    
    q_wave_positions = zeros(1, nohb);
    s_wave_positions = zeros(1, nohb);

    
    for i = 1:nohb
        % Determine the search window for Q-wave and S-wave detection
        q_window_start = max(1, round(locs(i)) - round(qrs_window_size / 2));
         q_window_end = (round(locs(i) )-1);
    
        s_window_end = min(length(ecg), locs(i) + round(qrs_window_size / 2));
        s_window_start = (round(locs(i) )+1);
    
        % Extract the samples within the Q and S windows
        q_window = y(q_window_start:q_window_end);
        s_window = y(s_window_start:s_window_end);
    
        % Determine Q-wave position
        if Rpeaks(i) >= 0
            [q_loc, q_index] = findpeaks(q_window);
        %else
            %[~, q_index] = findpeaks(q_window);
        end
        q_max=max(q_index);
        q_wave_positions(i) = q_window_start + q_max - 1;
    
        % Determine S-wave position
        if Rpeaks(i) >= 0
            [s_loc, s_index] = findpeaks(s_window);
       % else
            %[~, s_index] = findpeaks(s_window);
        end
        s_max=max(s_index);
        s_wave_positions(i) = s_window_start + s_max ;
    end
    
    % 
    % Define the search window for accurate R-wave detection
    search_window_size = 0;  % Number of samples before and after Ri
    accurate_R_positions = zeros(1, nohb);
    
    for i = 1:nohb
        Ri = locs(i);  % Location of the current R-wave
    
        % Determine the search window for accurate R-wave detection
        search_window_start = max(1, Ri - search_window_size);
        search_window_end = min(Ri + search_window_size, length(ecg));
    
        % Extract the amplitudes within the search window
        search_window = ecg(search_window_start:search_window_end);
    
        % Find the maximum and minimum amplitudes within the search window
        max_amplitude = max(search_window);
        min_amplitude = min(search_window);
    
        % Determine the R-wave position based on the maximum and minimum amplitudes
        if abs(max_amplitude) > abs(min_amplitude)
            accurate_R_positions(i) = search_window_start + find(search_window == max_amplitude) - 1;
        else
            accurate_R_positions(i) = search_window_start + find(search_window == min_amplitude) - 1;
        end
    end
    
    tt = modwt(ecg, 10, 'db1');
    twtrec = zeros(size(wt));
    twtrec(4:5,:) = tt(4:5, :);
    t = imodwt(twtrec, 'db1');
    t = abs(t) .^ 2;
    
    avg = mean(t);
    
    t_window_size = round(0.6 * Fs);  % 0.12 seconds at 360 Hz
    t_wave_positions = zeros(1, nohb);
    for i = 1:nohb
    t_window_end = min(length(ecg), s_wave_positions(i) + round(t_window_size / 2));
        t_window_start = (round(s_wave_positions(i) )+1);
        t_window = t(t_window_start:t_window_end);
        [t_loc, t_index] = findpeaks(t_window);
         t_max=max(t_index);
        t_wave_positions(i) = t_window_start + t_max - 1;
    end
    
    p_window_size = round(0.4 * Fs);  % 0.12 seconds at 360 Hz
    p_wave_positions = zeros(1, nohb);
    for i = 1:nohb
        p_window_start = max(1, round(q_wave_positions(i)) - round(p_window_size / 2));
         p_window_end = (round(q_wave_positions(i) )-1);
         p_window = t(p_window_start:p_window_end);
        [p_loc, p_index] = findpeaks(p_window);
         p_max=max(p_index);
        p_wave_positions(i) = p_window_start + p_max - 1;
    end


    % Plot the accurate R-wave, Q-wave, and S-wave positions on the ECG signal
    figure;
    title('ECG Signal');
    ylabel('Amplitude');
    plot(t, ecg);
    hold on;
    plot(accurate_R_positions, ecg(accurate_R_positions), 'ro', 'MarkerSize', 5);
    xlabel('Samples');
    title('Accurate R-wave Detection');
    grid on;
    
    
    hold on;
    plot(q_wave_positions, ecg(q_wave_positions), 'go', 'MarkerSize', 5);
    xlabel('Samples');
    title('Q-wave Detection');
    grid on;
    
    
    hold on;
    plot(s_wave_positions, ecg(s_wave_positions), 'bo', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS-wave Detection');
    grid on;
    
    hold on;
    plot(t_wave_positions, ecg(t_wave_positions), 'co', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS-wave Detection');
    grid on;
    
    hold on;
    plot(p_wave_positions, ecg(p_wave_positions), 'yo', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS-wave Detection');
    grid on;

end
