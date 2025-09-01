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

function ceiled = ceil_to_nearest(d, m)   
%CEIL_TO_NEAREST Ceil a duration to the nearest multiple of m minutes
%
%   ceiled = ceil_to_nearest(d, m) returns a duration array where each
%   element of d is rounded up to the nearest multiple of m minutes.
%
%   Inputs:
%       d - duration array
%       m - interval in minutes to ceil to (positive scalar)
%
%   Output:
%       ceiled - duration array with values ceiled to nearest m minutes

%------------- BEGIN CODE --------------

    % Convert the duration to total minutes
    total_minutes = minutes(d);
    
    % Determine the nearest ceil in minutes
    if mod(total_minutes, m) == 0
        % If already at an exact multiple of m
        ceiled_minutes = total_minutes;
    else
        % Round up to the next multiple of m
        ceiled_minutes = ceil(total_minutes / m) * m;
    end
    
    % Convert minutes back to duration
    ceiled_hours = floor(ceiled_minutes / 60);
    ceiled_minutes = mod(ceiled_minutes, 60);
    ceiled = duration(ceiled_hours, ceiled_minutes, 0, 0);
end