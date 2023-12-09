clc;
clear all;
close all;

data_path = fullfile('225m.mat');
data = load(data_path);
ecg = data.val(1, 5000:5350);

file_path = '225_ecg.txt';
binary_data = fileread(file_path);
binary_data = strtrim(binary_data);

% Remove newline characters
binary_data = regexprep(binary_data, '\n', '');

% Ensure the length is a multiple of 12
num_samples = floor(length(binary_data) / 12);
binary_data = binary_data(1:num_samples * 12);

decimal_values = zeros(1, num_samples);

for i = 1:num_samples
    start_idx = (i - 1) * 12 + 1;
    end_idx = i * 12;
    binary_chunk = binary_data(start_idx:end_idx);
    decimal_values(i) = bin2dec(binary_chunk);
end

N = length(ecg);
fs = 125;
t = (0:N-1)/fs;

min_value = min(ecg);
max_value = max(ecg);

normalized_ecg = round(4095 * (ecg - min_value) / (max_value - min_value));

figure;
subplot(2, 1, 1);
plot(t, normalized_ecg);
title('Normalized ECG Signal');
xlabel('Sample');
ylabel('Amplitude');


subplot(2, 1, 2);
plot(t, decimal_values);
title('Reconstructed ECG Signal');
xlabel('Sample');
ylabel('Amplitude');

% Display decimal values
disp('Decimal Values:');
disp(decimal_values);