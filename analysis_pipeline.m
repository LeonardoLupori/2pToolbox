clearvars, clc
addpath(genpath('C:\Users\Leonardo\Documents\MATLAB\2pToolbox'))

%% Get 3 files (fluorescence data, imaging info, voltage recording)
defPath = 'D:\PizzorussoLAB\';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fluorescence traces
[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select a F file from Suite2P', defPath);
suite2PName = FileName;
load([PathName FileName]);
m = matfile([PathName FileName],'Writable',true);
% Load the rest of the files if a previous preprocessing hasn't been
% performed
if ~misField(m,'stimulus') || ~misField(m,'runningInfo')
    % Imaging info
    [FileName,PathName,~] = uigetfile('*.xml','Select TIFF XML file',PathName);
    [generalInfo, sequenceInfo] = loadExperimentXML([PathName FileName]);
    framesTime = [sequenceInfo.frame.relativeTime]';
    % Voltge recording
    [FileName,PathName,~] = uigetfile('*.csv','Select Voltage trace CSV file',PathName);
    [channels, voltageTime] = loadVoltageCSV([PathName FileName]);
    decodedTrace = voltageDecoder(channels(:,1:6), 2);
    stimulus = stimulusToImage_sync(decodedTrace, voltageTime, framesTime);
    m.stimulus = stimulus;
    m.time = framesTime;
end

%% RUNNING analysis pipeline
smoothingWindow_1 = 1.5;    % (seconds) to reduce electrical noise
smoothingWindow_2 = 2.5;    % (seconds) to smooth the downsampled running trace
threshToRunning = 1;        % (cm/s) threshold to define a speed as running

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

voltagePeriod = mean(diff(voltageTime));    % Useful variables for later
framePeriod = mean(diff(framesTime));       % Useful variables for later
factor = floor(smoothingWindow_1/voltagePeriod);    % Closest integer
if mod(factor,2)==0; factor = factor+1; end         % makes sure the window is an odd number
running = buildPosition(channels(:,8),'cm',6);
runningSpeed = diff(running)/voltagePeriod;
runningSpeed = smooth(runningSpeed,factor);
runningSpeed = interp1(voltageTime,[0; runningSpeed],framesTime);
factor = floor(smoothingWindow_2/framePeriod);
if mod(factor,2)==0; factor = factor+1; end         % makes sure the window is an odd number
runningSpeed = smooth(runningSpeed,factor);
% Analysis on the running trace
runningInfo.totalDistance = max(running);
isRunning = runningSpeed>threshToRunning;
runningInfo.isRunning = isRunning;
runningInfo.totalTime = length(isRunning)*framePeriod;
runningInfo.timeRunning = sum(isRunning)*framePeriod;
runningInfo.timeStationary = sum(~isRunning)*framePeriod;
runningInfo.fractionTimeRunning = runningInfo.timeRunning/runningInfo.totalTime;
runningInfo.fractionTimeStationary = runningInfo.timeStationary/runningInfo.totalTime;
if sum(isRunning)==0
    speed = 0;
else
    speed = mean(runningSpeed(isRunning));
end
runningInfo.avgSpeed = speed;
% Save Running Info into the matfile
m.runningInfo = runningInfo;
m.runningSpeed = runningSpeed;

%% (Optional) QC plotting for RUNNING ANALYSIS
if exist('fRun','var') && ishandle(fRun)
    delete(fRun)
end
fRun = figure('Position',[80 500 1700 400],'Name','Running QC'); axRun = axes;
if ~exist('framesTime','var')
    framesTime = time;
end
sp = plot(axRun,framesTime/60, runningSpeed,'DisplayName','Speed','LineWidth',1.2);
xlabel('Time [min]'); ylabel('Speed [cm/s]'); title('Running Analysis QC plot')
hold(axRun,'on')
avgS = line([framesTime(1)/60, framesTime(end)/60],[runningInfo.avgSpeed, runningInfo.avgSpeed],...
    'LineWidth',1.3,'LineStyle','-.','Color','k','displayName','Average Speed');
% areaSp = area(axRun,framesTime/60,runningInfo.isRunning*axRun.YLim(2)*0.99,'BaseValue',0,...
%     'FaceColor',[.7 .9 .7],'EdgeAlpha',0,'DisplayName','Running Phases');
avgT = line([framesTime(1)/60, framesTime(end)/60],[threshToRunning, threshToRunning],...
    'LineWidth',.5,'LineStyle','-','Color','r','displayName','Running threshold');
stimuli = unique(stimulus);
numStimuli = length(stimuli);
colors = hsv(numStimuli);
for i = 3:numStimuli
    area(axRun,framesTime/60,(stimulus==stimuli(i))+axRun.YLim(1),'BaseValue',axRun.YLim(1),...
        'FaceColor',colors(i,:),'LineWidth',0.1,'ShowBaseLine','off');
end
line([framesTime(1)/60, framesTime(end)/60],[0, 0],'LineWidth',.5,'LineStyle','-','Color','k');
hold(axRun,'off')
legend(axRun,[sp,avgS,avgT],'location', 'best')
axRun.Children = flip(axRun.Children);
axRun.XLim(2) = max(framesTime/60);

%% (Optional) QC plotting for STIMULUS ALIGNMENT
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

%% Neuropil Correction
numcells = size(F,1);
neuCoeff = zeros(numcells);
neuConst = zeros(numcells);
correctedF = zeros(size(F));
for i = 1:numcells
    if ~iscell(i)
        continue
    end
    robFit = robustfit(Fneu(i,:),F(i,:),'huber');
    neuCoeff(i) = robFit(2);
    if neuCoeff(i) > 1
        neuCoeff(i) = 1;
    end
    neuConst(i) = robFit(1);
    correctedF(i,:) = F(i,:)-(neuCoeff(i)*Fneu(i,:));
end

%% (optional) QC plots for NEUROPIL CORRECTION estimation
timeLimits = [1, 2000];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cellsPlotted = 0;
previousPos = [50, 340];
for i = 1:numcells
    if ~iscell(i,1)
        continue
    end
    figCounter = mod(cellsPlotted,4);
    if figCounter == 0  % Create a new figure every 5 cells
        previousPos = [previousPos(1)+20 previousPos(2)-20];
        figure('Name',sprintf('Neurop correction | from cell# %i',i),...
            'Position',[previousPos(1) previousPos(2) 1100 630])
        ax = subplot(4,3,1);
    else
        ax = subplot(4,3,1+figCounter*3);
    end
    plot(Fneu(i,:),F(i,:),'LineStyle','none','Marker','.',...
        'Color',[0 0 1],'DisplayName','Raw trace')
    ax.XLabel.String = '\DeltaF/F Neuropil';
    ax.YLabel.String = '\DeltaF/F Cell';
    ax.Title.String = sprintf('Cell# %i | Coeff = %4.3f',i,neuCoeff(i));
    x = linspace(ax.XLim(1),ax.XLim(2));
    y = x*neuCoeff(i) + neuConst(i);
    hold(ax,'on')
    plot(x,y,'Color',[1 0 0],'LineWidth',1.8,'DisplayName','Robust Regression')
    hold(ax,'off')
    cellsPlotted = cellsPlotted+1;
    % Plot the timeline and corrected timeline
    if figCounter == 0
        tlAx = subplot(4,3,[2 3]);
    else
        tlAx = subplot(4,3,[2+figCounter*3 3+figCounter*3]);
    end
    plot(tlAx,F(i,timeLimits(1):timeLimits(2)),'Color',[0 0 1],...
        'LineWidth',0.1,'DisplayName','Cell');
    hold(tlAx,'on')
    plot(tlAx,Fneu(i,timeLimits(1):timeLimits(2)),'Color',[1 0 0],...
        'LineWidth',0.1,'DisplayName','Neuropil');
    plot(tlAx,correctedF(i,timeLimits(1):timeLimits(2)),'Color',[0 1 0],...
        'LineWidth',0.1,'DisplayName','Corrected');
    tlAx.Title.String = sprintf('Cell# %i | Timeline',i);
    tlAx.YLabel.String = '\DeltaF/F';
    if figCounter == 0
        legend('location','best')
    end
    hold(tlAx,'on')
end

%% Delta F/F and division in trials

dfof = dfof_gauss(correctedF',1000)';

% Load the Stimulus file
[FileName,PathName,FilterIndex] = uigetfile('*.csv','Select Stimulus definition',PathName);
if ~FilterIndex
    disp('Aborted.')
    return
end
stimProtocol = readStimuliCsv([PathName FileName]);
% Compute the erp for each cell for each stimulus
response = cell(size(stimProtocol,1),1);
for i = 1:size(stimProtocol,1)
    trialLimits = divideTrials(stimulus, stimProtocol.code(i),'silent');
    TrLength = trialLimits(1,2)-trialLimits(1,1)+1;
    erp = zeros(size(dfof,1),TrLength,size(trialLimits,1));
    for trial = 1:size(trialLimits,1)
        erp(:,:,trial) = dfof(:,trialLimits(trial,1):trialLimits(trial,2));
    end
    response{i} = erp;
end
stimProtocol.erp = response;
trials = stimProtocol(:,[1,2,3,4,7]);
m.trials = trials;

%% Plotting

interval = mean(diff(time));
for i=1:size(stimProtocol,1)
    stim = i;
    d = stimProtocol.erp{stim};
    d = d(logical(iscell(:,1)),:,:);
    timeERP = (-size(d,1)/2 : (size(d,1)/2)-1)*interval;
    subplot(4,6,i)
    %imagesc(mean(d,3),[0 2])
    med = mean(d,3);
    med = med./max(med,[],2);
    h = fspecial('gaussian',[1 30]);
    med = imfilter(med,h);
    
    imagesc(mean(d,3),[0 1])
    title(sprintf('Sf: %g - Tf: %g - Ori: %g',[stimProtocol.spatialFreq(stim), stimProtocol.temporalFreq(stim), stimProtocol.orientation(stim)]))
end

%% Plot each cell in a separate figure showing ERPs to each stimuli (slow)
cells = find(iscell(:,1));
interval = mean(diff(time));

for c = 1:sum(iscell(:,1))
    currentCell = cells(c);
    f = figure('Name',sprintf('Cell #%g/%g',currentCell,length(iscell)),...
        'Position',[262 173 1320 818]);
    for stim = 1:size(trials,1)
        d = trials.erp{stim};
        d = squeeze(d(currentCell,:,:));
        meanERP = mean(d,2);
        timeERP = (-size(d,1)/2 : (size(d,1)/2)-1)*interval;
        % ttest
        [h,pVal] = ttest2(meanERP(1:size(d,1)/2),meanERP(size(d,1)/2+1:end),'Tail','left');
        %Plotting
        subplot(4,6,stim)
        p = plot(timeERP,d,'color',[.75 .75 1]); hold on
        p(2) = line(get(gca,'xlim'),[0 0],'color',[0 0 0]);
        p(3) = line([0 0],get(gca,'ylim'),'color',[0 0 0]);
        p(4) = plot(timeERP,meanERP,'color',[1 .2 .2],'LineWidth', 2.5);
        hold off
        ylabel('\Delta F/F'), xlabel('Time[s]')
        title(sprintf('Sf:%g - Tf:%g - Ori:%g',[trials.spatialFreq(stim), trials.temporalFreq(stim), trials.orientation(stim)]))
        if pVal < 0.05/size(trials,1)
            temp = get(gca,'ylim');
            text(-4,temp(2)/1.3,'*','FontSize',30,'FontWeight','bold','Color','r')
        end
    end
end


