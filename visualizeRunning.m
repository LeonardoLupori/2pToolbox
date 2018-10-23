%% Fetch all recordings for a single mouse
clearvars, clc
folder = uigetdir('E:\','Choose the habituation folder');
addpath(genpath('C:\Users\User\Documents\MATLAB\2pToolbox'))

if folder ~= 0
    [logicalList, names] = findSubfolders(folder, 'Voltage');
    numOfRecordings = size(names,1);
    % Initialize a struct
    data = struct('recName',{},...
        'date',{},...
        'voltageTrace',{},...
        'positionTrace',{},...
        'time',{});
    for i = 1:numOfRecordings
        subfolder = [folder filesep names{i}];
        [~, filenames] = findFile(subfolder,'.csv');
        [channels, time] = loadVoltageCSV([subfolder filesep filenames{1}]);
        % fetch date from filename
        temp = strsplit(filenames{1},'-');
        date = temp{2};
        % Save data in the data struct
        data(i).recName = filenames{1};
        data(i).date = date;
        data(i).voltageTrace = channels;
        data(i).positionTrace = buildPosition(channels, 'cm', 6);
        data(i).time = time;
    end
end

%% Plot the results
figure;
ax = axes;
ax.ColorOrder = colormap(hot(7));
ax.NextPlot = 'replacechildren';
for i = 1:size(data,2)
    h(i) = plot(ax, data(i).time, data(i).positionTrace,'DisplayName',data(i).date,'linewidth',1.4);
    hold(ax,'on')
end
hold(ax,'off')
title('Distance run - training - ')
grid(ax,'on')
ax.XLabel.String = 'Time [s]';
ax.YLabel.String = 'Distance run [cm]';
ax.XTick = [0 : 60 : ax.XLim(2)];
line(ax.XLim,[0 0],'color',[0,0,0],'linewidth',1);
legend(h,'location','best')



