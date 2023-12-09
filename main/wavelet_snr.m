% clc
% clear all;
% close all;
% 
% folderName = '100';
% fileName = strcat(folderName, 'm');
% matFileName = strcat(fileName, '.mat');
% heaFileName = strcat(fileName, '.hea');
% 
% data_path = fullfile('data/bih_raw/', folderName, matFileName);
% 
% data = load(data_path);
% 
% ecg_orig = data.val(1, 5000:9000);
% 
% wname = 'sym8';
% 
% fs = 360;
% 
% ecg_signal1 = wdenoise(ecg_orig, 4, ...
%     'Wavelet', wname, ...
%     'DenoisingMethod', 'UniversalThreshold', ...
%     'ThresholdRule', 'soft', ...
%     'NoiseEstimate', 'LevelDependent');
% 
% % Plot the original and denoised signals
% figure;
% t = 1:length(ecg_orig);
% plot(t, ecg_orig, 'b', 'DisplayName', 'Original ECG Signal');
% hold on;
% plot(t, ecg_signal1, 'r', 'DisplayName', 'Denoised ECG Signal');
% xlabel('Sample Index');
% ylabel('Amplitude');
% title('Original and Denoised ECG Signals', wname);
% legend('Location', 'Best');
% grid on;
% 
% pqrst_plot(ecg_signal1, fs, t, wname);
% 
% SNR_dB = 20 * log10(mean(ecg_signal1.^2) / std(ecg_signal1.^2));
% fprintf('SNR of the original ECG signal: %.2f dB\n', SNR_dB);

clc
clear all;
close all;

folderName = '111';
fileName = strcat(folderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/bih_raw/', folderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, 1:3000);

fs = 360;

wname_list = {'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8'};

for i = 1:length(wname_list)
    wname = wname_list{i};

    ecg_signal1 = wdenoise(ecg_orig, 4, ...
        'Wavelet', wname, ...
        'DenoisingMethod', 'UniversalThreshold', ...
        'ThresholdRule', 'soft', ...
        'NoiseEstimate', 'LevelDependent');

    % Calculate RMSE
    N = length(ecg_orig);
    rmse = sqrt(sum((ecg_orig - ecg_signal1).^2) / N);

    % Calculate correlation coefficient (CC)
    x_bar = mean(ecg_orig);
    y_bar = mean(ecg_signal1);

    numerator = sum((ecg_orig - x_bar) .* (ecg_signal1 - y_bar));
    denominator_x = sqrt(sum((ecg_orig - x_bar).^2));
    denominator_y = sqrt(sum((ecg_signal1 - y_bar).^2));

    corrcoef = numerator / (denominator_x * denominator_y);

    SNR_dB = 20 * log10(mean(ecg_signal1.^2) / std(ecg_signal1.^2));

    if (SNR_dB>0)
        fprintf('For wname = %s:\n', wname);
        fprintf('RMSE: %.4f\n', rmse);
        fprintf('Correlation Coefficient: %.4f\n', corrcoef);
    else
    
        fprintf('SNR of the denoised ECG signal (wname = %s): %.2f dB\n', wname, SNR_dB);
    end
end

% Plot the original and denoised signals for 'sym8'
wname = 'sym8';

ecg_signal2 = wdenoise(ecg_orig, 4, ...
    'Wavelet', wname, ...
    'DenoisingMethod', 'UniversalThreshold', ...
    'ThresholdRule', 'soft', ...
    'NoiseEstimate', 'LevelDependent');


% Plot the original and denoised signals for 'sym8'
figure;
t = 1:length(ecg_orig);
plot(t, ecg_orig, 'b', 'DisplayName', 'Original ECG Signal');
hold on;
plot(t, ecg_signal2, 'r', 'DisplayName', 'Denoised ECG Signal (sym8)');
xlabel('Sample Index');
ylabel('Amplitude');
title('Original and Denoised ECG Signals (sym8)');
legend('Location', 'Best');
grid on;

pqrst_plot(ecg_signal2, fs, t, wname);
