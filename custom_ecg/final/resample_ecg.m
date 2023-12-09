function [y,ty] = resample_ecg(x,tx, fs)

targetSampleRate = fs;
[y,ty] = resample(x,tx,targetSampleRate);
