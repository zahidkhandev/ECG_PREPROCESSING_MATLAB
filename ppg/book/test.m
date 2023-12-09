clc;
clear all;
close all;

fileName = '25400008m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('225m.mat');

data = load(data_path);

ppg = data.val(5, 3000:4000);

N = length(ppg);
fs = 125;
t = (0:N-1) / fs;
Fc = 6/(fs/2);
m=6;    
Rs=18;

[b,a] = cheby2(m,Rs,Fc); 
ppg = filtfilt(b,a,ppg);

subplot(4,1,2);
plot(t, ppg);
title('Filtered PPG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

vpg = diff(ppg);
vpg_t = t(2:end); 

apg = diff(vpg);
apg_t = t(3:end);


% Feature extraction using ppg_peak_detector function
PPG_Loc = [1, 2, 3, 4, 5];
VPG_Loc = [1, 2, 3, 4];
APG_Loc = [1, 2, 3, 4, 5, 6];

[error_code, ppg_feature] = ppg_peak_detector(0, 1/fs, PPG_Loc, VPG_Loc, APG_Loc, ppg, vpg, apg);

% Plotting features
subplot(4,1,3);
bar(ppg_feature.TimeSpan);
title('TimeSpan Features');
xlabel('Feature Index');
ylabel('Time (s)');

subplot(4,1,4);
bar(ppg_feature.Amplitude);
title('Amplitude Features');
xlabel('Feature Index');
ylabel('Amplitude');