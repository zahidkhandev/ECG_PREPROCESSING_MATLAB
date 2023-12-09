function qrswav = qrs_wav(x, a_qrswav, d_qrswav, li)
    l = li;
    a = a_qrswav;
    b = (2 * l) / d_qrswav;
    n = 100;
    qrs1 = (a / (2 * b)) * (2 - b);
    qrs2 = 0;

    for i = 1:n
        term1 = (2 * b * a / (i^2 * pi^2)) * (1 - cos(i * pi / b));
        harmonic = term1 * cos(i * pi * x / l);
        qrs2 = qrs2 + harmonic;
    end

    qrswav = qrs1 + qrs2;
end
