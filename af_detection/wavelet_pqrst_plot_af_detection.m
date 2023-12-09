function wavelet_pqrst_plot_af_detection(ecg, Fs, t)

    tx = t ./ Fs;
    a=modwt(ecg,10,'sym6');
    b=zeros(size(a));
    b(4:8,:)=a(4:8,:);
    y1=imodwt(b,'sym6');
    
    wt = modwt(y1, 9, 'db4');
    wtrec = zeros(size(wt));
    wtrec(3:4, :) = wt(3:4, :);
    y = imodwt(wtrec, 'db4');
  
    y = abs(y) ;
    avg = mean(y);
    [Rpeaks, locs] = findpeaks(y, t, 'MinPeakHeight', 7 * avg);
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
            [q_loc, q_index] = findpeaks(q_window,'NPeaks', 1,'SortStr','descend');
        % else
        %     [q_loc, q_index] = findpeaks(q_window);
        end
      
        q_wave_positions(i) = q_window_start + q_index - 1;
        % Determine S-wave position
        if Rpeaks(i) >= 0
            [s_loc, s_index] = findpeaks(s_window,'NPeaks', 1,'SortStr','descend');
       % else
            %[~, s_index] = findpeaks(s_window);
        end
        
        s_wave_positions(i) = s_window_start + s_index -1;
    end
    % 
    % Define the search window for accurate R-wave detection
    search_window_size = 8;  % Number of samples before and after Ri
    accurate_R_positions = zeros(1, nohb);
    for i = 1:nohb
        Ri = locs(i);  % Location of the current R-wave
        % Determine the search window for accurate R-wave detection
        search_window_start = max(1, Ri - search_window_size);
        search_window_end = min(Ri + search_window_size, length(ecg));
        % Extract the amplitudes within the search window
        search_window = ecg(search_window_start:search_window_end);
        % Find the maximum and minimum amplitudes within the search window
       
        % Determine the R-wave position based on the maximum and minimum amplitudes
        
        [peakr, R_index] = findpeaks(search_window,'NPeaks', 1,'SortStr','descend');
         % t_max=max(t_index);
         % a=;
        accurate_R_positions(i) = search_window_start+R_index - 1;
    end
    s_wave_positions1=s_wave_positions+25;
    q_wave_positions1=q_wave_positions-25;
    tt = modwt(ecg, 9, 'db1');
    twtrec = zeros(size(wt));
    twtrec(5:7,:) = tt(5:7, :);
    t = imodwt(twtrec, 'db1');
    
    % t1wtrec = zeros(size(wt));
    % t1wtrec(5:6,:) = tt(5:6 , :);
    % t1 = imodwt(t1wtrec, 'db4');
    % t=t.^2;
    figure;
    
    subplot(313)
    plot(t);
    title('6 and 7 level decomposed signal');
    ylabel('Amplitude');
    xlabel('Samples');
    grid on;
    
    subplot(312)
    plot(y1);
    title('3 and 4 level decomposed signal');
    ylabel('Amplitude');
    xlabel('Samples');
    grid on;
    
    subplot(311);
    plot(ecg);
    title('original signal');
    ylabel('Amplitude');
    xlabel('Samples');
    grid on;
    
    %t = abs(t) ;
    
    avg = mean(t);
    
    
    % figure;
    % plot(t);
    t_window_size = round(0.6* Fs);  % 0.12 seconds at 360 Hz
    t_wave_positions = zeros(1, nohb);
    for i = 1:nohb
    t_window_end = min(length(ecg), s_wave_positions(i) + round(t_window_size / 2));
        t_window_start =max (1,round(s_wave_positions1(i)));
        t_window = t(t_window_start:t_window_end);
        [peakt, t_index] = findpeaks(t_window,'NPeaks', 1,'SortStr','descend');
         % t_max=max(t_index);
         % a=;
        t_wave_positions(i) = t_window_start+t_index - 1;
    end
    
    p_window_size = round(0.6* Fs);  % 0.12 seconds at 360 Hz
    p_wave_positions = zeros(1, nohb);
    for i = 1:nohb
        p_window_start = max(1, round(q_wave_positions(i)) - round(p_window_size / 2));
         p_window_end = (round(q_wave_positions1(i) )-1);
         p_window = t(p_window_start:p_window_end);
        [p_loc, p_index] = findpeaks(p_window,'NPeaks', 1,'SortStr','descend');
        p_wave_positions(i) = p_window_start + p_index -1;
    end
    % Create a figure with multiple subplots
    figure;
    % Subplot 1: ECG Signal
    subplot(411);
    plot(y1);
    xlabel('Samples');
    title('ECG Signal');
    ylabel('Amplitude');
    grid on;
    % Subplot 2: R Peaks and Heart Rate
    subplot(412);
    plot(y);
    hold on;
    plot(locs, Rpeaks, 'ro');
    hold on;
    plot(q_wave_positions, y(q_wave_positions), 'go', 'MarkerSize', 5);
    hold on;
    plot(s_wave_positions, y(s_wave_positions), 'bo', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS Peaks');
    ylabel('Amplitude');
    grid on;
    
    subplot(413);
    plot(t);
    hold on;
    plot(t_wave_positions, t(t_wave_positions), 'mo', 'MarkerSize', 5);
    hold on;
    plot(p_wave_positions, t(p_wave_positions), 'ko', 'MarkerSize', 5);
    grid on;
    xlabel('Samples');
    title(' PT-wave Detection ');
    grid on;
    % Subplot 3: Samples Between Cardiac Cycles
    % subplot(413);
    % stem( samples_between_cycles, 'b', 'LineWidth', 1.5, 'Marker', 'o', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
    % title('Samples Between Cardiac Cycles');
    % xlabel('Sample Index');
    % ylabel('Samples');
    % grid on;
    % Plot the accurate R-wave, Q-wave, and S-wave positions on the ECG signal
    subplot(414)  % Add a new subplot for the accurate R-wave positions
    plot(y1);
    hold on;
    plot(accurate_R_positions, y1(accurate_R_positions), 'ro', 'MarkerSize', 5);
    xlabel('Samples');
    title('Accurate R-wave Detection');
    grid on;
    
    hold on;
    plot(q_wave_positions, y1(q_wave_positions), 'go', 'MarkerSize', 5);
    xlabel('Samples');
    title('Q-wave Detection');
    grid on;
    
    hold on;
    plot(s_wave_positions, y1(s_wave_positions), 'bo', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS-wave Detection');
    grid on;
    
    
    hold on;
    plot(t_wave_positions, y1(t_wave_positions), 'mo', 'MarkerSize', 5);
    xlabel('Samples');
    title('QRS-wave Detection');
    grid on;
    
    hold on;
    plot(p_wave_positions, y1(p_wave_positions), 'ko', 'MarkerSize', 5);
    xlabel('Samples');
    title('PQRST-wave Detection');
    ylabel('Amplitude');
    grid on;
end