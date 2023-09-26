clc
clear all;
close all;

data = load('data/SB/JS00115.mat');

ecg = data.val(1, :);
fs = 500;
N = length(ecg);
t = (0:N-1) / fs;
f = (0:N-1) * (fs / N);
frequencies = f(1:N/2+1);

hl_filter = hpf_lpf(ecg);
pl_filter = powerline_removal(hl_filter, fs);
waveletSignal = wavelet_denoise(pl_filter, 5);

% Create a single figure with subplots for each signal
figure;

% Original ECG
subplot(5, 1, 1);
plot(t, ecg);
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

% Wavelet Denoised
subplot(5, 1, 4);
plot(t, waveletSignal);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Wavelet Denoised');

% Moving Average Applied
out = zeros(1, N);
out(1) = waveletSignal(1);
out(N) = waveletSignal(N);

for i = 2:N - 3
    out(i) = (waveletSignal(i-1) + waveletSignal(i) + waveletSignal(i+1) + waveletSignal(i+2) + waveletSignal(i+3))/5; % 1 X 3 averaging filter
end

subplot(5, 1, 5);
plot(t, out);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('Moving Average Applied');

figure
subplot(4, 1, 1);

[Pxx,F] = periodogram(ecg,[],length(ecg),fs);
plot(F,10*log10(Pxx))

subplot(4, 1, 2);

[Pxx_out,F_out] = periodogram(out,[],length(out),fs);
plot(F,10*log10(Pxx_out))

subplot(4, 1, 3)
input_fft = fft(ecg)/N;
input_fft = 2 * abs(input_fft(1:N/2+1));
plot(frequencies, input_fft)

subplot(4, 1, 4)
output_fft = fft(out)/N;
output_fft = 2 * abs(output_fft(1:N/2+1));
plot(frequencies, output_fft)

%assess_signals(ecg, out, fs)
