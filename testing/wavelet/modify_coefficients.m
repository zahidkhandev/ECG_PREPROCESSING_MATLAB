function modified_coeffs = modify_coefficients(coeffs, replacement_coeffs, levels, level)
    % Modify the coefficients at a specific level with replacement_coeffs
    start_idx = sum(levels(1:level-1)) + 1;
    end_idx = sum(levels(1:level));
    modified_coeffs = coeffs;
    modified_coeffs(start_idx:end_idx) = replacement_coeffs;
end
