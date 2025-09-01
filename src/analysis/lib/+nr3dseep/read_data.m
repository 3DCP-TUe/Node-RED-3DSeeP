% SPDX-License-Identifier: GPL-3.0-or-later
% Node-RED-3DSeeP
% Project: https://github.com/3DCP-TUe/Node-RED-3DSeeP
%
% Copyright (c) 2024-2025 Eindhoven University of Technology
%
% Authors:
%   - Derk Bos (2024)
%   - Arjen Deetman (2024-2025)
%
% For license details, see the LICENSE file in the project root.

function [data] = read_data(directory)
%READ_DATA Read and concatenate CSV files from a folder
%
% This function reads all CSV files in the specified directory and 
% concatenates them into a single table. Files whose names contain 
% "EventComments" are excluded from the import.
%
% Syntax: data = read_data(directory) 
%
% Inputs:
%   directory - string or character vector specifying the path to the 
%               folder containing CSV files
%
% Outputs:
%   data - MATLAB table containing the concatenated contents of all 
%          eligible CSV files
%
% Notes:
%   - An error is thrown if the specified folder does not exist.
%   - An error is thrown if no `.csv` files are found in the folder.
%   - Files containing "EventComments" in their name are skipped.
%
% Example:
%   data = read_data('C:\Users\Username\DataFolder');

%------------- BEGIN CODE --------------

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