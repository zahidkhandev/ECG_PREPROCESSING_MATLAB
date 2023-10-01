clc
clear all;
close all;

folderType = 'AF';
fileName = strcat('JS02677');
matFileName = strcat(fileName, '.mat');
heaFileName = strcat(fileName, '.hea');

data_path = fullfile('data/processed/', folderType, matFileName);

data = load(data_path);