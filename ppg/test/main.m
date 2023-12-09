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

ppg_salient_point(ppg, fs, t)

