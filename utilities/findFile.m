function [logicalList names] = findFile(folderPath,fileSubString)
% [logicalList names] = findFile(folderPath,fileSubString)


content = struct2table(dir(folderPath));
indexes = regexpi(content.name,fileSubString);
isDirList = content.isdir==1;  %tells if item is a directory
matchStringList = false(size(indexes,1),1); %tells if item matches subfolderString
% update matchStringList for every item in the directory
for i=1:size(indexes,1)
    if isempty(indexes{i})
        matchStringList(i) = false;
    else
        matchStringList(i) = true;
    end
end
% Only select items that are both non-directories and match subfolderString 
logicalList = ~isDirList & matchStringList;
names = content.name(logicalList);