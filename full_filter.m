function filteredSignal = full_filter(ecgSignal)
    % Define the sampling frequency
    Fs = 500; % Average sample rate

    % Design a high-pass filter
    highpassFrequency = 0.5;
    highpassSteepness = 0.95;
    highpassStopbandAttenuation = 50;
    highpassFiltered = highpass(ecgSignal, highpassFrequency, Fs, ...
        'Steepness', highpassSteepness, 'StopbandAttenuation', highpassStopbandAttenuation);

    % Design a low-pass filter
    lowpassFrequency = 30;
    lowpassSteepness = 0.95;
    lowpassStopbandAttenuation = 50;
    filteredSignal = lowpass(highpassFiltered, lowpassFrequency, Fs, ...
        'Steepness', lowpassSteepness, 'StopbandAttenuation', lowpassStopbandAttenuation);
end


