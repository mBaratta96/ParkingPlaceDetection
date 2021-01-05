clear;
clc;
close all;

addpath(genpath('parkingLotDetection'));
addpath(genpath('tiltEstimation'));

%% Chose the functionality
%Angle = rad2deg(estimateTiltAngle(100));
parkingDetection();