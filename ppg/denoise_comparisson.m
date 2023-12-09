clc; clear all; close all;

fileName = '28400008m';
matFileName = strcat(fileName, '.mat');
data_path = fullfile('225m.mat');
data = load(data_path);
ppg = data.val(5, 5000:6000);
N = length(ppg); 
fs = 125;
Fc = 6/(fs/2);
t = (0:N-1)/fs;
m=6;
Rs=18;

%% Bandpass filter 
[b,a] = butter(6, Fc);
ppg_bpf = filtfilt(b,a,ppg);
%% Chebyshev 2 filter
[b,a] = cheby2(m,Rs,Fc); 
ppg_cheb2 = filtfilt(b,a,ppg);
%% Plot 
figure;

subplot(311);
plot(t, ppg);
title("Original signal (MIMIC 401)")
ylabel('Amplitude (mV)');
xlabel('Time (s)');

subplot(312);
plot(t, ppg_bpf);
title("Denoised using band pass filter");
ylabel('Amplitude (mV)');
xlabel('Time (s)');
subplot(313);
plot(t, ppg_cheb2);
title("Denoised using Chebyshev II filter");

ylabel('Amplitude (mV)');
xlabel('Time (s)');

