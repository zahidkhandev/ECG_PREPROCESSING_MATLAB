clc
clear all;
close all;

folderName = '438';
fileName = strcat(folderName, '00003m');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/AF/438/00003/', matFileName);

data = load(data_path);

ecg = data.val(2, 1:550);
ecg = resample(ecg,360,125);

Fs = 360;
t = 1:length(ecg);
tx = t ./ Fs;

a=modwt(ecg,10,'sym8');
b=zeros(size(a));
b(4:8,:)=a(4:8,:);

ecg_filtered=imodwt(b,'sym8');

signal_duration_seconds = (length(ecg_filtered) - 1) / Fs;


time_pqrst_plot_af_detection(ecg_filtered, Fs, tx, signal_duration_seconds);


figure;
subplot(2, 1, 1); % Create a subplot for the original ECG signal
plot(t, ecg);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(2, 1, 2); % Create a subplot for the filtered signal
plot(t, ecg_filtered);
title('Filtered Signal (MODWT)');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
