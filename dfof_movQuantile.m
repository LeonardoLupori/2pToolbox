function dFoF = dfof_movQuantile(traces,n,q)

% dFoF = dfof_movQuantile(traces,n,q)
% 
% traces: a 2D matrix. rows represent timepoints and columns represent
% different cells
% n: window size for the moving quantile (best if odd) (default: 101)
% q: quantile to consider as f0 (default: 0.08)

if nargin < 2
    n = 101;
    q = 0.08;
elseif nargin <3
    q = 0.08;
end

dFoF = zeros(size(traces));
f0 = zeros(size(traces));

for i=1:size(traces,2)
    cellTrace = traces(:,i);
    f0(:,i) = moving(cellTrace,n,@(cellTrace,Q)quantile(cellTrace,q));
end

dFoF = (traces-f0)./f0;


