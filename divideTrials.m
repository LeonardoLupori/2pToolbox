function trialLimits = divideTrials(stimulusTrace, code, correctionsMode, preStimCode)
% 
% trialLimits = divideTrials(stimulusTrace, code)
% trialLimits = divideTrials(stimulusTrace, code, correctionsMode)
% trialLimits = divideTrials(stimulusTrace, code, correctionsMode, preStimCode)
% 
% divideTrials accepts the stimuli trace and returns a n-by-3 matrix
% containing the indices for the beginning (1st column) and the end (2nd
% column) frames of every trial containing the stimulation code specified
% by the argument code. The 3rd column contains the index of the stimulus
% onset A trial is defined as a pre-stimulation period (identified with a
% preStimCode) and a postStimulationPeriod (identified with the stimulus
% code). Trials begin at the last "preStimCode" found going backwards from
% the start of the stimulation. Trials end at the last "code" found after
% the start of the stmulation.
% 1
% OUTPUTS: 
% trialLimits: a n-by-3 matrix containing the indices for the
% beginning, the end and the stimulus onset frames of every trial
% containing the stimulation code specified by the argument code.
% 
% ARGUMENTS:
% stimulusTrace: a vector containing the stimulus codes.
% code: the stimulus code for which to define trial limits.
% correctionsMode: 'verbose' (default) or 'silent'. In verbose mode, the
% function outputs a warning for every trial that has an unusual number of
% preStim or postStim frames, before correcting it.
% preStimCode: (default:1) code assigned to the prestim condition (usually
% gray).
% 
%  Leonardo Lupori 07-Feb-2019
if nargin<3
    correctionsMode = 'verbose';
    preStimCode = 1;
elseif nargin <4
    preStimCode = 1;
    if ~any(strcmpi(correctionsMode,{'verbose','silent'}))
        error('correctionsMode must be either "verbose" or "silent"')
    end
end

temp = diff(stimulusTrace == code);
startOfStim = find(temp == 1)+1;    % indices for the START of the given stim code
endOfStim = find(temp == -1);       % indices for the END of the given stim code

if isempty(startOfStim)
    error('Stimulus code %i not present in the stimulus trace.',code)
end

% Initialize output variable
trialLimits = zeros(size(startOfStim,1),3);
% For every stimulation this determines the beginning and the end. Trials
% begin at the last "preStimCode" found going backwards from the start of
% the stimulation. Trials end at the last "code" found after the start of
% the stmulation.
for i = 1:size(startOfStim,1)
    % Determine beginning of the trial
    condition = stimulusTrace(1:startOfStim(i)-1) ~= preStimCode;
    trialLimits(i,1) = find(condition,1,'last')+1;
    % Determine the end of the trial
    toIndex = find(endOfStim>startOfStim(i),1,'first');
    trialLimits(i,2) = endOfStim(toIndex);
end
trialLimits(:,3) = startOfStim;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% QUALITY ASSURANCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Every trial has to have the same number of prestim and postStim frames

preStimLength = startOfStim-trialLimits(:,1);
postStimLength = trialLimits(:,2)-startOfStim+1;

% Check for trials with strange preStim length (preStim different from the mode)
standardPreStim = preStimLength == mode(preStimLength);
% If present, correct those trials
if ~all(standardPreStim)
    toAdjust = find(standardPreStim~=1);
    for i = 1:length(toAdjust)
        trialLimits(toAdjust(i),1) = startOfStim(toAdjust(i)) - mode(preStimLength);
        if strcmpi(correctionsMode,'verbose')
            warning('Trial %i/%i (code=%i) corrected for preStim length: from %i to %i frames.',...
                toAdjust(i), size(startOfStim,1), code,...
                preStimLength(toAdjust(i)), mode(preStimLength))
        end
    end
end

% Check for trials with strange postStim length (postStim different from the mode)
standardPostStim = postStimLength == mode(postStimLength);
% If present, correct those trials
if ~all(standardPostStim)
    toAdjust = find(standardPostStim~=1);
    for i = 1:length(toAdjust)
        trialLimits(toAdjust(i),2) = startOfStim(toAdjust(i)) + mode(postStimLength) -1;
        if strcmpi(correctionsMode,'verbose')
            warning('Trial %i/%i (code=%i) corrected for postStim length: from %i to %i frames.',...
                toAdjust(i), size(startOfStim,1), code,...
                postStimLength(toAdjust(i)), mode(postStimLength))
        end
    end
end