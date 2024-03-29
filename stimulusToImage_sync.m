function syncStimTrace = stimulusToImage_sync(stimuliTrace, voltageTime, framesTime)

% syncStimTrace = stimulusToImage_sync(stimuliTrace, voltageTime, framesTime)
% 
% synchronize the stimulus conditions trace (originally voltage trace) to
% the imaging timestamps without painful interpolation errors
% 
% stimuliTrace: the trace of stimuli identifier
% voltageTime: timestamps of voltage recording (also of stimuliTrace)
% framesTime: timestamps of frames

syncStimTrace = zeros(size(framesTime));
for i=1:length(framesTime)
%     if i==length(framesTime) && voltageTime(i)<framesTime(end)
%         syncStimTrace(i) = stimuliTrace(end);
%         continue
%     end
    
    ind = find(voltageTime >= framesTime(i),1,'first');
    if isempty(ind)
        warning('frame #%u was acquired later than last voltageTime. Assign the last stimulus code as default',i)
        syncStimTrace(i) = syncStimTrace(i-1);
    else
        syncStimTrace(i) = stimuliTrace(ind);
    end
end