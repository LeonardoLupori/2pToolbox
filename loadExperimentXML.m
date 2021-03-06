function [generalInfo sequence] = loadExperimentXML(pathToXML)
% [generalInfo sequence] = loadExperimentXML(pathToXML)
% 
% loadExperimentXML parses an experiment XML file from PrairieView into
% MATLAB-friendly variables. Not every single parameters recorded in the
% XML file is parsed, but only the most useful for post-processing. Some of
% the parameters might have a slighlty different name in the MATLAB
% variable for readability sake
% 
% ARGUMENTS
% pathToXML - a string containing the full path to an XML file
% 
% OUTPUT
% generalInfo - a struct with general info on the experiment
% sequence - a struct with specific info on the data acquired (info on each
% frame, voltage recordings and some meta-data)
% 
% Created by: Leonardo Lupori 06/04/2018
% Last edited: Leonardo Lupori 21/07/2018

% Load the XML as a struct
s = xml2struct(pathToXML);

%%% EXTRACT GENERAL INFORMATION ON THE EXPERIMENT
% General info
generalInfo.general.PrairieViewVersion = s.PVScan.Attributes.version;
generalInfo.general.experimentDate = s.PVScan.Attributes.date;


stateValues = s.PVScan.PVStateShard.PVStateValue;
for i = 1:size(stateValues,2) % Cycle trhough all the state values and load some
    key = stateValues{i}.Attributes.key;
    switch key
        % SCANSION related fields
        case 'activeMode'
            generalInfo.scansion.scanningMode = stateValues{i}.Attributes.value;
        case 'bitDepth'
            generalInfo.scansion.bitDepth = str2double(stateValues{i}.Attributes.value);
        case 'dwellTime'
            generalInfo.scansion.dwellTime = str2double(stateValues{i}.Attributes.value);
        case 'positionCurrent'
            subValues = stateValues{i}.SubindexedValues;
            generalInfo.scansion.startPositionZ = str2double(subValues.SubindexedValue.Attributes.value);
        case 'laserWavelength'
            generalInfo.scansion.laserWavelength = str2double(stateValues{i}.IndexedValue.Attributes.value);
        case 'laserPower'
            generalInfo.scansion.laserPower = str2double(stateValues{i}.IndexedValue.Attributes.value);
        % OPTICS related fields
        case 'objectiveLens'
            generalInfo.optics.objectiveLens = stateValues{i}.Attributes.value;
        case 'objectiveLensMag'
            generalInfo.optics.objectiveLensMag = str2double(stateValues{i}.Attributes.value);
        case 'objectiveLensNA'
            generalInfo.optics.objectiveLensNA = str2double(stateValues{i}.Attributes.value);
        case 'opticalZoom'
            generalInfo.optics.opticalZoom = str2double(stateValues{i}.Attributes.value);
        % IMAGE related fields
        case 'micronsPerPixel'
            generalInfo.image.micronsPerPixelX = str2double(stateValues{i}.IndexedValue{1}.Attributes.value);
            generalInfo.image.micronsPerPixelX = str2double(stateValues{i}.IndexedValue{2}.Attributes.value);
        case 'pixelsPerLine'
            generalInfo.image.pixelsPerLine = str2double(stateValues{i}.Attributes.value);
        case 'linesPerFrame'
            generalInfo.image.linesPerFrame = str2double(stateValues{i}.Attributes.value);
        case 'rotation'
            generalInfo.image.rotation = str2double(stateValues{i}.Attributes.value);
        % PMT related fields
        case 'pmtGain'
            generalInfo.pmt.greenPMT_power = str2double(stateValues{i}.IndexedValue{2}.Attributes.value);
            generalInfo.pmt.greenPMT_isActive = logical(generalInfo.pmt.greenPMT_power);
            generalInfo.pmt.redPMT_power = str2double(stateValues{i}.IndexedValue{1}.Attributes.value);
            generalInfo.pmt.redPMT_isActive = logical(generalInfo.pmt.redPMT_power);
    end
end

%%% EXTRACT INFORMATION ON THE IMAGE FILES

numOfSequences = size(s.PVScan.Sequence,2);
% Preallocation of the struct of sequences
sequence(numOfSequences) = struct();
for seq = 1:numOfSequences
    if numOfSequences > 1 % more than on sequence (need to index it as a cell)
        currentSequence = s.PVScan.Sequence{seq};
    else % only one sequence (can index it without brackets)
        currentSequence = s.PVScan.Sequence;
    end
    sequence(seq).type = currentSequence.Attributes.type;
    sequence(seq).time = currentSequence.Attributes.time;
    sequence(seq).cycle = currentSequence.Attributes.cycle;
    if isfield(currentSequence,'VoltageRecording')
        sequence(seq).voltageRecording = currentSequence.VoltageRecording.Attributes;
    end
    % Preallocation of the struct of frames
    numOfFrames = size(currentSequence.Frame,2);
    sequence(seq).frame(numOfFrames) = struct();
    for fr = 1:numOfFrames
        if numOfFrames > 1
            currentFrame = currentSequence.Frame{fr};
        else
            currentFrame = currentSequence.Frame;
        end
        sequence(seq).frame(fr).index = str2double(currentFrame.Attributes.index);
        sequence(seq).frame(fr).absoluteTime = str2double(currentFrame.Attributes.absoluteTime);
        sequence(seq).frame(fr).relativeTime = str2double(currentFrame.Attributes.relativeTime);
        sequence(seq).frame(fr).parameterSet = currentFrame.Attributes.parameterSet;
        channelsActive = size(currentFrame.File,2);
        for ch = 1:channelsActive
            if channelsActive > 1
                currentChannel = currentFrame.File{ch};
            else
                currentChannel = currentFrame.File;
            end
            if strcmpi(currentChannel.Attributes.channelName,'Red')
                sequence(seq).frame(fr).redChannelFrame = currentChannel.Attributes.filename;
            elseif strcmpi(currentChannel.Attributes.channelName,'Green')
                sequence(seq).frame(fr).greenChannelFrame = currentChannel.Attributes.filename;
            end
        end
    end
end
