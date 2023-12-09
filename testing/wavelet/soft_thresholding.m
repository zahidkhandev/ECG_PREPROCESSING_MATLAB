function thresholded_coeffs = soft_thresholding(coeffs, threshold)
    thresholded_coeffs = sign(coeffs) .* max(abs(coeffs) - threshold, 0);
end

