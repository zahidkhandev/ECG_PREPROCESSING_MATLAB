% Define the input parameters for the ecgsyn function
sfecg = 256;        % ECG sampling frequency [256 Hz]
N = 256;            % Approximate number of heart beats
Anoise = 0;         % Additive uniformly distributed measurement noise [0 mV]
hrmean = 60;        % Mean heart rate [60 beats per minute]
hrstd = 1;          % Standard deviation of heart rate [1 beat per minute]
lfhfratio = 0.5;    % LF/HF ratio [0.5]
sfint = 512;        % Internal sampling frequency [512 Hz]

% Order of extrema: [P Q R S T]
ti = [-70 -15 0 15 100] * pi / 180;  % Convert angles to radians
ai = [1.2 -5 30 -7.5 0.75];
bi = [0.25 0.1 0.1 0.1 0.4];

% Generate the synthetic ECG signal
[s, ipeaks] = ecgsyn(sfecg, N, Anoise, hrmean, hrstd, lfhfratio, sfint, ti, ai, bi);

% Plot the ECG signal
t = (0:N - 1) / sfecg;  % Time vector
figure;
plot(t, s);
xlabel('Time (s)');
ylabel('ECG Signal (mV)');
title('Synthetic ECG Signal');
grid on;

% Optionally, you can mark the PQRST peaks on the plot
hold on;
plot(t(ipeaks), s(ipeaks), 'ro', 'MarkerSize', 8);  % Red circles for peaks
legend('ECG Signal', 'PQRST Peaks');
hold off;
