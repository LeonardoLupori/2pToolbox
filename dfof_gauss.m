function dFoF = dfof_gauss(traces,iterations)

% dFoF = dfof_gauss(traces)
% dFoF = dfof_gauss(traces,iterations)
% 
% Delta F over F algorithm in which f0 is defined as the mean of the
% smallest gaussian curve fitted to the trace for each cell
% 
% traces: a 2D matrix. rows represent timepoints and columns represent
% different cells
% iterations(optional): number of iterations for the fit

if nargin < 2
    iterations = 1000;
end

options = statset('MaxIter',iterations);

dFoF = zeros(size(traces));
for i=1:size(traces,2)
    if std(traces(:,i))==0
        dFoF(:,i) = zeros(size(traces(:,i)));
        continue
    end
    try
        gmmodel = fitgmdist(traces(:,i), 3, 'Options', options);
    catch ME
        gmmodel = fitgmdist(traces(:,i), 2, 'Options', options);
        warning(['Unable to fit 3 gaussian components in trace ' num2str(i) '. fitting 2 instead.'])
    end
    
    f0 = min(gmmodel.mu);
    dFoF(:,i) = (traces(:,i)-f0) / f0;
end