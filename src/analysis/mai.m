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
directory = "D:\GitHub\Node-RED-3DSeeP\src\analysis\logs\20240708_Alberto2\";
nodeRed = lib.readData(directory);

%% Settings for layout
% X-axis
xTick = 30; % Interval of ticks on x-axis in minutes
xLimits = [lib.floorToNearest(nodeRed.desktop_time(1), xTick) lib.ceilToNearest(nodeRed.desktop_time(end), xTick)];
xticks = xLimits(1):minutes(xTick):xLimits(2);
% Set default marker size and line width
set(0, 'DefaultLineMarkerSize', 2);
set(0, 'DefaultLineLineWidth', 1.5);

%% Settings for analysis
% Window for correlations, mean, std, etc. 
windowStart = duration(11, 30, 0); 
windowEnd = duration(14, 0, 0);

%% Add columns missing in older versions of the data logger
% Printhead: pressure
if ~any(strcmp(nodeRed.Properties.VariableNames, 'printhead_pressure_bar'))
  nodeRed.printhead_pressure_bar = (nodeRed.printhead_box1_io_ai0_ma - 4) / 16 * 10;
end
% Printhead: mortar temperature
if ~any(strcmp(nodeRed.Properties.VariableNames, 'printhead_mortar_temperature_c'))
  nodeRed.printhead_mortar_temperature_c = nodeRed.printhead_box1_io_ai0_ma * 0.0 - 50;
end
% MAI MULTIMIX: Water temperature mixer inlet
if ~any(strcmp(nodeRed.Properties.VariableNames, 'mai_water_temp_mixer_inlet_c'))
  nodeRed.mai_water_temp_mixer_inlet_c = zeros(height(nodeRed), 1);
end

%% Calculations: Convert sensor data
% Differential pressure
k = 60; % ~3 seconds, 10 samples per second
filtered1 = movmean(nodeRed.material_io_ai0_pressure_bar, k, 'omitnan');
filtered2 = movmean(nodeRed.material_io_ai1_pressure_bar, k, 'omitnan');
filtered3 = movmean(nodeRed.printhead_pressure_bar, k, 'omitnan');
nodeRed.differential_pressure1_bar = filtered1 - filtered2;
nodeRed.differential_pressure2_bar = filtered2 - filtered3;
nodeRed.differential_pressure3_bar = filtered3;
% Pressure gradient
length1 = (150 + 144 + 820 + 184 + 113) / 1000;     %Coriolis
length2 = (150 + 13605 + 199 + 114) / 1000;         %Hose
length3 = (150 + 1013 + 95.5) / 1000;               %Printhead
nodeRed.pressure_gradient1_bar_m = nodeRed.differential_pressure1_bar / length1;
nodeRed.pressure_gradient2_bar_m = nodeRed.differential_pressure2_bar / length2;
nodeRed.pressure_gradient3_bar_m = nodeRed.differential_pressure3_bar / length3;
% Filtered values from coriolis io (if connected)
nodeRed.material_coriolis_mass_flow_filtered_90s_kg_min = (nodeRed.material_io_ai4_ma - 4) / 16 * 16;
nodeRed.material_coriolis_density_filtered_90s_kg_m3 = (nodeRed.material_io_ai5_ma - 4) / 16 * 400 + 2000;
% Mixer timing
[times, intervalTimes, runTimes] = lib.mixerTimes(nodeRed.desktop_time, nodeRed.mai_mixer_run_bool);
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
plot(nodeRed.desktop_time, nodeRed.printhead_pressure_bar, '.r')
% Limits
ylim([0 25])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Pressure printhead', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
lib.saveFigure(fig, 'pressure')

