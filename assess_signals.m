% function assess_signals(original_signal, denoised_signal, fs)
%     fft_original = fft(original_signal);
%     fft_denoised = fft(denoised_signal);
% 
%     L = length(original_signal); 
%     f = fs * (0:(L/2)) / L; 
% 
%     figure;
%     subplot(2, 1, 1);
%     plot(f, abs(fft_original(1:L/2+1)));
%     title('FFT of Original Signal');
%     xlabel('Frequency (Hz)');
%     ylabel('Magnitude');
% 
%     subplot(2, 1, 2);
%     plot(f, abs(fft_denoised(1:L/2+1)));
%     title('FFT of Denoised Signal');
%     xlabel('Frequency (Hz)');
%     ylabel('Magnitude');
% 
%     fprintf('Signal-to-Noise Ratio (SNR) in Voltage (dB): %.2f dB\n', snr_voltage);
%     fprintf('Signal-to-Noise Ratio (SNR) in dB: %.2f dB\n', snr_dB);
% end


function assess_signals(original_signal, denoised_signal, fs)
    % Calculate the spectra using the getspectrum function
    [f_original, amp_original] = getspectrum(original_signal, fs);
    [f_denoised, amp_denoised] = getspectrum(denoised_signal, fs);

    % Plot the spectra
    figure;
    subplot(2, 1, 1);
    plot(f_original, amp_original);
    title('Spectrum of Original Signal');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');

    subplot(2, 1, 2);
    plot(f_denoised, amp_denoised);
    title('Spectrum of Denoised Signal');
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
end