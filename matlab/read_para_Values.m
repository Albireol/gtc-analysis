function variableValues = read_para_Values(filename, variableName)
% Open the file for reading
fid = fopen(filename, 'r');
% Read the file line by line
tline = fgets(fid);
% Initialize the variable values
variableValues = [];
% Construct a regular expression to match the variable name
regex = [variableName '\s*=\s*([-+]?(\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?)'];
% Loop through the file until the end is reached
while ischar(tline)
    % Look for the variable name in the line
    [tokens, matches] = regexp(tline, regex, 'tokens', 'match');
    if ~isempty(matches)
        % If a match is found, extract the variable value
        variableValue = str2double(tokens{1});
        variableValues = [variableValues, variableValue];
    end
    % Read the next line
    tline = fgets(fid);
end
% Close the file
fclose(fid);
end


