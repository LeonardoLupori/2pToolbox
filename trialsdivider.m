clearvars -except data
brackets = [400,10300];
zeroToRemove = find(data.stimulus==0);
zeroToRemove = zeroToRemove(zeroToRemove>=brackets(1) & zeroToRemove<=brackets(2));
s = data.stimulus;
s(zeroToRemove) = 1;
%%
% clc
cell = 90;

for code=4:24
    trialLimits = divideTrials(s, code, 'silent');
    f = data.dFoF(:,cell);
    erp = zeros(size(trialLimits,1) ,trialLength(1));
    for i = 1:size(trialLimits,1)
        erp(i,:) = f(trialLimits(i,1):trialLimits(i,2));
    end
    figure
    plot(erp','color',[.7 .7 1])
    hold on
    plot(mean(erp),'Color','r','LineWidth',2)
    hold off
    title(sprintf('Stim Code: %i', code))
end
%%


plot(s,'Marker','*'), hold on
for i = 1:size(trialLimits,1)
    plot([trialLimits(i,1):trialLimits(i,2)],code,'Marker','o','Color','r')
    line([trialLimits(i,3), trialLimits(i,3)],[0, 20],'color','k')
    plot([trialLimits(i,1):trialLimits(i,2)],1,'Marker','o','Color','r')
end
hold off


