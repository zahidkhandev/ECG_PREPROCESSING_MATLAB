clc
clear all;
close all;

folderName = '108';
fileName = strcat(folderName, 'm');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/bih_raw/', folderName, matFileName);

data = load(data_path);

ecg=data.val(1,1:2000);
Fs=input("Sampling rate : ");
ecg=ecg/200;
t=1:length(ecg);
tx=t./Fs;
wt=modwt(ecg,4,'sym4');
wtrec=zeros(size(wt));
wtrec(3:4,:)=wt(3:4,:);
y=imodwt(wtrec,'sym4');
y=abs(y).^2;
avg=mean(y);
[Rpeaks,locs]=findpeaks(y,t,'MinPeakHeight',8*avg,'MinPeakDistance',50);
nohb=length(locs);
timelimit=length(ecg)/Fs;
hbpermin=(nohb*60)/timelimit;
disp(strcat ('Heart Rate=',num2str(hbpermin)))
%subplot (211)
figure;
%plot (tx, ecg);
plot ( ecg);
%xlim ([0, timelimit]);
grid on;
xlabel('Seconds')
title('ECG Signal')
%xlim([0, timelimit]);
hold on;
%subplot (212)
plot (t, y)
grid on;
xlim([0, length(ecg)]);
hold on
plot (locs, Rpeaks, 'ro')
xlabel ('Samples')
title (strcat ('R Peaks found and Heart Rate:',num2str(hbpermin)))