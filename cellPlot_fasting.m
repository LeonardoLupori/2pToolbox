function f = cellPlot_fasting(respStim, stimProtocol)

% Sets the order in which different stimuli appear in the response grid 
codeOrder = [22,23,24,10,11,12,...
    19,20,21,7,8,9,...
    16,17,18,4,5,6];

% Defines axes on the left and bottom row in order to maintain xticks and
% yticks only in those plots
bottomRow = [15,16,17,19,20,21];
leftColumn = [1,5,8,12,15,19];

customMax = @(x) max(x(:));
customMin = @(x) min(x(:));

f = figure('Position',[150,275,1500,650],'Color',[1,1,1]);
plotN = 1:21;
plotN(ismember(plotN,[4,11,18])) = [];  % remove ploits for the middle line

% fing global X and Y limits for the axes
top = max(cellfun(customMax,{respStim.erp}));
bottom = min(cellfun(customMin,{respStim.erp}));
limits = [bottom*1.1, top*1.1];

ax = gobjects(length(plotN),1);
for i = 1:length(plotN)
    thisPlot = plotN(i);
    ax(i) = subtightplot(3,7,thisPlot,[0.02,0.01],0.08,0.05);
    
    % Response struct to the current stimulus
    R = respStim([respStim.stimCode] == codeOrder(i));
    
    % Color based on if responsive
    if R.isResponsive
        col = [1 .8 .8; 1 .2 .2];
    else
        col = [.8 .8 1; .2 .2 1];
    end
        
    plot(R.erpTime, R.erp,'Color',col(1,:))
    hold on
    plot(R.erpTime, mean(R.erp,2),'Color',col(2,:),'LineWidth',2.5)
    hold off

    % Customize plot appearence
    ax(i).FontSize = 12;
    ax(i).YLim = limits;
    ax(i).XLim = [respStim(1).erpTime(1) respStim(1).erpTime(end)];
    ax(i).Box = 'off';
    
    yline(0,'Color','k','LineWidth',1,'LineStyle', ':')
    xline(0,'Color','k','LineWidth',1,'LineStyle', ':')
    
    currentSF = stimProtocol.spatialFreq(stimProtocol.code == R.stimCode);
    currentTF = stimProtocol.temporalFreq(stimProtocol.code == R.stimCode);
    text(-1.95, limits(2)*.95, sprintf('TF: %.1f Hz', currentTF), 'FontSize',10)
    text(-1.95, limits(2)*.85, sprintf('SF: %.2f cdeg', currentSF), 'FontSize',10)
    
    % Customize X AXIS 
    if ismember(thisPlot,bottomRow)
        xlabel('Time (s)')
    else
        xticks([])
    end
    % Customize Y AXIS 
    if ismember(thisPlot,leftColumn)
        ylabel('\DeltaF/F')
    else
        yticks([])
    end
    % Customize TITLES
    if thisPlot == 2
        title('ORI: 0°')
    elseif thisPlot == 6
        title('ORI: 270°')
    end
end