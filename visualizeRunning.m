close all, clearvars, clc
[FileName,PathName,FilterIndex] = uigetfile('E:\*.csv','Select a voltage trace');
%%
if FilterIndex ~= 0
    [channels, time] = loadVoltageCSV([PathName FileName]);
    positionTrace = buildPosition(channels, 'cm', 6);
    ax = axes;
    plot(ax,time, positionTrace)
    ax.XLabel.String = 'Time [s]';
    ax.YLabel.String = 'Distance run [cm]';
end

%%


