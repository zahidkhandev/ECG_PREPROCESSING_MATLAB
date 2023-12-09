clc; 
clear all; 
close all;

data_path = fullfile('225m.mat');
data = load(data_path);
ecg = data.val(1, 5000:5350);

N = length(ecg);
fs = 125;
t = (0:N-1)/fs;

figure;
subplot(2, 1, 1);
plot(t, ecg);
title('Original ECG Signal');
xlabel('Sample');
ylabel('Amplitude');

min_value = min(ecg);
max_value = max(ecg);

normalized_ecg = round(15 * (ecg - min_value) / (max_value - min_value));
binary_ecg = dec2bin(normalized_ecg, 4);

memFileName = strcat('225', '_ecg.txt');
fid = fopen(memFileName, 'w');

for i = 1:N-1
    fprintf(fid, '%s\n', binary_ecg(i, :));
end

% No newline for the last line
fprintf(fid, '%s', binary_ecg(N, :));

fclose(fid);

subplot(2, 1, 2);
plot(t, normalized_ecg);
title('Normalized ECG Signal');
xlabel('Sample');
ylabel('Amplitude');

disp('First 10 lines of binary data:');
disp(binary_ecg(1:10, :));
