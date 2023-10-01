clc
clear all;
close all;

folderType = 'AF';
fileName = strcat('JS02677');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/raw/', folderType, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);
ecg_orig(isinf(ecg_orig)|isnan(ecg_orig)) = 0;


fs = 125;
N = length(ecg_orig);
t = (0:N-1) / fs;
f = (0:N-1) * (fs / N);
frequencies = f(1:N/2+1);

%RESAMPLE SIGNAL To 125Hz
% [ecg, t] = resample_signal_125(ecg_orig, t_orig);

%Assigning new parameter
% fs = 125;
% N = length(ecg);
% f = (0:N-1) * (fs / N);


%Applying high pass and low pass filters
hl_filter = hpf_lpf(ecg_orig, fs);
pl_filter = powerline_removal(hl_filter, fs);
movSignal = moving_avg(pl_filter, 5);
waveletSignal = wavelet_denoise(movSignal, 5);

% Create a single figure with subplots for each signal
figure;

% Original ECG
subplot(5, 1, 1);
plot(t, ecg_orig);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Original Signal');

% HPF + LPF Filtered
subplot(5, 1, 2);
plot(t, hl_filter);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('HPF + LPF Signal');

% Powerline Removal
subplot(5, 1, 3);
plot(t, pl_filter);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Powerline Removal');

% Moving Average applied
subplot(5, 1, 4);
plot(t, movSignal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Moving Average Applied');

% Wavelet Denoised
subplot(5, 1, 5);
plot(t, waveletSignal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Wavelet Denoised');


out = waveletSignal;

figure
subplot(4, 1, 1);

[Pxx,F] = periodogram(ecg_orig,[],length(ecg_orig),fs);
plot(F,10*log10(Pxx))

title('Original Signal Spectrum');
xlabel('Frequency');

subplot(4, 1, 2);

[Pxx_out,F_out] = periodogram(out,[],length(out),fs);   
plot(F,10*log10(Pxx_out))

title('Output Signal Spectrum');
xlabel('Frequency');

subplot(4, 1, 3)
input_fft = fft(ecg_orig)/N;
input_fft = 2 * abs(input_fft(1:N/2+1));
plot(frequencies, input_fft)

title('Original Signal FFT');
xlabel('Frequency');

subplot(4, 1, 4)
output_fft = fft(out)/N;
output_fft = 2 * abs(output_fft(1:N/2+1));
plot(frequencies, output_fft)

title('Output Signal FFT');
xlabel('Frequency');

output_folder_path = fullfile('data/processed/', folderType);
if ~exist(output_folder_path, 'dir')
  mkdir(output_folder_path);
end

output_path = fullfile('data/processed/', folderType, matFileName);
save(output_path, 'out');

source_file_path_hea = fullfile('data/raw/', folderType, heaFileName);
destination_file_path_hea = fullfile("data/processed/", folderType, heaFileName);

copyfile(source_file_path_hea, destination_file_path_hea);

%assess_signals(ecg, out, fs)
