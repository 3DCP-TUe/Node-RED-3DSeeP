% SPDX-License-Identifier: GPL-3.0-or-later
% Node-RED-3DSeeP
% Project: https://github.com/3DCP-TUe/Node-RED-3DSeeP
%
% Copyright (c) 2024-2025 Eindhoven University of Technology
%
% Authors:
%   - Arjen Deetman (2024-2025)
%
% For license details, see the LICENSE file in the project root.

function tab = calculate_timetable_properties(timetab, times, window_start, window_end)
%CALCULATE_TIMETABLE_PROPERTIES Compute basic statistics for a timetable
%
% This function calculates summary statistics (mean, median, standard deviation, min, max)
% for each numeric column of a timetable TIMETAB within a specified time window.
%
% Syntax: tab = calculate_timetable_properties(timetab, times, window_start, window_end)
%
% Inputs:
%   timetab      - timetable containing numeric and/or duration variables
%   times        - vector of time values corresponding to rows of TIMETAB
%   window_start - start time for analysis window
%   window_end   - end time for analysis window
%
% Outputs:
%   tab - table with columns:
%           - 'variable' : name of the timetable variable
%           - 'mean'     : mean of values in window
%           - 'median'   : median of values in window
%           - 'std'      : standard deviation of values in window
%           - 'min'      : minimum value in window
%           - 'max'      : maximum value in window
%
% Notes:
%   - Columns of type duration are ignored.
%   - NaN values are automatically omitted from calculations.

%------------- BEGIN CODE --------------

    % Find indices for the window
    [~, index1] = min(abs(times - window_start));
    [~, index2] = min(abs(times - window_end));
    
    % Extract relevant rows
    selected = timetab(index1:index2, :);
    
    % Find columns with 'duration' type
    duration_columns = varfun(@(x) isa(x, 'duration'), selected, 'OutputFormat', 'uniform');
    selected(:, duration_columns) = [];
    
    % Calculate statistics
    mean_values = varfun(@(x) mean(x, 'omitnan'), selected);
    median_values = varfun(@(x) median(x, 'omitnan'), selected);
    std_values = varfun(@(x) std(x, 'omitnan'), selected);
    min_values = varfun(@(x) min(x, [], 'omitnan'), selected);
    max_values = varfun(@(x) max(x, [], 'omitnan'), selected);
    
    % Extract variable names (column names of timetab)
    column_names = selected.Properties.VariableNames';
    
    % Convert tables to arrays for easier concatenation
    mean_values = mean_values{:,:}';
    median_values = median_values{:,:}';
    std_values = std_values{:,:}';
    min_values = min_values{:,:}';
    max_values = max_values{:,:}';
    
    % Create final table with desired structure
    tab = table(column_names, mean_values, median_values, ...
        std_values, min_values, max_values, ...
        'VariableNames', {'variable', 'mean', 'median', 'std', 'min', 'max'});
end