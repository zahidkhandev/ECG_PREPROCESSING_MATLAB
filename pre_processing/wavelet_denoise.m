function denoisedSignal = wavelet_denoise(noisySignal, level)
    dwtmode('per','nodisplay');
    wname='sym8';
    denoisedSignal = wden(noisySignal,'modwtsqtwolog','h','mln',level,wname);
end
