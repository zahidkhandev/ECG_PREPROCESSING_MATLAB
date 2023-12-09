clc;
clear all;
close all;

fileName = 'ecg_60_bpm';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/generated/normal', matFileName);

data = load(data_path);

ecg_signal = data.ecg;

N = length(ecg_signal);
fs = 360;
t = (0:N-1) / fs;

duration = N / fs;

pqrst_plot(ecg_signal, fs, t,duration);

