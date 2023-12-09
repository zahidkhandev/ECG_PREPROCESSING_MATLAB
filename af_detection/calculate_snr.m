function snr_output = calculate_snr(original_signal, filtered_signal)
    % Calculate SNR using MATLAB's built-in function
    snr_output = snr(original_signal, filtered_signal);

    % % Calculate SNR using the custom function
    % original_signal_power = sum(original_signal.^2) / length(original_signal);
    % noise_power = sum((original_signal - filtered_signal).^2) / length(original_signal);
    % snr_linear = original_signal_power / noise_power;
    % snr_custom = 10 * log10(snr_linear);
    % 
    % % Calculate SNR using the provided formula
    % snr_formula = 20 * log10((mean(original_signal.^2)) / (mean(filtered_signal.^2)));
end
