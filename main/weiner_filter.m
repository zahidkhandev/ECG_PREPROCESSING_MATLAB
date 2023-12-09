clc
clear all;
close all;

folderType = 'SR_ONLY';
folderName = '055';
subFolderName = '00007';
fileName = strcat(folderName, subFolderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/mimic_raw/', folderType, folderName, subFolderName, matFileName);

data = load(data_path);

x = data.val(1, :);

% Define parameters
N = length(x);

% Compute the Discrete Fourier Transform (DFT) of the ECG signal 'x'
X = fft(x);

% Calculate the autocorrelation function
Rxx = ifft(X .* conj(X));

% Calculate the Wiener filter coefficients
H = 1 ./ Rxx;

% Apply the Wiener filter in the frequency domain
X_est = H .* fft(x);

% Inverse FFT to get the denoised ECG signal
x_est = ifft(X_est);

% Plot the original and denoised ECG signals
t = (0:N-1) / fs;
figure;
subplot(2,1,1);
plot(t, x);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(2,1,2);
plot(t, abs(x_est));
title('Denoised ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');