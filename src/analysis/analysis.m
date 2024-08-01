%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under the terms 
of GNU General Public License as published by the Free Software Foundation. For more 
information and the LICENSE file, see <https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%% Clear and close
close all; 
clear; 
clc;

%% Get file path
path = mfilename('fullpath');
[filepath, name, ext] = fileparts(path);
cd(filepath);

%% Read file and set directory
% Read multiple files from custom directory
directory = "D:\GitHub\Node-RED-3DSeeP\src\analysis\logs\20240722_Arjen\";
nodeRed = readData(directory);

%% Settings for layout
% X-axis
xTick = 30; % Interval of ticks on x-axis in minutes
xLimits = [floorToNearest(nodeRed.desktop_time(1), xTick) ceilToNearest(nodeRed.desktop_time(end), xTick)];
xticks = xLimits(1):minutes(xTick):xLimits(2);
% Set default marker size and line width
set(0, 'DefaultLineMarkerSize', 2);
set(0, 'DefaultLineLineWidth', 1.5);

%% Settings for analysis
% Window for correlations, mean, std, etc. 
windowStart = duration(10, 17, 0); 
windowEnd = duration(12, 8, 0);

%% Add columns missing in older versions of the data logger
% Printhead: pressure
if ~any(strcmp(nodeRed.Properties.VariableNames, 'printhead_pressure_bar'))
  nodeRed.printhead_pressure_bar = (nodeRed.printhead_box1_io_ai0_ma - 4) / 16 * 10;
end
% MAI MULTIMIX: Water temperature mixer inlet
if ~any(strcmp(nodeRed.Properties.VariableNames, 'mai_water_temp_mixer_inlet_c'))
  nodeRed.mai_water_temp_mixer_inlet_c = zeros(height(nodeRed), 1);
end

%% Calculations: Convert sensor data
% Differential pressure
k = 60; % ~6 seconds, 10 samples per second
filtered1 = movmean(nodeRed.material_io_ai0_pressure_bar, k, 'omitnan');
filtered2 = movmean(nodeRed.material_io_ai1_pressure_bar, k, 'omitnan');
nodeRed.material_differential_pressure_bar = filtered1 - filtered2;
% Filtered values from coriolis io (if connected)
nodeRed.material_coriolis_mass_flow_filtered_90s_kg_min = (nodeRed.material_io_ai4_ma - 4) / 16 * 16;
nodeRed.material_coriolis_density_filtered_90s_kg_m3 = (nodeRed.material_io_ai5_ma - 4) / 16 * 400 + 2000;
% Mixer timing
[times, intervalTimes, runTimes] = mixerTimes(nodeRed.desktop_time, nodeRed.mai_mixer_run_bool);
% Temperature pumping chamber MAI MULTIMIX
nodeRed.mai_temperature_pumping_chamber_c = (nodeRed.material_io_ai2_ma - 4) / 16 * 100;

%% Get time in minutes and seconds
nodeRed.seconds = seconds(nodeRed.desktop_time) - seconds(nodeRed.desktop_time(1));
nodeRed.minutes = minutes(nodeRed.desktop_time) - minutes(nodeRed.desktop_time(1));

%% Calculate properties
% Index of window
[~, index1] = min(abs(nodeRed.desktop_time - windowStart));
[~, index2] = min(abs(nodeRed.desktop_time - windowEnd));
% Calculate mean, std, min and max
meanValues = varfun(@(x) mean(x, 'omitnan'), nodeRed(index1:index2, :));
stdValues = varfun(@(x) std(x, 'omitnan'), nodeRed(index1:index2, :));
minValues = varfun(@(x) min(x, [], 'omitnan'), nodeRed(index1:index2, :));
maxValues = varfun(@(x) max(x, [], 'omitnan'), nodeRed(index1:index2, :));
% Remove '_Fun' from column names
meanValues.Properties.VariableNames = strrep(minValues.Properties.VariableNames, 'Fun_', '');
stdValues.Properties.VariableNames = strrep(maxValues.Properties.VariableNames, 'Fun_', '');
minValues.Properties.VariableNames = strrep(minValues.Properties.VariableNames, 'Fun_', '');
maxValues.Properties.VariableNames = strrep(maxValues.Properties.VariableNames, 'Fun_', '');

%% Mixer time properties
% Calculate indices
[~, index3] = min(abs(times - windowStart));
[~, index4] = min(abs(times - windowEnd));
% Extract data within the window
runTimes_window = runTimes(index3:index4);
intervalTimes_window = intervalTimes(index3:index4);
% Calculate mean, std, min, max for mixer_run_time
meanValues.mixer_run_time = mean(runTimes_window);
stdValues.mixer_run_time = std(runTimes_window);
minValues.mixer_run_time = min(runTimes_window);
maxValues.mixer_run_time = max(runTimes_window);
% Calculate mean, std, min, max for mixer_interval_time
meanValues.mixer_interval_time = mean(intervalTimes_window);
stdValues.mixer_interval_time = std(intervalTimes_window);
minValues.mixer_interval_time = min(intervalTimes_window);
maxValues.mixer_interval_time = max(intervalTimes_window);
% Calculate mean, std, min, max for mixer_ratio
ratioValues = runTimes_window ./ intervalTimes_window;
ratioValues = ratioValues(isfinite(ratioValues));
meanValues.mixer_ratio = mean(ratioValues);
stdValues.mixer_ratio = std(ratioValues);
minValues.mixer_ratio = min(ratioValues);
maxValues.mixer_ratio = max(ratioValues);