%% Plot pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.desktop_time, nodeRed.pressure_gradient1_bar_m, '.k')
plot(nodeRed.desktop_time, nodeRed.pressure_gradient2_bar_m, '.b')
plot(nodeRed.desktop_time, nodeRed.pressure_gradient3_bar_m, '.r')
% Limits
ylim([0 1.4])
xlim(xLimits)
% Labels
xlabel('Time')
yyaxis left
ylabel('Pressure gradient [bar/m]')
% Legend
legend('Coriolis', 'Hose', 'Printhead', 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
lib.saveFigure(fig, 'pressure_gradient')

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
ylim([0 8000])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Apparent dynamic viscocity [cP]')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
lib.saveFigure(fig, 'viscocity')

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
lib.saveFigure(fig, 'exciter_current_1')

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
lib.saveFigure(fig, 'mass_flow')

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
plot(nodeRed.desktop_time, nodeRed.printhead_mortar_temperature_c, '.r')
% Limits
ylim([26 36])
xlim(xLimits)
% Labels
xlabel('Time')
ylabel('Mortar temperature [C]')
% Legend
text1 = "Coriolis sensor: " + round(meanValues.material_coriolis_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.material_coriolis_temperature_c*100)/100;
text2 = "Pumping chamber: " + round(meanValues.mai_temperature_pumping_chamber_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.mai_temperature_pumping_chamber_c*100)/100;
text3 = "Printhead: " + round(meanValues.printhead_mortar_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(stdValues.printhead_mortar_temperature_c*100)/100;
legend(text1, text2, text3, 'Location', 'NorthEast')
% Layout
ax1 = gca;
set(ax1, 'XTick', xticks, 'XTickLabel', datestr(xticks, 'HH:MM'))
% Write figure
lib.saveFigure(fig, 'mortar_temperature')

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
lib.saveFigure(fig, 'density')

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
lib.saveFigure(fig, 'mortar_pump_frequency')

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
lib.saveFigure(fig, 'mortar_pump_output_power')

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
lib.saveFigure(fig, 'water_temperature')

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
lib.saveFigure(fig, 'water_flow')

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
lib.saveFigure(fig, 'water_pump_frequency')

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
lib.saveFigure(fig, 'ambient_temperature')

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
lib.saveFigure(fig, 'mixer_times_ratio')

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
lib.saveFigure(fig, 'mixer_times')

%% Correlation between temperature and pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.material_coriolis_temperature_c(index1:index2), nodeRed.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([floor(min(nodeRed.pressure_gradient1_bar_m(index1:index2))*10-1)/10, ceil(max(nodeRed.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(nodeRed.material_coriolis_temperature_c(index1:index2))-1), ceil(max(nodeRed.material_coriolis_temperature_c(index1:index2))+1)])
% Labels
xlabel('Mortar temperature [C]')
ylabel('Pressure gradient [bar/m]')
% Write figure
lib.saveFigure(fig, 'correlation_temp_pressure_gradient')

%% Correlation between viscocity and pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2), nodeRed.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([floor(min(nodeRed.pressure_gradient1_bar_m(index1:index2))*10-1)/10, ceil(max(nodeRed.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500, ceil(max(nodeRed.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500])
% Labels
xlabel('Apparent dynamic viscocity [cP]')
ylabel('Pressure gradient [bar/m]')
% Write figure
lib.saveFigure(fig, 'correlation_viscocity_pressure_gradient')

%% Report generator
% Create empty table
columnNames = {'Variable', 'Mean', 'Std', 'Min', 'Max'};
varTypes = {'string', 'string', 'string', 'string', 'string'};
T = table('Size', [0, 5], 'VariableTypes', varTypes, 'VariableNames', columnNames);
% Add data: {name, decimal precision}
columns = {
    {'mai_pump_speed_chz', 0},...
    {'mai_pump_output_power_w', 0},...
    {'mai_water_temp_c', 2},...
    {'mai_water_temp_mixer_inlet_c', 2},...
    {'mai_water_flow_set_lh', 0},...
    {'material_io_ai0_pressure_bar', 2},...
    {'material_io_ai1_pressure_bar', 2},...
    {'material_coriolis_dynamic_viscocity_cp', 0},...
    {'material_coriolis_temperature_c', 2},...
    {'material_coriolis_density_kg_m3', 0},...
    {'material_io_ai7_ambient_temperature_c', 2},...
    {'material_io_ai6_relative_humidity_perc', 2},...
    {'printhead_pressure_bar', 3},...
    {'printhead_mortar_temperature_c', 2},...
    {'differential_pressure1_bar', 3},...
    {'differential_pressure2_bar', 3},...
    {'differential_pressure3_bar', 3},...
    {'pressure_gradient1_bar_m', 3},...
    {'pressure_gradient2_bar_m', 3},...
    {'pressure_gradient3_bar_m', 3},...
    {'mixer_interval_time', 1},...
    {'mixer_run_time', 1},...
    {'mixer_ratio', 3}...
};
for i = 1:length(columns)
   % Define the new row data
    newRow = {columns{i}{1},...
        round(meanValues.(columns{i}{1}), columns{i}{2}),... 
        round(stdValues.(columns{i}{1}), columns{i}{2}),... 
        round(minValues.(columns{i}{1}), columns{i}{2}),... 
        round(maxValues.(columns{i}{1}), columns{i}{2})};
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
% Create an unordered list for the summary time window
timeList = UnorderedList();
timeItem1 = ListItem(Paragraph(['Start Time: ', char(windowStart)]));
timeItem2 = ListItem(Paragraph(['End Time: ', char(windowEnd)]));
append(timeList, timeItem1);
append(timeList, timeItem2);
% Create an unordered list for the system lengths
lengthList = UnorderedList();
lengthItem1 = ListItem(Paragraph(['System length 1: ', num2str(length1)]));
lengthItem2 = ListItem(Paragraph(['System length 2: ', num2str(length2)]));
lengthItem3 = ListItem(Paragraph(['System length 3: ', num2str(length3)]));
append(lengthList, lengthItem1);
append(lengthList, lengthItem2);
append(lengthList, lengthItem3);
% Add the data to the report
add(report, " ")
add(report, "Time window used for summary report:")
add(report, timeList);
add(report, "System length used to calculate pressure gradient:")
add(report, lengthList);
add(report, domTable);
% Close the report to generate the PDF
close(report);
% View the report
rptview(report);

%% End
disp('End of script')
