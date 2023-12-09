close all;
clear;
clc;

data = load('data\bih_raw\100.mat');

sig = data.val(1, :);

N = length(sig);
fs = 360;
t = (0:N-1) / fs;

figure(1);

subplot(4, 2, 1);
plot(t, sig);
title('Original Signal');

% Low Pass Filter
b = 1/32 * [1 0 0 0 0 0 -2 0 0 0 0 0 1];
a = [1 -2 1];
sigL = filter(b, a, sig);

subplot(4, 2, 3);
plot(t, sigL);
title('Low Pass Filter');

subplot(4, 2, 4);
zplane(b, a);

% High Pass Filter
b = [-1/32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/32];
a = [1 -1];
sigH = filter(b, a, sigL);

subplot(4, 2, 5);
plot(t, sigH);
title('High Pass Filter');

subplot(4, 2, 6);
zplane(b, a);

% Derivative Base Filter
b = [1/4 1/8 0 -1/8 -1/4];
a = [1];
sigD = filter(b, a, sigH);

subplot(4, 2, 7);
plot(t, sigD);
title('Derivative Base Filter');

subplot(4, 2, 8);
zplane(b, a);

% Square the signal
sigD2 = sigD.^2;

% Normalize
signorm = sigD2 / max(abs(sigD2));

h = ones(1, 31) / 31;
sigAV = conv(signorm, h);
sigAV = sigAV(15+[1:N]);
sigAV = sigAV / max(abs(sigAV));

figure(2);
plot(t, sigAV);
title('Moving Average filter');

% Thresholding
threshold = mean(sigAV);
P_G = (sigAV > 0.01);

figure(3);
plot(t, P_G);
title('Threshold Signal');

difsig = diff(P_G);
left = find(difsig == 1);
right = find(difsig == -1);

% Run cancellation delay
left = left - (6 + 16);
right = right - (6 + 16);

% Initialize arrays to store P, Q, S, R, and T points
num_beats = min(length(left), length(right));
P_t = zeros(1, num_beats);
P_A = zeros(1, num_beats);
Q_t = zeros(1, num_beats);
Q_A = zeros(1, num_beats);
R_t = zeros(1, num_beats);
R_A = zeros(1, num_beats);
S_t = zeros(1, num_beats);
S_A = zeros(1, num_beats);
T_t = zeros(1, num_beats);
T_A = zeros(1, num_beats);

% Detect PQRST points
for i = 1:num_beats
    % R-peak detection (Blue Circle)
    [R_A(i), R_t(i)] = max(sigL(left(i):right(i)));
    R_t(i) = R_t(i) - 1 + left(i); % add offset
    
    % Q-peak detection (Green Circle)
    [Q_A(i), Q_t(i)] = min(sigL(left(i):R_t(i)));
    Q_t(i) = Q_t(i) - 1 + left(i);
    
    % S-peak detection (Black Triangle)
    [S_A(i), S_t(i)] = min(sigL(left(i):right(i)));
    S_t(i) = S_t(i) - 1 + left(i);
    
    % P-peak detection (Blue Plus)
    [P_A(i), P_t(i)] = max(sigL(left(i):Q_t(i)));
    P_t(i) = P_t(i) - 1 + left(i);
    
    % T-peak detection (Red Plus)
    [T_A(i), T_t(i)] = max(sigL(S_t(i):right(i)));
    T_t(i) = T_t(i) - 1 + left(i) + 47;
end

% Plot ECG with PQRST points
figure;
plot(t, sigL, t(Q_t), Q_A, 'og', t(S_t), S_A, '^k', t(R_t), R_A, 'ob', t(P_t), P_A, '+b', t(T_t), T_A, '+r');
title('ECG Signal with PQRST Points');


figure;
plot(t, sigD);
title('Derivative Base Filter');