%% Plot pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_io_ai0_pressure_bar, '.k')
plot(nodeRed.desktop_time, nodeRed.material_io_ai1_pressure_bar, '.b')
% Limits
ylim([0 25])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'pressure')

%% Plot differential pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_differential_pressure_bar, '.k')
yyaxis right
plot(nodeRed.desktop_time, nodeRed.printhead_pressure_bar, '.b')
% Limits
yyaxis left
ylim([0 1.4])
yyaxis right
ylim([0 1.4])
xlim(xLimits)
% Labels
xlabel('Time')
yyaxis left
ylabel('Differential pressure [bar]')
yyaxis right
ylabel('Differential pressure [bar]')
% Legend
legend('Differential pressure coriolis', 'Differential pressure printhead', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
saveFigure(fig, 'differential_pressure')

%% Plot viscocity
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_coriolis_dynamic_viscocity_cp, '.k')
% Limits
ylim([0 6000])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Apparent dynamic viscocity [cP]')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'viscocity')

%% Plot exciter current
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_coriolis_exciter_current_1_ma, '.k')
% Limits
ylim([0 10])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Exciter current 1 [mA]')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'exciter_current_1')

%% Plot mass flow rate
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_coriolis_mass_flow_kg_min, '.k')
plot(nodeRed.desktop_time, nodeRed.material_coriolis_mass_flow_filtered_90s_kg_min, '.b')
% Limits
ylim([0 12])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Mass flow rate [kg/min]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mass_flow')

%% Plot temperature
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_coriolis_temperature_c, '.k')
plot(nodeRed.desktop_time, nodeRed.mai_temperature_pumping_chamber_c, '.b')
% Limits
ylim([26 36])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Mortar temperature [C]')
% Legend
text1 = "Coriolis sensor: " + round(meanValues.material_coriolis_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.material_coriolis_temperature_c*100)/100;
text2 = "Pumping chamber: " + round(meanValues.mai_temperature_pumping_chamber_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.mai_temperature_pumping_chamber_c*100)/100;
legend(text1, text2, 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mortar_temperature')

%% Plot density
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_coriolis_density_kg_m3, '.k')
plot(nodeRed.desktop_time, nodeRed.material_coriolis_density_filtered_90s_kg_m3, '.b')
% Limits
ylim([2320 2400])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Density [kg/m^{3}]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'density')

%% Plot pump frequency
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.mai_pump_speed_chz./100, '.k')
% Limits
ylim([0 50])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Pump frequency [Hz]')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mortar_pump_frequency')

%% Plot pump output power
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.mai_pump_output_power_w, '.k')
% Limits
ylim([0 800])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Pump output power [W]')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mortar_pump_output_power')

%% Plot water temperature
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.mai_water_temp_c, '.k')
plot(nodeRed.desktop_time, nodeRed.mai_water_temp_mixer_inlet_c, '.b')
% Limits
ylim([floor(min(nodeRed.mai_water_temp_c)-1), ceil(max(nodeRed.mai_water_temp_c)+1)])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Water temperature [C]')
% Legend
legend('Sensor 1: Original', 'Sensor 2: Mixer inlet', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'water_temperature')

%% Plot water flow
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.mai_water_flow_actual_lh, '.k')
plot(nodeRed.desktop_time, nodeRed.mai_water_flow_set_lh, '.b')
% Limits
ylim([160 220])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Water flow [L/h]')
% Legend
legend('Actual', 'Setpoint', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'water_flow')

%% Plot water pump frequency
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.mai_waterpump_output_freq_chz./100, '.k')
plot(nodeRed.desktop_time, nodeRed.mai_waterpump_ref_freq_chz./100, '.b')
% Limits
ylim([0 30])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Water pump freq. [Hz]')
% Legend
legend('Actual', 'Reference', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'water_pump_frequency')

