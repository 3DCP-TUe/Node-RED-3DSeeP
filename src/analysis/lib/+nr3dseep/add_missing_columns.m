%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%ADD_MISSING_COLUMNS Adds default columns to a table if missing
%
%   data = add_missing_columns(data) checks if certain expected columns
%   exist in the input table DATA. If a column is missing, it is added
%   with default values:
%       - 'printhead_pressure_bar' : calculated from 'printhead_box1_io_ai0_ma'
%       - 'printhead_mortar_temperature_c' : zeros
%       - 'mai_pumping_chamber_mortar_temperature_c' : zeros
%       - 'mai_silo_dry_mortar_temperature_c' : zeros
%       - 'mai_water_temp_mixer_inlet_c' : zeros
%
%   Inputs:
%       data - MATLAB table containing process or sensor data
%
%   Outputs:
%       data - table with missing columns added and initialized
%
%   Notes:
%       The function assumes that if 'printhead_pressure_bar' is missing,
%       'printhead_box1_io_ai0_ma' exists to compute its values.
function data = add_missing_columns(data)
    
    % Printhead: pressure
    if ~any(strcmp(data.Properties.VariableNames, ...
            'printhead_pressure_bar'))
        data.printhead_pressure_bar = ...
            (data.printhead_box1_io_ai0_ma - 4) / 16 * 10;
    end
    
    % Printhead: mortar temperature
    if ~any(strcmp(data.Properties.VariableNames, 'printhead_mortar_temperature_c'))
        data.printhead_mortar_temperature_c = zeros(height(data), 1);
    end
    
    % MAI MULTIMIX: Mortar temperature at pumping chamber
    if ~any(strcmp(data.Properties.VariableNames, 'mai_pumping_chamber_mortar_temperature_c'))
        data.mai_pumping_chamber_mortar_temperature_c = zeros(height(data), 1);
    end
    
    % MAI MULTIMIX: Mortar temperature at silo
    if ~any(strcmp(data.Properties.VariableNames, 'mai_silo_dry_mortar_temperature_c'))
        data.mai_silo_dry_mortar_temperature_c = zeros(height(data), 1);
    end
    
    % MAI MULTIMIX: Additional water temperature sensor
    if ~any(strcmp(data.Properties.VariableNames, 'mai_water_temp_mixer_inlet_c'))
        data.mai_water_temp_mixer_inlet_c = zeros(height(data), 1);
    end
end