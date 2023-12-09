data = load('216m.mat');
ecg = data.val(1,1:1000);
duration=length(ecg);

% only if it is mitbih dataset
ecg = resample(ecg,360,125);

fs = 360;  % Adjusted sampling rate
time = 1:length(ecg);
tx = time ./ fs;

baseline = mean(ecg);
y1=ecg;    
fprintf("BASELINE: %d", baseline);

min_peak_height = 200;
invalid_P_Count = 0;

wt = modwt(ecg, 9, 'db1');
wtrec = zeros(size(wt));
wtrec(3:5, :) = wt(3:5, :);
y = imodwt(wtrec, 'db1');
y = y ;

avg = mean(y);
figure;
plot(tx,y);
tt = modwt(ecg, 9, 'db1');
twtrec = zeros(size(wt));
twtrec(5:7,:) = tt(5:7, :);
tp = imodwt(twtrec, 'db1');

[~, R_loc] = findpeaks(y, 'MinPeakHeight', 8 * avg, 'MinPeakDistance', 100);    
    
beatPeriod = duration / length(R_loc);
    Ac_R_points = NaN(size(R_loc));

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
  

    Q_points = round(Q_points ./2.88);

    % Ground truth Q points
    ground_truth = [24, 115, 207, 298, 390, 481, 572, 664, 756, 847, 939, 1030, 1122, 1213, 1305, 1397, 1488, 1580, 1671, 1762, 1854, 1945, 2036, 2128, 2220, 2311, 2402, 2494, 2585, 2676, 2768, 2860, 2952, 3043, 3135, 3226, 3318, 3409, 3501, 3593, 3676, 3777, 3868, 3960, 4051, 4142, 4234, 4326, 4407, 4509, 4601, 4692, 4784, 4875, 4967, 5059, 5150, 5242, 5333, 5424, 5516, 5607, 5699, 5791, 5882, 5974, 6066, 6157, 6249, 6341, 6432, 6524, 6616, 6708, 6799, 6890, 6982, 7073, 7165, 7256, 7348, 7439];
    threshold = 1; % Adjust as needed


    correct_count = 0;

    for i = 1:length(Q_points)
        match_found = any(abs(Q_points(i) - ground_truth) <= threshold);
        if match_found
            correct_count = correct_count + 1;
        end
    end
    
    % Calculate accuracy
    accuracy = (correct_count / length(Q_points)) * 100;
    
    disp(['Accuracy: ' num2str(accuracy) '%']);