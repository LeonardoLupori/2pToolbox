function [logicalList names] = findSubfolders(folderPath, subfolderString)
% logicalList = findSubfolders(folderPath, subfolderString)

content = struct2table(dir(folderPath));
indexes = regexpi(content.name,subfolderString);
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
% Only select items that are both directories and match subfolderString 
logicalList = isDirList & matchStringList;
names = content.name(logicalList);