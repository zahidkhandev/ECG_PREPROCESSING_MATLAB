function denoised_signal = wavelet_denoise(ecg_signal)
    % Define the wavelet
    wname = 'fibr';

    % Choose the level of decomposition
    nlevel = 8;

    % Perform wavelet decomposition
    [c, l] = wavedec(ecg_signal, nlevel, wname);

    % Estimate the threshold using Rigorous Sure (rigrsure)
    threshold = thselect(ecg_signal, 'rigrsure');

    % Perform soft thresholding
    c_soft = wthresh(c, 's', threshold);

    % Reconstruct the denoised ECG signal
    denoised_signal = waverec(c_soft, l, wname);
end
