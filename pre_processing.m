clc
clear all
close all
data = load('JS04185.mat');

ecg = data.val(2, :);

f_s = 500;
N = length(ecg);
t = (0:N-1) / f_s;
f = (0:N-1) * (f_s / N);


hl_filter = hpf_lpf(ecg);

% figure
% plot(t, hl_filter);
% xlabel('Time (s)');
% ylabel('ECG Amplitude (mV)');
% title('HPF LPF Signal');

moving_avg = moving_avg_filter(hl_filter);

waveletSignal = wavelet_denoise(moving_avg, 5);

figure
plot(t, ecg);
xlabel('Time (s)');
ylabel('ECG Amplitude (mV)');
title('Original Signal');

figure
plot(t, waveletSignal);
xlabel('Time (s)');
ylabel('ECG Amplitude (mV)');
title('Moving Average applied');


assess_signals(ecg, waveletSignal, f_s);

