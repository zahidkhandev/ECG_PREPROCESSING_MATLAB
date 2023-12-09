clc;
clear all;
close all;

fileName = '115m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/bih_raw/115/', matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);

N = length(ecg_orig);

old_fs = 360;

t = (0:N-1) / old_fs;

fs = 360;

ecg_resampled = ecg_orig;

tx = t;

start_time = 0.1;
end_time = 4;

start_sample = round(start_time * fs);
end_sample = round(end_time * fs);

ecg_segment = ecg_resampled(start_sample:end_sample);
t_segment = tx(start_sample:end_sample);

wavelet_types = {'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8', 'sym10', 'db2', 'db3', 'db4', 'db5', 'db6', 'db7', 'db8', 'db9', 'db10'};

for i = 1:length(wavelet_types)

    wavelet_type = wavelet_types{i};
    wt = modwt(ecg_segment,7,wavelet_type);
    wtrec = zeros(size(wt));
    wtrec(4:8,:) = wt(4:8,:);
    ecg_clean = imodwt(wtrec,wavelet_type);

    fprintf('Symlet type: %s\n', wavelet_type);

    SNRcln = 10 * log10((mean(ecg_segment.^2)) / (mean((ecg_segment - ecg_clean).^2)));
    fprintf('SNR of the clean ECG signal: %.2f dB\n\n', SNRcln);

    if mod(i, 4) == 1
        figure;
    end

    subplot(4, 1, mod(i - 1, 4) + 1);
    plot(t_segment, ecg_clean);
    title(sprintf('ECG Signal with %s Wavelet Denoising', wavelet_type));
    xlabel('Time (s)');
    ylabel('Amplitude');
end

figure;
subplot(1, 1, 1);
plot(t_segment, ecg_segment);
