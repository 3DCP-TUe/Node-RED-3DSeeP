%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

% READ_DATA Read and concatenate CSV files from a folder
%
%   data = READ_DATA(directory) reads all CSV files in the specified
%   directory and concatenates them into a single table, excluding any
%   files whose names contain "EventComments".
%
%   Input:
%       directory - Path to the folder containing CSV files
%
%   Output:
%       data - Table containing the concatenated contents of all CSV files
%
%   Notes:
%       - The function throws an error if the folder does not exist or if
%         no CSV files are found.
%       - Files containing "EventComments" in their name are skipped.
%
%   Example:
%       data = read_data('C:\Users\Username\DataFolder');
function [data] = read_data(directory)
    
    % Check if the directory exists
    if ~isfolder(directory)
        error('ERROR: The specified directory does not exist.');
    end
    
    % Get the list of CSV files in the directory
    files = dir(fullfile(directory, '*.csv'));
    if isempty(files)
        error(['ERROR: ' ...
            'No .csv files found in the specified folder.']);
    end
    
    %Read files and append if multiple
    data = [];
    for i = 1:length(files)
        if ~contains(files(i).name, "EventComments")
            data = [data; readtable(fullfile(directory, ...
                files(i).name))];
        end
    end
    
end