function [P_t, Q_t, R_t, S_t, T_t, HRV] = pqrst_detection(sigAV, sigL)
    treshold = mean(sigAV);
    P_G = (sigAV > 0.01);

    % Find the QRS complex regions
    difsig = diff(P_G);
    left = find(difsig == 1);
    raight = find(difsig == -1);

    % Cancel delays due to filtering
    left = left - (6 + 16);
    raight = raight - (6 + 16);

    % Initialize arrays for PQRST points
    R_A = zeros(1, length(left));
    R_t = zeros(1, length(left));
    Q_A = zeros(1, length(left));
    Q_t = zeros(1, length(left));
    S_A = zeros(1, length(left));
    S_t = zeros(1, length(left));
    P_A = zeros(1, length(left));
    P_t = zeros(1, length(left));
    T_A = zeros(1, length(left));
    T_t = zeros(1, length(left));

    % Extract PQRST points
    for i = 1:length(left)
        [R_A(i), R_t(i)] = max(sigL(left(i):raight(i)));
        R_t(i) = R_t(i) - 1 + left(i);

        [Q_A(i), Q_t(i)] = min(sigL(left(i):R_t(i)));
        Q_t(i) = Q_t(i) - 1 + left(i);

        [S_A(i), S_t(i)] = min(sigL(left(i):raight(i)));
        S_t(i) = S_t(i) - 1 + left(i);

        [P_A(i), P_t(i)] = max(sigL(left(i):Q_t(i)));
        P_t(i) = P_t(i) - 1 + left(i);

        [T_A(i), T_t(i)] = max(sigL(S_t(i):raight(i)));
        T_t(i) = T_t(i) - 1 + left(i) + 47;
    end

    % Calculate HRV
    HRV = diff(P_t);
end