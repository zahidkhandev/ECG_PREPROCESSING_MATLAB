function qwav = q_wav(x, a_qwav, d_qwav, t_qwav, li)
    l = li;
    x = x + t_qwav;
    a = a_qwav;
    b = (2 * l) / d_qwav;
    n = 100;
    q1 = (a / (2 * b)) * (2 - b);
    q2 = 0;

    for i = 1:n
        term1 = (2 * b * a) / (i^2 * pi^2) * (1 - cos(i * pi / b));
        harmonic = term1 * cos(i * pi * x / l);
        q2 = q2 + harmonic;
    end

    qwav = -1 * (q1 + q2);
end
