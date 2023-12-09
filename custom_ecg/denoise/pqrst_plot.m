function pqrst_plot(ECG_signal, fs, time_vector, duration, ecg_orig)

    baseline = mean(ECG_signal);
    
    fprintf("BASELINE: %d", baseline);

    min_peak_height = 200;

    invalid_P_Count = 0;

    [~, R_loc] = findpeaks(ECG_signal, 'MinPeakHeight', min_peak_height);
    
    beatPeriod = duration / length(R_loc);

    % Initialize arrays to store P, Q, S, and T points
    P_points = NaN(size(R_loc));
    Q_points = NaN(size(R_loc));
    S_points = NaN(size(R_loc));
    T_points = NaN(size(R_loc));
    
    % Define the intervals for Q, S, P, and T point detection
    QRS_interval = round(0.120 * fs * beatPeriod); % 82 ms
    P_interval = round(0.22 * fs * beatPeriod);  % 220 ms
    T_interval = round(0.440 * fs * beatPeriod);  % 440 ms

    % Initialize an array to store RR intervals
    RR_intervals = NaN(size(R_loc) - 1);

    % Detect Q, S, P, and T points
    for i = 1:length(R_loc)
        r_peak = R_loc(i);

        % Detect Q point (smallest amplitude in the 82 ms preceding the R-peak)
        q_window = ECG_signal(max(1, r_peak - QRS_interval):r_peak);
        [~, q_index] = min(q_window);
        Q_points(i) = max(1, r_peak - QRS_interval) + q_index - 1;

        % Detect S point (smallest amplitude in the 82 ms following the R-peak)
        s_window = ECG_signal(r_peak:min(length(ECG_signal), r_peak + QRS_interval));
        [~, s_index] = min(s_window);
        S_points(i) = r_peak + s_index - 1;

        % Detect P point (biggest amplitude in the 198 ms prior to the Q point)
        p_window = ECG_signal(max(1, Q_points(i) - P_interval):Q_points(i));
        [~, p_index] = max(p_window);
        P_point_candidate = max(1, Q_points(i) - P_interval) + p_index - 1;
        P_points(i) = P_point_candidate;

        if ECG_signal(P_point_candidate) <=  0.1 * ECG_signal(r_peak)
            invalid_P_Count = invalid_P_Count + 1;
        end

        % Detect T point (biggest amplitude in the 398 ms next to the S point)
        t_window = ECG_signal(S_points(i):min(length(ECG_signal), S_points(i) + T_interval));
        [~, t_index] = max(t_window);
        T_points(i) = S_points(i) + t_index - 1;

        % If this is the first R-peak, skip RR interval calculation
        if i == 1
            continue;
        end

        RR_intervals(i - 1) = R_loc(i) - R_loc(i - 1);
    end

    % Plot ECG with PQRST points
    figure;
    plot(time_vector, ECG_signal, 'r');
    hold on;

    % Plot R peaks
    scatter(time_vector(R_loc), ECG_signal(R_loc), 'ko', 'filled', 'DisplayName', 'R Peaks');

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
    %plot(time_vector, ones(size(time_vector)) * baseline, 'k--', 'DisplayName', 'Baseline');
    
    % Plot the original ECG signal in red
    if nargin == 6
        plot(time_vector, ecg_orig, 'b', 'DisplayName', 'Original ECG');
    end

    xlabel('Time (s)');
    ylabel('ECG Signal');
    title('ECG Signal with PQRST Points');
    legend('Location', 'Best');
    grid on;
    
    fprintf("Invalid P Count: %d", invalid_P_Count);
end
