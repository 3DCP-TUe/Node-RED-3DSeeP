% SPDX-License-Identifier: GPL-3.0-or-later
% Node-RED-3DSeeP
% Project: https://github.com/3DCP-TUe/Node-RED-3DSeeP
%
% Copyright (c) 2024-2025 Endhoven University of Technology
%
% Authors:
%   - Arjen Deetman (2024-2025)
%
% For license details, see the LICENSE file in the project root.

function table = correction_analog_inputs(table)
%CORRECTION_ANALOG_INPUTS Corrects pre-v0.4.0 analog input conversion
%   Before v0.4.0 (Aug 12, 2024)
%   table = correction_analog_inputs(table) applies the correction
%   formula to pressure columns and analog input channels.
%   Ensures a 'date' column exists in the table.

%------------- BEGIN CODE --------------

    % Pressure
    table.material_io_ai0_pressure_bar = ...
        table.material_io_ai0_pressure_bar * 27468 / 27648;
    table.material_io_ai1_pressure_bar = ...
        table.material_io_ai1_pressure_bar * 27468 / 27648;
    table.printhead_pressure_bar = ...
        table.printhead_pressure_bar * 27468 / 27648;
    
    % AI ports
    columnsToCorrect = ...
        contains(table.Properties.VariableNames, '_ma') & ...
        contains(table.Properties.VariableNames, 'ai');
    correctionFormula = @(x) (x - 4) * (27468 / 27648) + 4;
    table(:, columnsToCorrect) = varfun(correctionFormula, ...
        table(:, columnsToCorrect)); 
end