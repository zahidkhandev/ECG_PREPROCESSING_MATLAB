function denoised_signal = moving_avg(orig_signal,window_size)

    denoised_signal = zeros(1, length(orig_signal));
    for i=1:length(orig_signal)-window_size
        denoised_signal(i) = 1/window_size *(orig_signal(i) + orig_signal(i+1) + orig_signal(i+2) + orig_signal(i+3) + orig_signal(i+4));
    end

end

