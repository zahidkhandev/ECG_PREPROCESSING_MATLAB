clc;
clear all;
close all;

BPM = 70; % Set the value of BPM (Beat per minute)
Duration = 60; % Set the value of Duration in seconds
peak = 1000; % Set the value of the peak of the wave
beatPeriod = 60 / BPM;
numOfHeartbeats = ceil(Duration / beatPeriod);

signalType = 'normal';

beatDuration = 0.7;

% amplitude constants:
rPeak = peak;
pPeak = 0.1 * rPeak;
qPeak = 0.16 * rPeak;
sPeak = 0.45 * rPeak;
tPeak = 0.1875 * rPeak;

% time constants:
Pint = 0.08;
PRint = 0.204;
STseg = 0.10;
QTint = 0.33;
QRSint = 0.09;

q1 = PRint + 0.018;
r1 = PRint + 0.044;
s1 = PRint + 0.07;
s2 = PRint + QRSint;
t1 = PRint + QRSint + STseg;
t2 = PRint + QTint;


if(BPM > 130)
    Pint = 0.12 * beatPeriod;
    PRint = 0.204 * beatPeriod;
    QTint = 0.33 * beatPeriod;
    QRSint = 0.09 * beatPeriod;
    STseg = 0.10 * beatPeriod;
    q1 = PRint + 0.018 * beatPeriod;
    r1 = PRint + 0.044 * beatPeriod;
    s1 = PRint + 0.07 * beatPeriod;
    s2 = PRint + QRSint;
    t1 = PRint + QRSint + STseg;
    t2 = PRint + QTint;
end

mq = -qPeak / (q1 - PRint);
cq = -mq * PRint;

mrUp = (rPeak + qPeak) / (r1 - q1);
crUp = rPeak - mrUp * r1;
mrDown = (-sPeak - rPeak) / (s1 - r1);
crDown = rPeak - mrDown * r1;
ms = sPeak / (s2 - s1);
cs = -ms * s2;

aFinal = (numOfHeartbeats - 1) * beatPeriod;

ecg = [];

for a = 0:beatPeriod:aFinal
    x = 0:0.001:Pint;
    y = pPeak * sin(x * pi / Pint);
    ecg = [ecg, y];

    x = Pint:0.001:PRint;
    y = zeros(1, length(x));
    ecg = [ecg, y];

    x = PRint:0.001:q1;
    y = mq * x + cq;
    ecg = [ecg, y];

    x = q1:0.001:r1;
    y = mrUp * x + crUp;
    ecg = [ecg, y];

    x = r1:0.001:s1;
    y = mrDown * x + crDown;
    ecg = [ecg, y];

    x = s1:0.001:s2;
    y = ms * x + cs;
    ecg = [ecg, y];

    % Generation of ST segment
    x = s2:0.001:t1;
    y = zeros(1, length(x));
    ecg = [ecg, y];

    % Generation of T wave
    x = t1:0.001:t2;
    y = tPeak * sin((x - t1) * pi / (t2 - t1));
    ecg = [ecg, y];
   

    if(beatPeriod > beatDuration)
        x = t2:0.001:beatDuration;
        y = zeros(1, length(x));
        ecg = [ecg, y];
        x = beatDuration:0.001:beatPeriod;
        y = zeros(1, length(x));
        ecg = [ecg, y];
    else
        x = t2:0.001:beatPeriod;
        y = zeros(1, length(x));
        ecg = [ecg, y];
    end

end

N = length(ecg);
fs = N / Duration;
time = (0:N-1) / fs;

[resampled_ecg, resampled_time] = resample_ecg(ecg, time, 360);
% 
% figure;
% plot(resampled_time, resampled_ecg);

%r_peak_plot(resampled_ecg,360, resampled_time);

pqrst_plot(resampled_ecg,360, resampled_time, Duration, false);

directory = 'data\generated';

variable_name = sprintf('ecg_%d_bpm', BPM);

full_path = fullfile(directory, signalType, [variable_name, '.mat']);

ecg = resampled_ecg;

save(full_path, 'ecg');
