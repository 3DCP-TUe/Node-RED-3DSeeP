%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

classdef lib
    methods(Static)

        % -----------------------------------------------------------------

        % Reads and combines all CSV files from a given directory
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
            % Create and navigate to save folder
            saveFolderName = fullfile(directory, "Results");
            if ~exist(saveFolderName, 'dir' )
                mkdir(saveFolderName)
            end
            cd(saveFolderName)
        end
        
        % -----------------------------------------------------------------
        
        % Mixer run and interval times
        function [times, intervalTimes, runTimes] = mixer_times(time, ...
                bools) 
            % Remove NaN values
            validIndices = ~isnan(bools);
            boolsFiltered = bools(validIndices);
            timeFiltered = time(validIndices);
            % Force first and last element to be mixer off
            boolsFiltered(1) = 0;
            boolsFiltered(end) = 0;
            % Preallocate output arrays
            max_transitions = sum(diff(boolsFiltered) ~= 0);
            times = duration.empty(max_transitions, 0);
            intervalTimes = zeros(1, max_transitions);
            runTimes = zeros(1, max_transitions);
            % Initialize variables
            startTime = nan;
            intervalIndex = 0;
            runIndex = 0;
            % Calculate interval and run times
            for i = 2:length(boolsFiltered)
                % Start of mixer run
                if (boolsFiltered(i-1) == 0 && boolsFiltered(i) == 1)
                    if ~isnan(startTime)
                        intervalIndex = intervalIndex + 1;
                        intervalTimes(intervalIndex) = ...
                            seconds(timeFiltered(i) - startTime);
                    end
                startTime = timeFiltered(i);
                % End of mixer run
                elseif (boolsFiltered(i-1) == 1 && boolsFiltered(i) == 0)
                    runIndex = runIndex + 1;
                    endTime = timeFiltered(i);
                    runTimes(runIndex) = seconds(endTime - startTime);
                    times(runIndex) = startTime;
                end
            end
            % Remove unused preallocated elements
            times = times(1:runIndex);
            intervalTimes = intervalTimes(1:runIndex);
            runTimes = runTimes(1:runIndex);  
        end
        
        % -----------------------------------------------------------------

        % Write figure
        function [] = save_figure(fig, name) 
            width = fig.Position(3);
            height = fig.Position(4);
            set(gcf, 'PaperPosition', [0 0 width height]);
            set(gcf, 'PaperSize', [width height]); 
            saveas(fig, name, 'pdf')
        end
        
        % -----------------------------------------------------------------

        % Floor duration
        function flooredDuration = floor_to_nearest(d, m)
            % Convert the duration to total minutes
            totalMinutes = minutes(d);
            % Determine the nearest floor in minutes
            flooredMinutes = floor(totalMinutes / m) * m;
            % Convert minutes back to duration
            flooredHours = floor(flooredMinutes / 60);
            flooredMinutes = mod(flooredMinutes, 60);
            flooredDuration = duration(flooredHours, flooredMinutes, 0, 0);
        end
        
        % -----------------------------------------------------------------

        % Ceil duration
        function ceiledDuration = ceil_to_nearest(d, m)   
            % Convert the duration to total minutes
            totalMinutes = minutes(d);
            % Determine the nearest ceil in minutes
            if mod(totalMinutes, m) == 0
                % If already at an exact multiple of m
                ceiledMinutes = totalMinutes;
            else
                % Round up to the next multiple of m
                ceiledMinutes = ceil(totalMinutes / m) * m;
            end
            % Convert minutes back to duration
            ceiledHours = floor(ceiledMinutes / 60);
            ceiledMinutes = mod(ceiledMinutes, 60);
            ceiledDuration = duration(ceiledHours, ceiledMinutes, 0, 0);
        end

        % -----------------------------------------------------------------

        % Corrections for incorrect conversion of analog inputs 
        % Before v0.4.0 (Aug 12, 2024)
        function table = correction_analog_inputs(table)
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
        
        % -----------------------------------------------------------------
        
        function fig = figure_time_series(xticks, xlimits)
            % Create figure
            fig = figure;
            fig.Units = 'centimeters';
            fig.Position = [1 14 24 8];
            hold on
            grid on
            box on
            % Dummy plot: axis layout does not function correctly when the
            % figure is empty
            dum = plot([xlimits(1)-duration(1,0,0), ...
                xlimits(2)+duration(1,0,0)], [0, 0]);
            % Layout of x-axis
            ax = gca;
            set(ax, 'XTick',  xticks, 'XTickLabel', ...
                datestr(xticks, 'HH:MM'))
            xlim(xlimits)
            xlabel('Time')
            % Delete dummy
            delete(dum);
        end

        % -----------------------------------------------------------------

        % Adds missing columns
        function data = add_missing_columns(data)
            % Printhead: pressure
            if ~any(strcmp(data.Properties.VariableNames, 'printhead_pressure_bar'))
              data.printhead_pressure_bar = (data.printhead_box1_io_ai0_ma - 4) / 16 * 10;
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

        % -----------------------------------------------------------------
        
    end
end

