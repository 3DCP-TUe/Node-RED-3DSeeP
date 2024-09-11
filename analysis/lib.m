%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under the terms 
of GNU General Public License as published by the Free Software Foundation. For more 
information and the LICENSE file, see <https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

classdef lib
    methods(Static)

        % Reads and combines all CSV files from a given directory
        function [data] = readData(directory)
            % Check if the directory exists
            if ~isfolder(directory)
                error('ERROR: The specified directory does not exist.');
            end
            % Get the list of CSV files in the directory
            files = dir(fullfile(directory, '*.csv'));
            if isempty(files)
                error('ERROR: No .csv files found in the specified folder.');
            end
            %Read files and append if multiple
            data = [];
            for i = 1:length(files)
                data = [data; readtable(fullfile(directory, files(i).name))];
            end
            % Create and navigate to save folder
            saveFolderName = fullfile(directory, "Results");
            if ~exist(saveFolderName, 'dir' )
                mkdir(saveFolderName)
            end
            cd(saveFolderName)
        end
        
        % Mixer run and interval times
        function [times, intervalTimes, runTimes] = mixerTimes(time, bools) 
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
                        intervalTimes(intervalIndex) = seconds(timeFiltered(i) - startTime);
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
        
        % Write figure
        function [] = saveFigure(fig, name) 
            width = fig.Position(3);
            height = fig.Position(4);
            set(gcf, 'PaperPosition', [0 0 width height]);
            set(gcf, 'PaperSize', [width height]); 
            saveas(fig, name, 'pdf')
        end
        
        % Floor duration
        function flooredDuration = floorToNearest(d, m)
            % Convert the duration to total minutes
            totalMinutes = minutes(d);
            % Determine the nearest floor in minutes
            flooredMinutes = floor(totalMinutes / m) * m;
            % Convert minutes back to duration
            flooredHours = floor(flooredMinutes / 60);
            flooredMinutes = mod(flooredMinutes, 60);
            flooredDuration = duration(flooredHours, flooredMinutes, 0);
        end
        
        % Ceil duration
        function ceiledDuration = ceilToNearest(d, m)   
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
            ceiledDuration = duration(ceiledHours, ceiledMinutes, 0);
        end

        % Corrections for incorrect conversion of analog inputs (before v0.4.0)
        function table = correctionAnalogInputs(table)
            % Pressure
            table.material_io_ai0_pressure_bar = table.material_io_ai0_pressure_bar * 27468 / 27648;
            table.material_io_ai1_pressure_bar = table.material_io_ai1_pressure_bar * 27468 / 27648;
            table.printhead_pressure_bar = table.printhead_pressure_bar * 27468 / 27648;
            % AI ports
            columnsToCorrect = contains(table.Properties.VariableNames, '_ma') & contains(table.Properties.VariableNames, 'ai');
            correctionFormula = @(x) (x - 4) * (27468 / 27648) + 4;
            table(:, columnsToCorrect) = varfun(correctionFormula, table(:, columnsToCorrect)); 
        end
    end
end

