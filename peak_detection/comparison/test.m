clc;
clear all;
close all;

fileName = '216m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('', matFileName);

data = load(data_path);

ecg = data.val(1, :);

N = length(ecg);
Fs = 125;
t = (0:N-1) / Fs;

% 
fs = 360;

ecg = resample(ecg, fs, Fs);

N = length(ecg);

t = (0:N-1) / fs;

duration = N/fs;

% filter_order = 5;
% low_cutoff = 0.5;
% high_cutoff = 45;
% [b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (Fs / 2), 'bandpass');
% denoised_ecg = filtfilt(b, a, ecg);
% 
% window_size = 5;
% denoised_ecg = movmean(denoised_ecg, window_size);

level = 10;
wavelet_name = 'db6';
wt = modwt(ecg, level, wavelet_name);
wtrec = zeros(size(wt));
wtrec(4:7, :) = wt(4:7, :);

denoised_ecg = imodwt(wtrec, wavelet_name);
    
figure;

% Original ECG subplot
subplot(2, 1, 1);
plot(t, ecg);
title('Original ECG');
xlabel('Time (s)');
ylabel('Amplitude');

% Denoised ECG subplot
subplot(2, 1, 2);
plot(t, denoised_ecg);
title('Denoised ECG');
xlabel('Time (s)');
ylabel('Amplitude');

Q_points = wavelet_time_based(denoised_ecg, fs, t, duration);

Q_points = round(Q_points ./2.88);

% Ground truth Q points
ground_truth = [24, 115, 207, 298, 390, 481, 572, 664, 756, 847, 939, 1030, 1122, 1213, 1305, 1397, 1488, 1580, 1671, 1762, 1854, 1945, 2036, 2128, 2220, 2311, 2402, 2494, 2585, 2676, 2768, 2860, 2952, 3043, 3135, 3226, 3318, 3409, 3501, 3593, 3676, 3777, 3868, 3960, 4051, 4142, 4234, 4326, 4407, 4509, 4601, 4692, 4784, 4875, 4967, 5059, 5150, 5242, 5333, 5424, 5516, 5607, 5699, 5791, 5882, 5974, 6066, 6157, 6249, 6341, 6432, 6524, 6616, 6708, 6799, 6890, 6982, 7073, 7165, 7256, 7348, 7439];
threshold = 0; % Adjust as needed

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
