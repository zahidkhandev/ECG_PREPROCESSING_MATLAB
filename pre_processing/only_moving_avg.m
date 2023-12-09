clc
clear all;
close all;

folderType = 'AF';
fileName = strcat('48500010m');
mainFolderName = '485';
subFolderName = '00010';
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

x_slim1 = 0;
x_slim2 = 10;

data_path = fullfile('data/mimic_raw/', folderType, mainFolderName, subFolderName, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);
ecg_orig(isinf(ecg_orig)|isnan(ecg_orig)) = 0;

fs = 125;
N = length(ecg_orig);
t = (0:N-1) / fs;
f = (0:N-1) * (fs / N);
frequencies = f(1:N/2+1);

%Applying Wavelet transform
movSignal = moving_avg(ecg_orig, 5);

% Create a single figure with subplots for each signal
figure;

% Original ECG
subplot(2, 1, 1);
plot(t, ecg_orig);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Original Signal');
xlim([x_slim1, x_slim2]);


% Wavelet Denoised
subplot(2, 1, 2);
plot(t, movSignal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Moving average filter');
xlim([x_slim1, x_slim2]);

