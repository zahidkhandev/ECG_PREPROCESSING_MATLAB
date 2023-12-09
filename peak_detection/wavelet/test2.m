clc;
clear all;
close all;

fileName = '234m';
matFileName = strcat(fileName, '.mat');

data_path = fullfile('data/bih_raw/234/', matFileName);

data = load(data_path);

ecg=data.val(1,1:1000);
Fs=360;
t=1:length(ecg);
tx=t./Fs;

wt=modwt(ecg,10,'sym6');
wtrec=zeros(size(wt));
wtrec(4:8,:)=wt(4:8,:);
y=imodwt(wtrec,'sym6');


figure;
subplot(211);
plot(y);
subplot(212);
plot(ecg);