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

start_time = 0.1;
end_time = 2;

start_sample = round(start_time * fs);
end_sample = round(end_time * fs);

ecg_segment = ecg_orig(start_sample:end_sample);
t_segment = t(start_sample:end_sample);

noise_stddev = 0.05;

noise = noise_stddev * randn(size(ecg_orig));

ecg_with_noise = ecg_orig + noise;

ecg_noise_segment = ecg_with_noise(start_sample:end_sample);

wavelet_types = {'sym4', 'sym8', 'sym10'};
denoising_methods = {'Minimax', 'SURE', 'UniversalThreshold'};

for i = 1:length(wavelet_types)
    wavelet_type = wavelet_types{i};
    
    for j = 1:length(denoising_methods)
        denoising_method = denoising_methods{j};
        
        ecg_clean = wdenoise(ecg_with_noise, 4, ...
            'Wavelet', wavelet_type, ...
            'DenoisingMethod', denoising_method, ...
            'ThresholdRule', 'hard', ...
            'NoiseEstimate', 'LevelDependent');

        SNRog = 10 * log10((mean(ecg_segment.^2)) / (mean((ecg_segment - ecg_noise_segment).^2)));
        fprintf('Symlet type: %s, Denoising Method: %s, Threshold Method: Hard\n', wavelet_type, denoising_method);

        ecg_clean_segment = ecg_clean(start_sample:end_sample);

        SNRcln = 10 * log10((mean(ecg_segment.^2)) / (mean((ecg_segment - ecg_clean_segment).^2)));
        fprintf('SNR of the clean ECG signal: %.2f dB\n\n', SNRcln);

        if mod(i, 3) == 1 && j == 1
            figure;  % Create a new figure for every sym wavelet and denoising method
        end

        subplot(3, 3, (i - 1) * 3 + j);
        plot(t_segment, ecg_clean_segment);
        title(sprintf('%s Wavelet Denoising, %s Denoising Method, Hard Threshold', wavelet_type, denoising_method));
        xlabel('Time (s)');
        ylabel('Amplitude');
    end
end
