close all;
clear;
clc;

data = load('data\mimic_raw\AF\442\00006\44200006m.mat');

ecg_signal = data.val(1, :);

fs = 125;
% Define the frequency range for the bandpass filter (0.4 to 40 Hz)
low_frequency = 0.4;  % Lower cutoff frequency
high_frequency = 40;  % Upper cutoff frequency

% Design a bandpass filter
[b, a] = butter(1, [low_frequency, high_frequency] / (fs / 2), 'bandpass');

% Apply the bandpass filter to the ECG signal
filtered_signal = filtfilt(b, a, ecg_signal);

% Pan-Tompkins QRS complex detection
% Determine the width of the integration window (in samples)
integration_window_width = 0.12 * fs;  % Adjust as needed

% Calculate the derivative and square it
derivative_signal = diff(filtered_signal);
squared_signal = derivative_signal .^ 2;

% Integrate the squared signal
integration_window = ones(1, integration_window_width);
integrated_signal = conv(squared_signal, integration_window, 'same');

% Set a threshold for peak detection (adjust as needed)
threshold = 0.6;  % You may need to fine-tune this threshold

% Find QRS complex locations based on peak detection
[qrs_values, qrs_locations] = findpeaks(integrated_signal, 'MinPeakHeight', threshold, 'MinPeakDistance', 0.2 * fs);

% Define a window around each R-wave for Q, R, S, and T wave extraction (adjust the window size as needed)
window_size = 100;  % Adjust this value based on your data

% Initialize matrices to store the extracted P, Q, R, S, and T waves and their corresponding peaks
p_wave_signals = zeros(window_size, length(qrs_locations));
p_wave_peaks = zeros(1, length(qrs_locations));
q_wave_signals = zeros(window_size, length(qrs_locations));
r_wave_signals = zeros(window_size, length(qrs_locations));
s_wave_signals = zeros(window_size, length(qrs_locations));
t_wave_signals = zeros(window_size, length(qrs_locations));

% Extract P, Q, R, S, and T waves and their peaks
for i = 1:length(qrs_locations)
    r_peak = qrs_locations(i);
    if r_peak - 2 * window_size >= 1
        p_wave_signals(:, i) = ecg_signal(r_peak - 2 * window_size : r_peak - window_size - 1);
        [~, max_index] = max(p_wave_signals(:, i));
        p_wave_peaks(i) = r_peak - window_size - 1 + max_index;
    end
    if r_peak - window_size >= 1
        q_wave_signals(:, i) = ecg_signal(r_peak - window_size : r_peak - 1);
    end
    if r_peak + window_size <= length(ecg_signal)
        r_wave_signals(:, i) = ecg_signal(r_peak : r_peak + window_size - 1);
    else
        r_wave_signals(:, i) = nan(size(r_wave_signals, 1), 1);  % Assign NaN if beyond bounds
    end
    
    if r_peak + window_size <= length(ecg_signal)
        s_wave_signals(:, i) = ecg_signal(r_peak + 1 : r_peak + window_size);
    else
        s_wave_signals(:, i) = nan(size(s_wave_signals, 1), 1);  % Assign NaN if beyond bounds
    end
    
    if r_peak + 2 * window_size <= length(ecg_signal)
        t_wave_signals(:, i) = ecg_signal(r_peak + window_size + 1 : r_peak + 2 * window_size);
    else
        t_wave_signals(:, i) = nan(size(t_wave_signals, 1), 1);  % Assign NaN if beyond bounds
    end
end

 


% Plot or analyze the extracted P, Q, R, S, and T waves and their peaks
% For example, you can plot the P, Q, R, S, and T waves along with their peaks as follows:

% Plot P-waves
figure;
for i = 1:length(qrs_locations)
    subplot(ceil(sqrt(length(qrs_locations))), ceil(sqrt(length(qrs_locations))), i);
    plot(p_wave_signals(:, i));
    hold on;
    plot(p_wave_peaks(i), p_wave_signals(p_wave_peaks(i), i), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    title(['P-wave ', num2str(i)]);
end

% Plot Q-waves
figure;
for i = 1:length(qrs_locations)
    subplot(ceil(sqrt(length(qrs_locations))), ceil(sqrt(length(qrs_locations))), i);
    plot(q_wave_signals(:, i));
    title(['Q-wave ', num2str(i)]);
end

% Plot R-waves
figure;
for i = 1:length(qrs_locations)
    subplot(ceil(sqrt(length(qrs_locations))), ceil(sqrt(length(qrs_locations))), i);
    plot(r_wave_signals(:, i));
    title(['R-wave ', num2str(i)]);
end

% Plot S-waves
figure;
for i = 1:length(qrs_locations)
    subplot(ceil(sqrt(length(qrs_locations))), ceil(sqrt(length(qrs_locations))), i);
    plot(s_wave_signals(:, i));
    title(['S-wave ', num2str(i)]);
end

% Plot T-waves
figure;
for i = 1:length(qrs_locations)
    subplot(ceil(sqrt(length(qrs_locations))), ceil(sqrt(length(qrs_locations))), i);
    plot(t_wave_signals(:, i));
    title(['T-wave ', num2str(i)]);
end