function [y,ty] = resample_signal_125(x,tx)

targetSampleRate = 125;
[y,ty] = resample(x,tx,targetSampleRate);
