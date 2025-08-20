%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%FLOOR_TO_NEAREST Floors a duration to the nearest interval in minutes
%   floored = floor_to_nearest(d, m)
%       - d: duration or array of durations
%       - m: interval in minutes
function floored = floor_to_nearest(d, m)
    
    % Convert the duration to total minutes
    total_minutes = minutes(d);
    
    % Determine the nearest floor in minutes
    floored_minutes = floor(total_minutes / m) * m;
    
    % Convert minutes back to duration
    floored_hours = floor(floored_minutes / 60);
    floored_minutes = mod(floored_minutes, 60);
    floored = duration(floored_hours, floored_minutes, 0, 0);
end