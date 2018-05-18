function [redActive, greenActive] = channelsActive(sequenceStruct)
% [redActive, greenActive, uniqueID] = channelsActive(sequenceStruct)
% 
% channelsActive provides information about which image channels are
% present in a specific sequence struct. It analyzes the sequenceStruct  in
% input and outputs a boolean for each channel indicating its presence.
% 
% ARGUMENTS
% sequenceStruct - A structure containing the experiment information (can 
% be obtained from the function loadExperimentXML)
% 
% OUTPUT
% redActive - A boolean indicating whether the red channel is active
% greenActive - A boolean indicating whether the green channel is active
% 
% Created by: Leonardo Lupori 09/04/2018
% 
% see also loadExperimentXML

if ~isfield(sequenceStruct,'frame')
    error('The specified sequenceStruct does not have any frames information in it.')
end

redActive = false;
greenActive = false;

if isfield(sequenceStruct.frame,'redChannelFrame')
    redActive = true;
end
if isfield(sequenceStruct.frame,'greenChannelFrame')
    greenActive = true;
end