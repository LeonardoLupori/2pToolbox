function decodedTrace = voltageDecoder(channels, threshold)

% decodedTrace = voltageDecoder(channels)
% decodedTrace = voltageDecoder(channels, threshold)
% 
% decodes stimuli codes from voltage traces.
% channels: T x C matrix of voltage values. Rows represent timepoints and
% columns represent channels
% threshold(optional): voltage value used to binarize the TTL (default: 2)


if nargin<2
    threshold = 2; %2V for standard 3.3V TTL
end

% Binarize the voltage traces
logicChannels = channels > threshold;

decodedTrace = zeros(size(channels,1),1);
for i=1:size(logicChannels,2)
    powerOfTwo = i-1;
    decodedTrace(:,i) = logicChannels(:,i)*(2^powerOfTwo);
end
decodedTrace = sum(decodedTrace,2);