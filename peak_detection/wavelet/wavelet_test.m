clc;
clear all;
close all;

fileName = '105m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/bih_raw/105/', matFileName);
data = load(data_path);

ecg = data.val(1, 1:2000);

N = length(ecg_signal);
fs = 360;
t = (0:N-1) / fs;

wavelet_peak(ecg_signal, fs, t);


