clc;
clear all;
close all;

fileName = '48500008m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/mimic_raw/AF/485/00008/', matFileName);

data = load(data_path);

ecg_orig = data.val(1, 1900:2900);

N = length(ecg_orig);

old_fs = 125;

t = (0:N-1) / old_fs;

fs = 360;

[ecg_resampled, tx] = resample_ecg(ecg_orig, t, fs);

start_time = 0.1;
end_time = 3;

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

subplot(3, 1, 1);
plot(t_segment, ecg_segment);
title('Original signal'); % Set title for the first subplot
xlabel('Time (s)');
ylabel('Amplitude');

wavelet_type = 'db4';
wt = modwt(ecg_segment, 7, wavelet_type);
wtrec = zeros(size(wt));
wtrec(4:8, :) = wt(4:8, :);
ecg_final_db4 = imodwt(wtrec, wavelet_type);

subplot(3, 1, 2);
plot(t_segment, ecg_final_db4);
title('Denoised db4');
xlabel('Time (s)');
ylabel('Amplitude');

wavelet_type = 'sym4';
wt = modwt(ecg_segment, 7, wavelet_type);
wtrec = zeros(size(wt));
wtrec(4:8, :) = wt(4:8, :);
ecg_final_sym4 = imodwt(wtrec, wavelet_type);

subplot(3, 1, 3);
plot(t_segment, ecg_final_sym4);
title('Denoised sym4');
xlabel('Time (s)');
ylabel('Amplitude');

    