clc;
clear all;
close all;

fileName = '115m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/bih_raw/115/', matFileName);

data = load(data_path);

ecg_orig = data.val(1, 1:9000);

N = length(ecg_orig);

Fs = 360;
t = 1:length(ecg_orig);
tx = t / Fs;

level = 10;
wavelet_name = 'sym8';
wt = modwt(ecg_orig, level, wavelet_name);
wtrec = zeros(size(wt));
wtrec(4:7, :) = wt(4:7, :);

final_ecg = imodwt(wtrec, wavelet_name);

signal_power_final = sum(ecg_orig.^2);
noise_power_final = sum((ecg_orig - final_ecg).^2);

SNR_dB_final = 10 * log10(signal_power_final / noise_power_final);

figure;
subplot(2, 1, 1);
plot( ecg_orig, 'b');
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('ECG (mV)');


subplot(2, 1, 2);
plot( final_ecg, 'k');
title('ECG Signal after filtering');
xlabel('Time (s)');
ylabel('ECG (mV)');

disp(['SNR of the ECG signal ', num2str(SNR_dB_final), ' dB']);