%% Ambient temperature and relative humidity
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.material_io_ai7_ambient_temperature_c, '.k')
yyaxis right
plot(nodeRed.desktop_time, nodeRed.material_io_ai6_relative_humidity_perc, '.b')
% Limits
yyaxis left
ylim([floor(min(nodeRed.material_io_ai7_ambient_temperature_c)-2), ceil(max(nodeRed.material_io_ai7_ambient_temperature_c)+2)])
yyaxis right
ylim([floor(min(nodeRed.material_io_ai6_relative_humidity_perc)-2), ceil(max(nodeRed.material_io_ai6_relative_humidity_perc)+2)])
xlim(xLimits)
% Labels
xlabel('Time')
yyaxis left
ylabel('Ambient temperature [C]')
yyaxis right
ylabel('Relative humidity [%]')
% Legend
text1 = "Ambient temperature: " + round(meanValues.material_io_ai7_ambient_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.material_io_ai7_ambient_temperature_c*100)/100 + " C";
text2 = "Relative humidity: " + round(meanValues.material_io_ai6_relative_humidity_perc*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.material_io_ai6_relative_humidity_perc*100)/100 + " %";
legend(text1, text2, 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
saveFigure(fig, 'ambient_temperature')

%% Mixer times ratio (flow prediction)
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
k = 8;
plot(times, runTimes./intervalTimes, '.k')
plot(times, movmean(runTimes./intervalTimes, [k 0]), '-k')
% Limits
xlim(xLimits)
ylim([0 0.4])
% Labels
xlabel('Time')
ylabel('Run time / interval time')
% Legend
legend('Single run', sprintf('Moving mean k=%d', k), 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mixer_times_ratio')

%% Mixer times (flow prediction)
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
k = 8;
plot(times, intervalTimes, '.k')
plot(times, movmean(intervalTimes, [k 0]), '-k')
plot(times, runTimes, '.b')
plot(times, movmean(runTimes, [k 0]), '-b')
% Limits
xlim(xLimits)
ylim([0 120])
% Labels
xlabel('Time')
ylabel('Mixer times [Seconds]')
% Legend
legend('Interval time', sprintf('Interval time mov. mean k=%d', k), 'Run time', sprintf('Run time mov. mean k=%d', k), 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
saveFigure(fig, 'mixer_times')

%% Correlation between temperature and differential pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.material_coriolis_temperature_c(index1:index2), nodeRed.material_differential_pressure_bar(index1:index2), '.k')
% Limits
ylim([floor(min(nodeRed.material_differential_pressure_bar(index1:index2))*10-1)/10, ceil(max(nodeRed.material_differential_pressure_bar(index1:index2))*10+1)/10])
xlim([floor(min(nodeRed.material_coriolis_temperature_c(index1:index2))-1), ceil(max(nodeRed.material_coriolis_temperature_c(index1:index2))+1)])
% Labels
xlabel('Mortar temperature [C]')
ylabel('Differential pressure [bar]')
% Write figure
saveFigure(fig, 'correlation_temp_dp')

%% Correlation between viscocity and differential pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2), nodeRed.material_differential_pressure_bar(index1:index2), '.k')
% Limits
ylim([floor(min(nodeRed.material_differential_pressure_bar(index1:index2))*10-1)/10, ceil(max(nodeRed.material_differential_pressure_bar(index1:index2))*10+1)/10])
xlim([floor(min(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500, ceil(max(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500])
% Labels
xlabel('Apparent dynamic viscocity [cP]')
ylabel('Differential pressure [bar]')
% Write figure
saveFigure(fig, 'correlation_viscocity_dp')

%% Report generator
% Create empty table
columnNames = {'Variable', 'Mean', 'Std', 'Min', 'Max'};
varTypes = {'string', 'string', 'string', 'string', 'string'};
T = table('Size', [0, 5], 'VariableTypes', varTypes, 'VariableNames', columnNames);
% Add data
columns = {'mai_pump_speed_chz',...
    'mai_pump_output_power_w',...
    'mai_water_temp_c',...
    'mai_water_temp_mixer_inlet_c',...
    'mai_water_flow_set_lh',...
    'material_io_ai0_pressure_bar',...
    'material_io_ai1_pressure_bar',...
    'material_differential_pressure_bar',...
    'material_coriolis_dynamic_viscocity_cp',...
    'material_coriolis_temperature_c',...
    'material_coriolis_density_kg_m3',...
    'material_io_ai7_ambient_temperature_c',...
    'material_io_ai6_relative_humidity_perc',...
    'printhead_pressure_bar',...
    'mixer_interval_time',...
    'mixer_run_time',...
    'mixer_ratio'};
decimals = [0, 0, 2, 2, 0, 2, 2, 3, 0, 2, 0, 2, 2, 3, 1, 1, 3];
for i = 1:length(columns)
   % Define the new row data
    newRow = {columns{i},...
        round(meanValues.(columns{i}), decimals(i)),... 
        round(stdValues.(columns{i}), decimals(i)),... 
        round(minValues.(columns{i}), decimals(i)),... 
        round(maxValues.(columns{i}), decimals(i))};
    % Add the new row to the table
    T(end+1, :) = newRow;
end
% Import report generator
import mlreportgen.report.*
import mlreportgen.dom.*
% Create a PDF report
report = Report('report', 'pdf');
% Add a title to the report
title = Paragraph('Report 3DCP');
title.Style = {Bold(true), FontSize('14pt')};
add(report, title);
% Convert MATLAB table to a DOM table
domTable = BaseTable(T);
% Add the DOM table to the report
add(report, domTable);
% Close the report to generate the PDF
close(report);
% View the report
rptview(report);

%% End
disp('End of script')

%% Functions

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
    fig.Units = 'inches';
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
