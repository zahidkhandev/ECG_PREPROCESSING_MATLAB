clc
clear all;
close all;

wname_list = {'db1', 'db2', 'db4', 'db6', 'db10'};
num_records = 15;  % Number of records (101 to 115)

% Initialize arrays to store results for different wavelets
SNR_orig = zeros(num_records, length(wname_list));
SNR_filtered = zeros(num_records, length(wname_list));

for record = 101:115
    folderName = num2str(record);
    fileName = strcat(folderName, 'm');
    matFileName = strcat(fileName, '.mat');
    heaFileName = strcat(fileName, '.hea');

    data_path = fullfile('data/bih_raw/', folderName, matFileName);

    % Check if the MAT file exists
    if exist(data_path, 'file')
        data = load(data_path);

        ecg_orig = data.val(1, 1:3000);

        fs = 360;

        % Initialize arrays to store results for different wavelets
        SNR_orig_record = zeros(1, length(wname_list));
        SNR_filtered_record = zeros(1, length(wname_list));

        for i = 1:length(wname_list)
            wname = wname_list{i};

            ecg_signal1 = wdenoise(ecg_orig, 4, ...
                'Wavelet', wname, ...
                'DenoisingMethod', 'UniversalThreshold', ...
                'ThresholdRule', 'soft', ...
                'NoiseEstimate', 'LevelDependent');

            % Calculate SNR in dB for original and filtered signals
            [snr_orig, snr_filtered] = calculateNoisePowerAndSNR(ecg_orig, ecg_signal1);
            
            % Store the SNR values for the current wavelet and record
            SNR_orig_record(i) = snr_orig;
            SNR_filtered_record(i) = snr_filtered;
        end

        fprintf('SNR for %d: \n', record);
        fprintf('Original Signal SNR: [%.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB]\n', SNR_orig_record);
        fprintf('Filtered Signal SNR: [%.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB, %.2fdB]\n', SNR_filtered_record);
        
        % Store the SNR values in the result arrays
        SNR_orig(record - 100, :) = SNR_orig_record;
        SNR_filtered(record - 100, :) = SNR_filtered_record;
    else
        fprintf('Data for record %d not found.\n', record);
    end
end

% Now you have the SNR values for both original and filtered signals in SNR_orig and SNR_filtered
% You can access and print them as needed
disp('SNR for Original Signal:');
disp(SNR_orig);
disp('SNR for Filtered Signal:');
disp(SNR_filtered);
