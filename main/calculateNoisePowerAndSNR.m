function [snr_original, snr_filtered] = calculateNoisePowerAndSNR(original_ecg, filtered_ecg)
    % Calculate the power of the original signal
    original_power = sum(original_ecg.^2) / length(original_ecg);

    % Calculate the noise component
    noise_component = original_ecg - filtered_ecg;

    % Calculate the power of the noise component using RMS
    noise_power = sum(noise_component.^2) / length(noise_component);

    % Calculate the power of the filtered signal
    filtered_power = sum(filtered_ecg.^2) / length(filtered_ecg);

    % Calculate the SNR in dB for the original and filtered signals
    snr_original = 10 * log10(original_power / noise_power);
    snr_filtered = 10 * log10(filtered_power / noise_power);
end
