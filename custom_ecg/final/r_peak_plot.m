function r_peak_plot(ECG_signal, fs, time_vector)
    % Detect R peaks using findpeaks
    [~, R_loc] = findpeaks(ECG_signal, 'MinPeakHeight', 0.4);
    
    % Plot ECG with R peaks
    figure;
    plot(time_vector, ECG_signal);
    hold on;

    % Plot R peaks
    scatter(time_vector(R_loc), ECG_signal(R_loc), 'ro', 'filled', 'DisplayName', 'R Peaks');

    xlabel('Time (s)');
    ylabel('ECG Signal');
    title('ECG Signal with R Peaks');
    legend('Location', 'Best');
    grid on;

    disp(['Number of R Peaks: ', num2str(length(R_loc))]);
end
