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

function tab = mixer_times(time, bools) 
%MIXER_TIMES Calculate mixer run durations, intervals, and duty ratios
%
% This function analyzes a binary mixer signal to compute the start 
% times of mixer runs, the duration of each run, the interval between 
% consecutive runs, and the duty ratio (runtime / interval). The results 
% are returned in a table.
%
% Syntax: tab = mixer_times(time, bools) 
%
% Inputs:
%   time  - Nx1 duration vector representing time points
%   bools - Nx1 logical or numeric vector (0 or 1) indicating mixer 
%           on/off states at each time point
%
% Outputs:
%   tab - MATLAB table with the following variables:
%       times          - start time of each mixer run (duration)
%       interval_times - interval between consecutive runs (seconds)
%       runtimes       - duration of each mixer run (seconds)
%       ratio          - duty ratio (runtimes ./ interval_times)
%
% Notes:
%   - NaN values in `bools` are removed prior to analysis.
%   - The first and last states are forced to 0 (mixer off) to ensure 
%     correct interval calculations.
%   - The last row of the output table is removed to avoid incomplete 
%     intervals or runs.
%
% Example:
%   t = duration(12,0,0) + minutes(0:10:120);
%   b = [0 1 1 0 0 1 0 1 1 0 0 0 1]';
%   tab = mixer_times(t, b)

%------------- BEGIN CODE --------------
 
    % Remove NaN values
    valid_indices = ~isnan(bools);
    bools_filtered = bools(valid_indices);
    time_filtered = time(valid_indices);
    
    % Force first and last element to be mixer off
    bools_filtered(1) = 0;
    bools_filtered(end) = 0;
    
    % Preallocate output arrays
    max_transitions = sum(diff(bools_filtered) ~= 0);
    times = duration.empty(max_transitions, 0);
    interval_times = zeros(1, max_transitions);
    runtimes = zeros(1, max_transitions);
    
    % Initialize variables
    start_time = nan;
    interval_index = 0;
    run_index = 0;
    
    % Calculate interval and run times
    for i = 2:length(bools_filtered)
        
        % Start of mixer run
        if (bools_filtered(i-1) == 0 && bools_filtered(i) == 1)
            if ~isnan(start_time)
                interval_index = interval_index + 1;
                interval_times(interval_index) = ...
                    seconds(time_filtered(i) - start_time);
            end
        start_time = time_filtered(i);
        
        % End of mixer run
        elseif (bools_filtered(i-1) == 1 && bools_filtered(i) == 0)
            run_index = run_index + 1;
            end_time = time_filtered(i);
            runtimes(run_index) = seconds(end_time - start_time);
            times(run_index) = start_time;
        end
    end
    
    % Remove unused preallocated elements
    times = times(1:run_index);
    interval_times = interval_times(1:run_index);
    runtimes = runtimes(1:run_index);
    
    % Calculate ratio
    ratio =  runtimes./interval_times;
    
    % Make table
    tab = table(times', interval_times', runtimes', ratio', ...
        'VariableNames', {'times', 'interval_times', ...
        'runtimes', 'ratio'});

    % Remove last row
    tab(end, :) = [];  
end