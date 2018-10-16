function positionTrace = buildPosition(voltageTrace, units, radius)
% positionTrace = buildPosition(voltageTrace)
% positionTrace = buildPosition(voltageTrace, units)
% positionTrace = buildPosition(voltageTrace, units, radius)
% 
% buildPosition generate a vector of positions of the specified unit from a
% voltage trace (Output of the 2P microscope)
% 
% ARGUMENTS
% -voltageTrace: a 1D array of voltage values (no restrictions on the actual
% voltage values as long as all the angular positions are represented once,
% i.e. the signal resets every full turn.
% -units(optional): (default: radians) Specifiy the units that you desire
% the output to be expressed in. Can be:
%       -'rad' radians
%       -'deg' degrees
%       -'cm'  centimeters - NOTE! this requires you to specify the radius in cm
% -radius: The radius of the rotating cylinder. Required only if you select
% "cm as units"
%
% see also:
% loadVoltageCSV, unwrap, rescale 



if nargin < 2
    units = 'rad';
end

rescaledSignal = rescale(voltageTrace,-pi,pi);
position = unwrap(rescaledSignal); % remove periodicity
position = position - position(1); % displacement from time=0

switch units
    case 'rad'
        positionTrace = position;
    case 'deg'
        positionTrace = rad2deg(position); 
    case 'cm'
        if nargin < 2
            error('Radius in cm is required to generate an output in "cm" units.')
        end
        positionTrace = position*radius;
end

