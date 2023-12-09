function denoisedSignal = wavelet_denoise(noisySignal, level)
    dwtmode('per','nodisplay');
    wname='sym4';
    denoisedSignal = wden(noisySignal,'modwtsqtwolog','h','mln',level,wname);
end

% function denoisedSignal = wavelet_denoise(noisySignal, level)
%     dwtmode('per','nodisplay');
%     wname='sym8';
%     denoisedSignal = wden(noisySignal,'heursure','h','mln',level,wname);
% end
