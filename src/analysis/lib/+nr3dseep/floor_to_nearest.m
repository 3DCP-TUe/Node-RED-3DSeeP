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

function floored = floor_to_nearest(d, m)
%FLOOR_TO_NEAREST Floors a duration to the nearest interval in minutes
%
% This function takes a duration (or array of durations) and floors each 
% value to the nearest lower multiple of the specified minute interval M. 
% The output is returned as a duration object.
%
% Syntax: floored = floor_to_nearest(d, m) 
%
% Inputs:
%   d - duration or array of durations to be floored
%   m - positive scalar specifying the flooring interval in minutes
%
% Outputs:
%   floored - duration (or array of durations) floored to the nearest 
%             multiple of M minutes
%
% Notes:
%   - The flooring operation always rounds down to the nearest multiple 
%     of M minutes.
%   - If M does not evenly divide an hour, the resulting minutes will wrap 
%     correctly using modulo arithmetic.
%
% Example:
%   d = duration(2, 17, 0); % 2 hours 17 minutes
%   floored = floor_to_nearest(d, 15);
%   % floored = 2 hours 15 minutes

%------------- BEGIN CODE --------------

    % Convert the duration to total minutes
    total_minutes = minutes(d);
    
    % Determine the nearest floor in minutes
    floored_minutes = floor(total_minutes / m) * m;
    
    % Convert minutes back to duration
    floored_hours = floor(floored_minutes / 60);
    floored_minutes = mod(floored_minutes, 60);
    floored = duration(floored_hours, floored_minutes, 0, 0);
end