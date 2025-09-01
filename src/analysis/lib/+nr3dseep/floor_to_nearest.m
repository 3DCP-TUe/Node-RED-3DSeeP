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
%   floored = floor_to_nearest(d, m)
%       - d: duration or array of durations
%       - m: interval in minutes

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