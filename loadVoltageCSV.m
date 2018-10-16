function [channels, time] = loadVoltageCSV(pathToCVS)

% [channels, time] = loadVoltageCSV(pathToCVS)
% 
% channels: matrix of voltage values. row represents timepoints and column
% represents channels
% time: in seconds.

M = csvread(pathToCVS, 1, 0);

time = M(:,1)/1000; % Changes time units from ms to s
channels = M(:,2:end);