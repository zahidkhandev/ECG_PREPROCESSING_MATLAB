function swav = s_wav(x, a_swav, d_swav, t_swav, li)
    l = li;
    x = x - t_swav;
    a = a_swav;
    b = (2 * l) / d_swav;
    n = 100;
    s1 = (a / (2 * b)) * (2 - b);
    s2 = 0;

    for i = 1:n
        term1 = (2 * b * a) / (i^2 * pi^2) * (1 - cos(i * pi / b));
        harmonic = term1 * cos(i * pi * x / l);
        s2 = s2 + harmonic;
    end

    swav = -1 * (s1 + s2);
end
