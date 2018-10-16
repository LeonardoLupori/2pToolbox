function [bool handleOrPath]=misField(handleOrPath,field)
% [bool fileHandle] = misField(handleOrPath,field)
%
% check if 'field' is a subfield of the matfile 'handle'
%
% INPUT 
% handle: handle of or fullpath to matfile
% field : subfield name [string]
%
% OUTPUT
% bool: true or false...
% fileHandle: handle of matfile
%

if nargin <2
    error('This function needs two args...');
end

if ~ischar(field)
     error('The second input must be a string')
end

if ischar(handleOrPath)
    handleOrPath = matfile(handleOrPath,'Writable',true);
elseif ~isobject(handleOrPath)
   bool = isfield(handleOrPath,field);
   return;
end

info = whos(handleOrPath);

if sum(strcmpi({info.name},field))
    bool = true;
else
    bool = false; 
end