clc
clear all;
close all;

folderType = 'AF';

fileName = strcat('JS00290');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/raw/', folderType, matFileName);

data = load(data_path);

ecg_orig = data.val(1, :);
ecg_orig(isinf(ecg_orig)|isnan(ecg_orig)) = 0;

fs = 500;
N = length(ecg_orig);
t = (0:N-1) / fs;
f = (0:N-1) * (fs / N);
frequencies = f(1:N/2+1);


[peak_orig, loc_orig] = findpeaks(ecg_orig, fs);

peak_sel = [];
loc_sel = [];
j=1;

for i = (i:length(peak_orig))
    if (peak_orig(i) > 0.8)
        peak_sel(j) = peak_orig(i);
        loc_sel(j) = loc_orig(i);
    end
end

[Twave, loc_orig2] = findpeaks(ecg_orig, fs);
twave_sel = [];
j = 1;

for i = (1:length (Twave))
    if(peak_orig(i) > 0.35 && peak_orig(1) < 0.8)
        twave_sel(j) = twave(i);
        loc_sel2(j) = loc_orig2(i);
    end
end


ecg_inv = -ecg_orig;

[swave, loc_s] = findpeaks(ecg_inv, fs);

s_sel = [];
loc_sels = [];
j = 1;

for i = (1:length(swave))
    if(swave(i) > 0.15)
        s_sel(j) = swave(i);
        loc_sels(j) = loc_sels(i);
        j = j+1;
    end
end

for i =1 : length(s_sel)
    s_sel(i) = -s_sel(i);
end


plot(t, ecg_orig, 'k')
hold on;
plot(loc_sel2, twave_sel, 'yx')
hold on;