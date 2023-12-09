close all;
clear;
clc;

data = load('data\mimic_raw\AF\442\00006\44200006m.mat');

raw_ecg = data.val(1, :);

dwtmode('per','nodisplay');
wname='sym8';
level=5;

ECG_signal=wden(raw_ecg,'modwtsqtwolog','h','mln',level,wname); 
fs = 125;

% Detect R-peaks using findpeaks
[~, R_loc] = findpeaks(ECG_signal, 'MinPeakHeight', 0.5, 'MinPeakDistance', fs / 2);

% Detect T-wave peaks
T_loc = R_loc + round(0.4 * fs);  % Assuming T-wave is around 400 ms after R-peak

% Create an array to separate complexes
separated_ECG = ECG_signal;
for i = 1:length(T_loc)
    if T_loc(i) <= length(separated_ECG)
        separated_ECG(T_loc(i)) = NaN;  % Insert NaN after T-wave
    end
end

% Plot the separated ECG complexes
figure;
plot(1:length(separated_ECG), separated_ECG);
xlabel('Sample');
ylabel('Amplitude');
title('Separated ECG Complexes (After T-Wave)');
