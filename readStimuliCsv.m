function stimuluiTable = readStimuliCsv(pathToFile)
% stimuluiTable = readStimuliCsv(pathToFile)
% 
% readStimuliCsv reads a CSV file containing the stimuli specification and
% parse the data into a MATLAB table. The stimuli CSV has to have column
% header in text (without spaces) describing the stimulus variable that the
% column defines. The first row contains text headers, while all the other
% rows contain values defining a stimulus condition.
% 
% ARGUMENTS
% pathToFile - A string containing the full path to the CSV file
% 
% OUTPUT
% stimuluiTable - A table (n-by-m) containing n stimuli, each defined by m
% variables.
% 
% Created by: Leonardo Lupori 08/feb/2019


[data, titles] = xlsread(pathToFile);
% assemple the output table
stimuluiTable = array2table(data, 'VariableNames', titles);