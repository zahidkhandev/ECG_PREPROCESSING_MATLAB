clc;
clear all;
close all;

fileName = '25400008m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('443m.mat');

data = load(data_path);

ppg = data.val(5, 3000:4000);

N = length(ppg);
fs = 125;
t = (0:N-1) / fs;
Fc = 6/(fs/2);
m=6;
Rs=18;


% Plot the original and filtered PPG signals
figure;
subplot(4,1,1);
plot(t, ppg);
title('Original PPG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

[b,a] = cheby2(m,Rs,Fc); 
ppg = filtfilt(b,a,ppg);

subplot(4,1,2);
plot(t, ppg);
title('Filtered PPG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

ppg_derivative_1 = diff(ppg);
t_derivative_1 = t(2:end); 

ppg_derivative_2 = diff(ppg_derivative_1);
t_derivative_2 = t(3:end);

filter_order = 5;
low_cutoff = 0.5;
high_cutoff = 5;

[b, a] = butter(filter_order, [low_cutoff, high_cutoff] / (fs / 2), 'bandpass');

filtered_vpg = ppg_derivative_1;

filtered_apg = ppg_derivative_2;

subplot(4,1,3);
plot(t_derivative_1, filtered_vpg);
title('Filtered First Derivative - Velocity Plethysmograph (VPG)');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(4,1,4);
plot(t_derivative_2, filtered_apg);
title('Filtered Second Derivative - Acceleration Plethysmogram (APG)');
xlabel('Time (s)');
ylabel('Amplitude');

ppg_salient_point_old(ppg, fs, 5, 0.5, 5);

