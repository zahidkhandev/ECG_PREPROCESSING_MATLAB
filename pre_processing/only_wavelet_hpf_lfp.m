clc
clear all;
close all;

x_slim1 = 0;
x_slim2 = 10;

folderType = 'SR_ONLY';
folderName = '254';
subFolderName  ='00007';
fileName = strcat(folderName, subFolderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/', folderType, folderName, subFolderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);

ecg_orig(isinf(ecg_orig)|isnan(ecg_orig)) = 0;

fs = 125;
N = length(ecg_orig);
t = (0:N-1) / fs;
f = (0:N-1) * (fs / N);
frequencies = f(1:N/2+1);

%Applying Wavelet transform
waveletSignal = wavelet_denoise(ecg_orig, 4);

%Applying HPF + LPF filter
hl_filter = hpf_lpf(waveletSignal, fs);
    
% Create a single figure with subplots for each signal
figure;

% Original ECG
subplot(3, 1, 1);
plot(t, ecg_orig);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Original Signal');
xlim([x_slim1, x_slim2]);


% Wavelet Denoised
subplot(3, 1, 2);
plot(t, waveletSignal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Wavelet Denoised');
xlim([x_slim1, x_slim2]);

% High pass low pass filter
subplot(3, 1, 3);
plot(t, hl_filter);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('High pass + Low pass');
xlim([x_slim1, x_slim2]);

snr_output1 = snr(ecg_orig, waveletSignal);
snr_output2 = snr(ecg_orig, hl_filter);
fprintf('SNR for Wavelet ECG: %.2f dB\n', snr_output1);
fprintf('SNR for HPF+LPF ECG: %.2f dB\n', snr_output2);


% snr_orig = snr(ecg_orig);
% 
% snr_denoised = snr(waveletSignal);
% 
% fprintf('SNR for Original ECG: %.2f dB\n', snr_orig);
% fprintf('SNR for Denoised ECG: %.2f dB\n', snr_denoised);

% out = hl_filter;
% 
% output_folder_path = fullfile('data/processed/', folderType);
% if ~exist(output_folder_path, 'dir')
%   mkdir(output_folder_path);
% end
% 
% output_path = fullfile('data/processed/', folderType, matFileName);
% save(output_path, 'out');
% 
% source_file_path_hea = fullfile('data/raw/', folderType, heaFileName);
% destination_file_path_hea = fullfile("data/processed/", folderType, heaFileName);
% 
% copyfile(source_file_path_hea, destination_file_path_hea);
