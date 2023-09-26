function denoisedSignal = wavelet_denoise(noisySignal, level)
    denoisedSignal = wden(noisySignal, 'heursure', 's', 'one', level, 'sym8');
end
