function Q_points = wavelet_time_based(ECG_signal, fs, time_vector, duration, ecg_orig)
    time = 1:length(ECG_signal);
    tx = time ./ fs;
    y1=ECG_signal;    
    wt = modwt(ECG_signal, 9, 'db1');
    wtrec = zeros(size(wt));
    wtrec(3:5, :) = wt(3:5, :);
    y = imodwt(wtrec, 'db1');
    y = abs(y) ;
    
    avg = mean(y);
    figure;
    plot(tx,y);
    tt = modwt(ECG_signal, 9, 'db1');
    twtrec = zeros(size(wt));
    twtrec(5:7,:) = tt(5:7, :);
    tp = imodwt(twtrec, 'db1');
    
    baseline = mean(ECG_signal);
    
    fprintf("BASELINE: %d", baseline);

    [~, R_loc] = findpeaks(y, 'MinPeakHeight', 8 * avg, 'MinPeakDistance', 100);    
    
    beatPeriod = duration / length(R_loc);

    Ac_R_points = NaN(size(R_loc));

    R_window_size = 4;
    for i = 1:length(R_loc)
        r_peak=(R_loc(i));
        R_window = y1(max(1, r_peak - R_window_size):min(length(y1), r_peak + R_window_size));
        if y1(r_peak)>0
        [~,actual_r_index]=max(R_window);
        end 
        if  y1(r_peak)<0
        [~,actual_r_index]=min(R_window);
        end 
        
         if isempty(actual_r_index)
            actal_r_index=0;
         end
       Ac_R_points(i) = max(1, r_peak - R_window_size) + actual_r_index - 1; 
    end 

    % Initialize arrays to store P, Q, S, and T points
    P_points = NaN(size(R_loc));
    Q_points = NaN(size(R_loc));
    S_points = NaN(size(R_loc));
    T_points = NaN(size(R_loc));
    
    R_window_size = 4;
    for i = 1:length(R_loc)
        r_peak=(R_loc(i));
        R_window = y1(max(1, r_peak - R_window_size):min(length(y1), r_peak + R_window_size));
        if y1(r_peak)>0
        [~,actual_r_index]=max(R_window);
        end 
        if  y1(r_peak)<0
        [~,actual_r_index]=min(R_window);
        end 
        
         if isempty(actual_r_index)
            actal_r_index=0;
         end
       Ac_R_points(i) = max(1, r_peak - R_window_size) + actual_r_index - 1; 
    end 
    
    % Define the intervals for Q, S, P, and T point detection
    QRS_interval = round(0.10 * fs ); % 82 ms
    P_interval = round(0.22 * fs );  % 220 ms
    T_interval = round(0.350 * fs );  % 440 ms

    % Initialize an array to store RR intervals
    RR_intervals = NaN(size(R_loc) - 1);

    % Detect Q, S, P, and T points
    for i = 1:length(R_loc)
        r_peak = (Ac_R_points(i));

        % Detect Q point (smallest amplitude in the 82 ms preceding the R-peak)
        q_window = y(max(1, r_peak - QRS_interval):r_peak-1);
        [~, q_index] = findpeaks (q_window,'NPeaks', 1,'SortStr','descend');
         if isempty(q_index)
            q_index=0;
        end
        Q_points(i) = max(1, r_peak - QRS_interval) + q_index - 1;

        % Detect S point (smallest amplitude in the 82 ms following the R-peak)
        s_window = y(r_peak+1:min(length(y), r_peak + QRS_interval));
        [~, s_index] = findpeaks(s_window,'NPeaks', 1,'SortStr','descend');
         if isempty(s_index)
            s_index=0;
        end
        S_points(i) = r_peak + s_index - 1;

        % Detect P point (biggest amplitude in the 198 ms prior to the Q point)
        p_window = tp(max(1, Q_points(i) - P_interval):Q_points(i)-1);
        [~, p_index] = findpeaks(p_window,'NPeaks', 1,'SortStr','descend');
        if isempty(p_index)
            p_index=0;
        end
         P_points(i) = max(1, Q_points(i) - P_interval) + p_index - 1;

        % Detect T point (biggest amplitude in the 398 ms next to the S point)
        t_window = tp(S_points(i)+1:min(length(tp), S_points(i) + T_interval));
       [~, t_index] = findpeaks(t_window,'NPeaks', 1,'SortStr','descend');
        if isempty(t_index)
            t_index=0;
        end
        T_points(i) = S_points(i) + t_index - 1;

        % If this is the first R-peak, skip RR interval calculation
        if i == 1
            continue;
        end

        RR_intervals(i - 1) = Ac_R_points(i) - Ac_R_points(i - 1);
    end

    % Plot ECG with PQRST points
    figure;
    plot(tx, y1, 'r');
    hold on;

    % Plot R peaks
    scatter(tx(round(Ac_R_points)), y1(round(Ac_R_points)), 'ko', 'filled', 'DisplayName', 'R Peaks');

    % Plot P point
    valid_P_points = P_points(~isnan(P_points));
    scatter(tx(valid_P_points), y1(valid_P_points), 'ro', 'filled', 'DisplayName', 'P Points');

    % Plot Q, S, and T points
    valid_Q_points = Q_points(~isnan(Q_points));
    valid_S_points = S_points(~isnan(S_points));
    valid_T_points = T_points(~isnan(T_points));
    scatter(tx(valid_Q_points), y1(valid_Q_points), 'go', 'filled', 'DisplayName', 'Q Points');
    scatter(tx(valid_S_points), y1(valid_S_points), 'bo', 'filled', 'DisplayName', 'S Points');
    scatter(tx(valid_T_points), y1(valid_T_points), 'co', 'filled', 'DisplayName', 'T Points');
  
    % Plot the original ECG signal in red
    if nargin == 6
        plot(time_vector, ecg_orig, 'b', 'DisplayName', 'Original ECG');
    end

    xlabel('Time (s)');
    ylabel('ECG Signal');
    title('ECG Signal with PQRST Points');
    legend('Location', 'Best');
    grid on;
    
    figure;
    plot(tx, y1, 'r');

end
