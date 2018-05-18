function voltageTable = readVoltageCsv(pathToFile)
% voltageTable = readVoltageCsv(pathToFile)
% 
% readVoltageCsv reads a CSV file containing the voltage measurements
% recorded from the Bruker DAQ and parse the data into a MATLAB table.
% 
% ARGUMENTS
% pathToFile - A string containing the full path to the CSV file
% 
% OUTPUT
% voltageTable - A table with timestamps on the column "time_ms" and a new
% column for each channel recorded containing the voltage readings
% 
% Created by: Leonardo Lupori 23/04/2018

[data, titles] = xlsread(pathToFile);

columnNames = cell(size(titles)); % Inizialize a cell for the column names
% Loop to format the column names avoiding whitespaces and parentheses
for i=1:size(titles,2)
    if ~isempty(strfind(titles{i},'Time')) %avoids parentheses in Time(ms)
        columnNames{i} = 'time_ms';
    elseif ~isempty(strfind(titles{i},'Input')) %avoids whitespaces in Input X
        splitted = strsplit(titles{i});
        channelNumber = splitted{end};
        columnNames{i} = ['input_' channelNumber];
    end
end
% assemple the output table
voltageTable = array2table(data, 'VariableNames', columnNames);