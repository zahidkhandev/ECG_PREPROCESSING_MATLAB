function denoisedSignal = powerline_removal(signal, fs)
    f0 = 60; % 50Hz
    Q = 20; % Quality factor (adjust as needed)
    wo = f0 / (fs / 2); % Normalized frequency
    bw = wo / Q;
    
    [b, a] = iirnotch(wo, bw);
    
    % Apply the notch filter to the signal
    denoisedSignal = filtfilt(b, a, signal);
end
