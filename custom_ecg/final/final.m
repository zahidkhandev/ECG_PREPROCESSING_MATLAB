clc
clear all;
close all;

duration = 60;
bpm = 72;

h = duration/bpm;

for a = 0:h:2*h
    ECGdur = 0:0.001:10;
    Pint = 0.08;
    PRint = 0.18;
    STint = 0.11;
    QTint = 0.40;
    QRSint = 0.09;
    pPeak = 0.25;
    rPeak = 1.6;
    qPeak = .25 * rPeak;
    sPeak = .35 * rPeak;
    tPeak = 0.3;

    % Generate P wave:
    x = 0:0.001:Pint;
    y = pPeak*sin(x*pi/Pint);
    plot (a+x, y)
    hold on
    xlabel('Time (s)')
    ylabel('Voltage (mV)')
    title('ECG');

    % Generate PR segment:
    x = Pint:0.0001:PRint;
    plot(a+x, 0);

    % Generation of QRS wave:
    q1 = PRint + 0.015;
    r1 = PRint + 0.045;
    s1 = PRint + 0.075;
    s2 = PRint + QRSint;

    y = 26.667 * x + 4.533333;
    plot(a+x, y);

    x = q1:0.001:r1;
    y = 66.667 * x - 12.733;
    plot(a+x, y);

    x = r1:0.001:s1;
    y = -72*x + 17.08;
    plot (a+x, y);

    x = s1:0.001:s2;
    y = 37.333*x - 9.706;
    plot (a+x, y)

    % Generation of ST segment
    t1 = PRint + QRSint + STint;
    x = s2:0.0001:t1;
    plot (a+x, 0);
    
    t2 = PRint + QTint;
    x = t1:0.001: t2;
    y = tPeak * sin((x-t1) *pi / (t2-t1));
    plot (a+x, y);

    x=t2:0.0001:h;
    plot (a + x, 0)
end

