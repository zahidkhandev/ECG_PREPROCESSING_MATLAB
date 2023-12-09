clc;
clear all;
close all;

fileName = 'ecg_70_bpm';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/generated/normal', matFileName);
data = load(data_path);

ecg_orig = data.ecg;

N = length(ecg_orig);
fs = 360;
t = (0:N-1) / fs;

start_time = 0.1;  % Start time should be 0 to include the first 20 seconds
end_time = 10;

start_sample = round(start_time * fs);
end_sample = round(end_time * fs);

ecg_segment = ecg_orig(start_sample:end_sample);
t_segment = t(start_sample:end_sample);

noise_stddev = 0.05;

noise = noise_stddev * randn(size(ecg_segment));

ecg_with_noise = ecg_segment + noise;

ecg_denoised = wdenoise(ecg_with_noise, 4, ...
    'Wavelet', 'sym10', ...
    'DenoisingMethod', 'UniversalThreshold', ...
    'ThresholdRule', 'hard', ...
    'NoiseEstimate', 'LevelDependent');

figure;
subplot(3,1,1);
plot(t_segment, ecg_segment);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t_segment, ecg_with_noise);
title('ECG Signal with Gaussian Noise');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t_segment, ecg_denoised);
title('ECG Signal denoised');
xlabel('Time (s)');
ylabel('Amplitude');

pqrst_plot(ecg_denoised, fs, t_segment, 10)

signal_power = sum(ecg_denoised.^2) / length(ecg_denoised);

noise_power = sum(noise.^2) / length(noise);

SNR_dB = 10 * log10(signal_power / noise_power);

fprintf('SNR: %.2f dB\n', SNR_dB);


denoising_methods = {'Bayes', 'SURE', 'UniversalThreshold'};
threshold_rules = {'soft', 'hard'};
wavelet_names = {'db1', 'db2', 'db3', 'db4', 'db5', 'db6', 'db7', 'db8', 'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8'};

for method = denoising_methods
    denoising_method = method{1}; % Extract the denoising method from the cell array

    for threshold_rule = threshold_rules
        threshold = threshold_rule{1}; % Extract the thresholding rule from the cell array

        for wname = wavelet_names
            wavelet_name = wname{1}; % Extract the wavelet name from the cell array

            ecg_denoised = wdenoise(ecg_with_noise, 4, ...
                'Wavelet', wavelet_name, ...
                'DenoisingMethod', denoising_method, ...
                'ThresholdRule', threshold, ...
                'NoiseEstimate', 'LevelDependent');

            % Calculate SNR for the denoised signal
            signal_power = sum(ecg_denoised.^2) / length(ecg_denoised);
            noise_power = sum(noise.^2) / length(noise);
            SNR_dB = 10 * log10(signal_power / noise_power);

            fprintf('Wavelet Name: %s, Denoising Method: %s, Threshold Rule: %s, SNR: %.2f dB\n', wavelet_name, denoising_method, threshold, SNR_dB);
        end
    end
end

