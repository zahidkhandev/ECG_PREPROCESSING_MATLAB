clc;
clear all;
close all;

fileName = '48500008m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/mimic_raw/AF/485/00008/', matFileName);

data = load(data_path);

ecg_orig = data.val(1, 1900:2900);

N = length(ecg_orig);

old_fs = 360;

t = (0:N-1) / old_fs;

Fs = 360;

[ecg, tx] = resample_ecg(ecg_orig, t, Fs);

% Define a 4-second interval
interval_start = 2 * Fs; % Start at 2 seconds
interval_end = 6 * Fs;   % End at 6 seconds

powerline_amplitude_mV = 50;
powerline_frequency = 50;
powerline_signal = powerline_amplitude_mV * sin(2 * pi * powerline_frequency * tx);

noise_amplitude_mV = 10;
random_noise = noise_amplitude_mV * randn(size(ecg));

ecg_with_noise = ecg + powerline_signal + random_noise;

total_noise = random_noise + powerline_signal;

signal_power_original = sum(ecg.^2);
noise_power_original = sum(total_noise.^2);

SNR_dB_original = 10 * log10(signal_power_original / noise_power_original);

wavelet_list = {'db8', 'sym8'};

signal_power_final = sum(ecg.^2);

mse_values = zeros(1, length(wavelet_list));

figure;
subplot(3, 1, 1);
plot(tx(interval_start:interval_end), ecg(interval_start:interval_end));
title('Original ECG Signal (4-second interval)');
xlabel('Time (s)');
ylabel('ECG (mV)');

for i = 1:length(wavelet_list)
    wavelet_name = wavelet_list{i};
    level = 10;
    wt = modwt(ecg_with_noise, level, wavelet_name);
    wtrec = zeros(size(wt));
    wtrec(4:8, :) = wt(4:8, :);

    final_ecg = imodwt(wtrec, wavelet_name);
    noise_power_final = sum((ecg - final_ecg).^2);

    SNR_DdB_final = 10 * log10(signal_power_final / noise_power_final);
    
    mse = mean((ecg(interval_start:interval_end) - final_ecg(interval_start:interval_end)).^2);
    mse_values(i) = mse;
    
    subplot(3, 1, i+1);
    plot(tx(interval_start:interval_end), final_ecg(interval_start:interval_end));
    title(['Denoised ECG Signal with ', wavelet_name, ' (4-second interval)']);
    xlabel('Time (s)');
    ylabel('ECG (mV)');
    
    disp(['SNR with ', wavelet_name, ': ', num2str(SNR_DdB_final), ' dB']);
    disp(['MSE with ', wavelet_name, ': ', num2str(mse)]);

    pqrst_plot( final_ecg(interval_start:interval_end), Fs, tx(interval_start:interval_end), 4);
end

disp(['SNR of the original ECG signal: ', num2str(SNR_dB_original), ' dB']);
disp(['MSE for db8: ', num2str(mse_values(1))]);
disp(['MSE for sym8: ', num2str(mse_values(2))]);
