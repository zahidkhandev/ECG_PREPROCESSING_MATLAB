clc;
clear all;

fileName = 'ecg_70_bpm';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/generated/normal', matFileName);

data = load(data_path);

ecg = data.ecg;

Fs = 360;
t = 1:length(ecg);
tx = t / Fs;

baseline_wander_amplitude_mV = 200;
baseline_wander_frequency = 0.02;

baseline_wander_signal = baseline_wander_amplitude_mV * sin(2 * pi * baseline_wander_frequency * tx);

ecg_with_baseline_wander = ecg + baseline_wander_signal;

signal_power_original = sum(ecg.^2);
noise_power_original = sum(baseline_wander_signal.^2);

SNR_dB_original = 10 * log10(signal_power_original / noise_power_original);

wavelets = {'db1', 'db2', 'db3', 'db4', 'db5', 'db6', 'db7', 'db8', 'db9', 'db10', 'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8', 'sym10'};
SNR_results = zeros(1, length(wavelets));

for i = 1:length(wavelets)
    wavelet_name = wavelets{i};
    level = 10; % Choose the level of decomposition

    wt = modwt(ecg_with_baseline_wander, level, wavelet_name);
    wtrec = zeros(size(wt));
    wtrec(4:8, :) = wt(4:8, :);

    final_ecg = imodwt(wtrec, wavelet_name);

    signal_power_final = sum(ecg.^2);
    noise_power_final = sum((ecg - final_ecg).^2);

    SNR_dB_final = 10 * log10(signal_power_final / noise_power_final);
    
    SNR_results(i) = SNR_dB_final;
end

% Print original SNR
disp(['Original SNR: ', num2str(SNR_dB_original), ' dB']);

% Print SNR results for various wavelets
for i = 1:length(wavelets)
    disp(['SNR with ', wavelets{i}, ': ', num2str(SNR_results(i)), ' dB']);
end
