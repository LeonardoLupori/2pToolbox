function h = traceplot(traces,manualOffset)

% h = traceplot(traces,manualOffset)
% 
% traceplots plots different traces in a stacked plot. If a manual offset
% is omitted, an automati one will be used
% 
% traces: lines represent timepoints and columns represent cells

if nargin<2
    offset = quantile(traces(:),0.999);
else
    offset = manualOffset;
end
baselines = 0:offset:offset*(size(traces,2)-1);
offsetTraces = bsxfun(@plus, traces, baselines);
h = plot(offsetTraces);
yline(baselines)
% line(repmat([0; size(traces,1)],1,size(traces,2)),repmat(baselines,2,1),...
%     'color','k');
uistack(h,'top');

% Plot customization
xlim([-200 length(traces)]);
ylim([-offset max(offsetTraces(:,end)+offset)]);

text(repmat(-100,length(baselines),1), baselines, string(1:size(traces,2)), 'FontWeight', 'normal', 'FontSize', 12)


