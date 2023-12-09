function [c, L] = get_wavelet_coeffs(signal,level,wavelet_name)
    [c, L] = wavedec(signal, level, wavelet_name);
end