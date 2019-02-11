clearvars, clc
addpath(genpath('C:\Users\Leonardo\Documents\MATLAB\2pToolbox'))
 
%% Get 3 files (fluorescence data, imaging info, voltage recording)

defPath = 'C:\';

% Fluorescence traces
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select a F file from Suite2P', defPath);
load([PathName FileName]);
% Imaging info
[FileName,PathName,FilterIndex] = uigetfile('*.xml','Select TIFF XML file',PathName);
[generalInfo, sequenceInfo] = loadExperimentXML([PathName FileName]);
framesTime = [sequenceInfo.frame.relativeTime]';
% Voltge recording
[FileName,PathName,FilterIndex] = uigetfile('*.csv','Select Voltage trace CSV file',PathName);
[channels, voltageTime] = loadVoltageCSV([PathName FileName]);
decodedTrace = voltageDecoder(channels(:,1:6), 2);
stimulus = stimulusToImage_sync(decodedTrace, voltageTime, framesTime);
% Running trace
smoothingWindow = 0.5; % (seconds) to reduce electrical noise
factor = smoothingWindow/mean(diff(voltageTime));
if mod(factor,2)==0
    factor = factor+1;
end
running = smooth(buildPosition(channels(:,8),'cm',6),factor);
running = interp1(voltageTime,running,framesTime);

%% (Optional) QC plotting
if exist('fAlign','var') && ishandle(fAlign)
    close(fAlign)
end
fAlign = figure;
fAlign.Position = [70 300 1300 400];
plot(framesTime,stimulus,'DisplayName','Aligned stimuli','marker','o',...
    'LineStyle','none')
hold on
plot(framesTime,repmat(-.5,length(framesTime),1),'DisplayName','Frame',...
    'marker','x','LineStyle','none')
plot(voltageTime,decodedTrace,'DisplayName','rawCodes')
hold off
legend('location','best')
title('Voltage to frames alignment')
ylim([-1 max(stimulus)+1])
xlim([0 framesTime(end)])
xlabel('Time (s)'),ylabel('Conditions')
addToolbarExplorationButtons(gcf) % Adds buttons to figure toolbar

%% Preprocessing
data.stimulus = stimulus;
data.framesTime = framesTime;
data.rawF = dat.Fcell{1}';
data.neuropilF = dat.FcellNeu{1}';
data.npCoeff = [dat.stat.neuropilCoefficient];
data.validCells = find([dat.stat.iscell]==1);

% Neuropil subtraction
data.correctedTraces = data.rawF - (data.neuropilF .* data.npCoeff);

% Deta F over F
% data.dFoF = dfof_movQuantile(data.correctedTraces, 101, 0.1);    % moving quantile
data.dFoF = dfof_gauss(data.correctedTraces,1000);    % gaussian version

%% (Optional) QC plotting

cellInspector(data)













