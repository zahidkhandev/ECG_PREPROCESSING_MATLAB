function pqrst_plot(ECG_signal, fs, time_vector, filterType)
    % Detect R peaks using findpeaks
    [~, R_loc] = findpeaks(ECG_signal, 'MinPeakHeight', 0.5, 'MinPeakDistance', fs / 2);

    % Initialize arrays to store P, Q, S, and T points
    P_points = NaN(size(R_loc));
    Q_points = NaN(size(R_loc));
    S_points = NaN(size(R_loc));
    T_points = NaN(size(R_loc));

    % Define the intervals for Q, S, P, and T point detection
    QRS_interval = round(0.082 * fs); % 82 ms
    P_interval = round(0.198 * fs);  % 198 ms
    T_interval = round(0.398 * fs);  % 398 ms

    % Initialize an array to store RR intervals
    RR_intervals = NaN(size(R_loc) - 1);

    % Define the threshold for BV (0.1 * R peak amplitude)

    % Detect Q, S, P, and T points
    for i = 1:length(R_loc)
        BV_threshold = 0.1 * R_loc(i);
        r_peak = R_loc(i);

        % Detect Q point (smallest amplitude in the 82 ms preceding the R-peak)
        q_window = ECG_signal(max(1, r_peak - QRS_interval):r_peak);
        [~, q_index] = min(q_window);
        Q_points(i) = max(1, r_peak - QRS_interval) + q_index - 1;

        % Detect S point (smallest amplitude in the 82 ms following the R-peak)
        s_window = ECG_signal(r_peak:min(length(ECG_signal), r_peak + QRS_interval));
        [~, s_index] = min(s_window);
        S_points(i) = r_peak + s_index - 1;

        % If this is the first R-peak, skip RR interval calculation
        if i == 1
            continue;
        end

        % Calculate RR interval
        RR_intervals(i - 1) = R_loc(i) - R_loc(i - 1);

        % Detect P point (biggest amplitude in the 198 ms prior to the Q point)
        p_window = ECG_signal(max(1, Q_points(i) - P_interval):Q_points(i));
        [~, p_index] = max(p_window);
        P_points(i) = max(1, Q_points(i) - P_interval) + p_index - 1;

        % Check conditions for P-wave detection
        BV = max(p_window);
        R_amplitude = ECG_signal(R_loc(i));
        if BV >= BV_threshold * R_amplitude
            % P-wave detected
        else
            % Check RR interval for irregularity
            threshold = 0.2 * fs;  % Define your RR interval threshold
            if RR_intervals(i - 1) > threshold
                % Irregular RR interval, potential AF case
            else
                % Regular RR interval, discard P point
                P_points(i) = NaN;
            end
        end

        % Detect T point (biggest amplitude in the 398 ms next to the S point)
        t_window = ECG_signal(S_points(i):min(length(ECG_signal), S_points(i) + T_interval));
        [~, t_index] = max(t_window);
        T_points(i) = S_points(i) + t_index - 1;
    end

    % Plot ECG with PQRST points
    figure;
    plot(time_vector, ECG_signal);
    hold on;

    % Plot R peaks
    scatter(time_vector(R_loc), ECG_signal(R_loc), 'yo', 'filled', 'DisplayName', 'R Peaks');

    % Plot P point
    valid_P_points = P_points(~isnan(P_points));
    scatter(time_vector(valid_P_points), ECG_signal(valid_P_points), 'ro', 'filled', 'DisplayName', 'P Points');

    % Plot Q, S, and T points
    valid_Q_points = Q_points(~isnan(Q_points));
    valid_S_points = S_points(~isnan(S_points));
    valid_T_points = T_points(~isnan(T_points));
    scatter(time_vector(valid_Q_points), ECG_signal(valid_Q_points), 'go', 'filled', 'DisplayName', 'Q Points');
    scatter(time_vector(valid_S_points), ECG_signal(valid_S_points), 'bo', 'filled', 'DisplayName', 'S Points');
    scatter(time_vector(valid_T_points), ECG_signal(valid_T_points), 'co', 'filled', 'DisplayName', 'T Points');

    xlabel('Time (s)');
    ylabel('ECG Signal');
    title('ECG Signal with PQRST Points', filterType);
    legend('Location', 'Best');
    grid on;

    % Calculate intervals for PP, RR, QQ, SS, and TT
    PP_interval = diff(P_points(~isnan(P_points))) / fs; % in seconds
    RR_interval = diff(R_loc) / fs;
    QQ_interval = diff(Q_points(~isnan(Q_points))) / fs;
    SS_interval = diff(S_points(~isnan(S_points))) / fs;
    TT_interval = diff(T_points(~isnan(T_points))) / fs;

    % Calculate the frequencies for each interval
    PP_frequencies = 1 ./ PP_interval; % in Hz (cycles per second)
    RR_frequencies = 1 ./ RR_interval;
    QQ_frequencies = 1 ./ QQ_interval;
    SS_frequencies = 1 ./ SS_interval;
    TT_frequencies = 1 ./ TT_interval;

    % Calculate the median frequencies
    median_PP_frequency = median(PP_frequencies);
    median_RR_frequency = median(RR_frequencies);
    median_QQ_frequency = median(QQ_frequencies);
    median_SS_frequency = median(SS_frequencies);
    median_TT_frequency = median(TT_frequencies);

    fprintf('Median Frequency of PP Interval: %.2f Hz\n', median_PP_frequency);
    fprintf('Median Frequency of RR Interval: %.2f Hz\n', median_RR_frequency);
    fprintf('Median Frequency of QQ Interval: %.2f Hz\n', median_QQ_frequency);
    fprintf('Median Frequency of SS Interval: %.2f Hz\n', median_SS_frequency);
    fprintf('Median Frequency of TT Interval: %.2f Hz\n', median_TT_frequency);

    lowest_component = min([median_PP_frequency, median_RR_frequency, median_QQ_frequency, median_SS_frequency, median_TT_frequency]);
    highest_component = max([median_PP_frequency, median_RR_frequency, median_QQ_frequency, median_SS_frequency, median_TT_frequency]);

    lowest_component = lowest_component - 0.02;
    highest_component = highest_component + 0.02;

    fprintf('Lowest Component: %.2f Hz\n', lowest_component);
    fprintf('Highest Component: %.2f Hz\n', highest_component);
end
