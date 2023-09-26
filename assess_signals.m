function assess_signals(original_signal, denoised_signal, fs)
    fft_original = fft(original_signal);
    fft_denoised = fft(denoised_signal);

    signal_power_original = sum(original_signal.^2) / length(original_signal);
    noise_power = sum((original_signal - denoised_signal).^2) / length(original_signal);
    snr_voltage = 10 * log10(signal_power_original / noise_power);
    
    snr_dB = 20 * log10(rms(original_signal) / rms(original_signal - denoised_signal));
    
    L = length(original_signal); 
    f = fs * (0:(L/2)) / L; 
    
    figure;
    subplot(2, 1, 1);
    plot(f, abs(fft_original(1:L/2+1)));
    title('FFT of Original Signal');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    
    subplot(2, 1, 2);
    plot(f, abs(fft_denoised(1:L/2+1)));
    title('FFT of Denoised Signal');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');

    fprintf('Signal-to-Noise Ratio (SNR) in Voltage (dB): %.2f dB\n', snr_voltage);
    fprintf('Signal-to-Noise Ratio (SNR) in dB: %.2f dB\n', snr_dB);
end
