%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
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
cd('logs\20240507_Arjen\')
directory = pwd;
node_red = lib.read_data(directory);

%% Settings for layout
% X-axis
xtick = 30; % Interval of ticks on x-axis in minutes
xlimits = [lib.floor_to_nearest(node_red.desktop_time(1), xtick) 
    lib.ceil_to_nearest(node_red.desktop_time(end), xtick)];
xticks = xlimits(1):minutes(xtick):xlimits(2);
% Set default marker size and line width
set(0, 'DefaultLineMarkerSize', 2);
set(0, 'DefaultLineLineWidth', 1.5);

%% Settings for analysis
% Window for correlations, mean, std, etc. 
window_start = duration(9, 0, 0); 
window_end = duration(17, 0, 0);

%% Add columns missing in older versions of the data logger
node_red = lib.add_missing_columns(node_red);

%% Corrections: bug fix incorrect conversion analog inputs v0.4.0
apply_correction = false;
if (apply_correction == true)
    node_red = lib.correction_analog_inputs(node_red);
end

%% Calculations: Convert sensor data
% Differential pressure
k = 60; % ~3 seconds, 10 samples per second
filtered1 = movmean(node_red.material_io_ai0_pressure_bar, k, 'omitnan');
filtered2 = movmean(node_red.material_io_ai1_pressure_bar, k, 'omitnan');
filtered3 = movmean(node_red.printhead_pressure_bar, k, 'omitnan');
node_red.differential_pressure1_bar = filtered1 - filtered2;
node_red.differential_pressure2_bar = filtered2 - filtered3;
node_red.differential_pressure3_bar = filtered3;
% Pressure gradient
length1 = (150 + 144 + 820 + 184 + 113) / 1000;     %Coriolis
length2 = (150 + 13605 + 199 + 114) / 1000;         %Hose
%length3 = (150 + 1013 + 95.5) / 1000;               %Printhead without temp
length3 = (150 + 1013 + 49.5 + 95.5) / 1000;        %Printhead with temp
%length3 = (150 + 1013 + 51 + 83 + 1099) / 1000;     %Printhead with 1 meter hose (id)
node_red.pressure_gradient1_bar_m = node_red.differential_pressure1_bar / length1;
node_red.pressure_gradient2_bar_m = node_red.differential_pressure2_bar / length2;
node_red.pressure_gradient3_bar_m = node_red.differential_pressure3_bar / length3;
% Filtered values from coriolis io (if connected)
%node_red.material_coriolis_mass_flow_filtered_90s_kg_min = (node_red.material_io_ai4_ma - 4) / 16 * 16;
%node_red.material_coriolis_density_filtered_90s_kg_m3 = (node_red.material_io_ai5_ma - 4) / 16 * 400 + 2000;
node_red.material_coriolis_mass_flow_filtered_90s_kg_min = (node_red.material_io_ai4_ma - 4) / 16 * 32;
node_red.material_coriolis_density_filtered_90s_kg_m3 = (node_red.material_io_ai5_ma - 4) / 16 * 3200;
% Mixer timing
[times, interval_times, runtimes] = lib.mixer_times(node_red.desktop_time, node_red.mai_mixer_run_bool);

%% Get time in minutes and seconds
node_red.seconds = seconds(node_red.desktop_time) - seconds(node_red.desktop_time(1));
node_red.minutes = minutes(node_red.desktop_time) - minutes(node_red.desktop_time(1));

%% Calculate properties
% Index of window
[~, index1] = min(abs(node_red.desktop_time - window_start));
[~, index2] = min(abs(node_red.desktop_time - window_end));
% Calculate mean, std, min and max
mean_values = varfun(@(x) mean(x, 'omitnan'), node_red(index1:index2, :));
std_values = varfun(@(x) std(x, 'omitnan'), node_red(index1:index2, :));
min_values = varfun(@(x) min(x, [], 'omitnan'), node_red(index1:index2, :));
max_values = varfun(@(x) max(x, [], 'omitnan'), node_red(index1:index2, :));
% Remove '_Fun' from column names
mean_values.Properties.VariableNames = strrep(min_values.Properties.VariableNames, 'Fun_', '');
std_values.Properties.VariableNames = strrep(max_values.Properties.VariableNames, 'Fun_', '');
min_values.Properties.VariableNames = strrep(min_values.Properties.VariableNames, 'Fun_', '');
max_values.Properties.VariableNames = strrep(max_values.Properties.VariableNames, 'Fun_', '');

%% Mixer time properties
% Calculate indices
[~, index3] = min(abs(times - window_start));
[~, index4] = min(abs(times - window_end));
% Extract data within the window
runtimesWindow = runtimes(index3:index4);
interval_times_window = interval_times(index3:index4);
% Calculate mean, std, min, max for mixer_run_time
mean_values.mixer_run_time = mean(runtimesWindow);
std_values.mixer_run_time = std(runtimesWindow);
min_values.mixer_run_time = min(runtimesWindow);
max_values.mixer_run_time = max(runtimesWindow);
% Calculate mean, std, min, max for mixer_interval_time
mean_values.mixer_interval_time = mean(interval_times_window);
std_values.mixer_interval_time = std(interval_times_window);
min_values.mixer_interval_time = min(interval_times_window);
max_values.mixer_interval_time = max(interval_times_window);
% Calculate mean, std, min, max for mixer_ratio
ratioValues = runtimesWindow ./ interval_times_window;
ratioValues = ratioValues(isfinite(ratioValues));
mean_values.mixer_ratio = mean(ratioValues);
std_values.mixer_ratio = std(ratioValues);
min_values.mixer_ratio = min(ratioValues);
max_values.mixer_ratio = max(ratioValues);

%% Plot pressure
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_io_ai0_pressure_bar, '.k')
plot(node_red.desktop_time, node_red.material_io_ai1_pressure_bar, '.b')
plot(node_red.desktop_time, node_red.printhead_pressure_bar, '.r')
% Limits
ylim([0 25])
% Labels
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Pressure printhead', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'pressure')

%% Plot pressure gradient
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.pressure_gradient1_bar_m, '.k')
plot(node_red.desktop_time, node_red.pressure_gradient2_bar_m, '.b')
plot(node_red.desktop_time, node_red.pressure_gradient3_bar_m, '.r')
% Limits
ylim([0 2.0])
% Labels
ylabel('Pressure gradient [bar/m]')
% Legend
legend('Coriolis', 'Hose', 'Printhead', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'pressure_gradient')

%% Plot viscocity
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_dynamic_viscocity_cp, '.k')
% Limits
ylim([0 8000])
% Labels
ylabel('Apparent dynamic viscocity [cP]')
% Write figure
lib.save_figure(fig, 'viscocity')

%% Plot exciter current
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_exciter_current_1_ma, '.k')
% Limits
ylim([0 10])
% Labels
ylabel('Exciter current 1 [mA]')
% Write figure
lib.save_figure(fig, 'exciter_current_1')

%% Plot mass flow rate
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_mass_flow_kg_min, '.k')
plot(node_red.desktop_time, node_red.material_coriolis_mass_flow_filtered_90s_kg_min, '.b')
% Limits
ylim([0 12])
% Labels
ylabel('Mass flow rate [kg/min]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'mass_flow')

%% Plot temperature
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_temperature_c, '.k')
plot(node_red.desktop_time, node_red.mai_pumping_chamber_mortar_temperature_c, '.b')
plot(node_red.desktop_time, node_red.printhead_mortar_temperature_c, '.r')
% Limits
ylim([26 36])
% Labels
ylabel('Mortar temperature [C]')
% Legend
text1 = "Coriolis sensor: " + round(mean_values.material_coriolis_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(std_values.material_coriolis_temperature_c*100)/100;
text2 = "Pumping chamber: " + round(mean_values.mai_pumping_chamber_mortar_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(std_values.mai_pumping_chamber_mortar_temperature_c*100)/100;
text3 = "Printhead: " + round(mean_values.printhead_mortar_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(std_values.printhead_mortar_temperature_c*100)/100;
legend(text1, text2, text3, 'Location', 'SouthEast')
% Write figure
lib.save_figure(fig, 'mortar_temperature')

%% Plot temperature
%{
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_pumping_chamber_mortar_temperature_c, '.b')
plot(node_red.desktop_time, node_red.material_coriolis_temperature_c, '.k')
plot(node_red.desktop_time, node_red.printhead_mortar_temperature_c, '.r')
% Plot mixer run
x = node_red.desktop_time;
y = node_red.mai_mixer_run_bool * 40;
area(x, y, 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
% Limits
ylim([28 32])
% Labels
ylabel('Mortar temperature [C]')
% Legend
text1 = "Pumping chamber";
text2 = "Coriolis sensor";
text3 = "Printhead";
text4 = "Mixer run";
legend(text1, text2, text3, text4, 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'mortar_temperature')
%}

%% Plot density
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_density_kg_m3, '.k')
plot(node_red.desktop_time, node_red.material_coriolis_density_filtered_90s_kg_m3, '.b')
% Limits
ylim([2320 2400])
% Labels
ylabel('Density [kg/m^{3}]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'density')

%% Plot pump frequency
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_pump_speed_chz, '.k')
% Limits
ylim([0 5000])
% Labels
ylabel('Pump frequency [cHz]')
% Write figure
lib.save_figure(fig, 'mortar_pump_frequency')

%% Plot pump output power
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_pump_output_power_w, '.k')
% Limits
ylim([0 800])
% Labels
ylabel('Pump output power [W]')
% Write figure
lib.save_figure(fig, 'mortar_pump_output_power')

%% Plot water temperature
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_water_temp_c, '.k')
plot(node_red.desktop_time, node_red.mai_water_temp_mixer_inlet_c, '.b')
% Limits
ylim([floor(min(node_red.mai_water_temp_c)-1), ceil(max(node_red.mai_water_temp_c)+1)])
% Labels
ylabel('Water temperature [C]')
% Legend
legend('Sensor 1: Original', 'Sensor 2: Mixer inlet', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'water_temperature')

%% Plot water flow
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_water_flow_actual_lh, '.k')
plot(node_red.desktop_time, node_red.mai_water_flow_set_lh, '.b')
% Limits
ylim([0 400])
% Labels
ylabel('Water flow [L/h]')
% Legend
legend('Actual', 'Setpoint', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'water_flow')

%% Plot water pump frequency
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mai_waterpump_output_freq_chz./100, '.k')
plot(node_red.desktop_time, node_red.mai_waterpump_ref_freq_chz./100, '.b')
% Limits
ylim([0 30])
% Labels
ylabel('Water pump freq. [Hz]')
% Legend
legend('Actual', 'Reference', 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'water_pump_frequency')

%% Ambient temperature and relative humidity
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_io_ai7_ambient_temperature_c, '.k')
yyaxis right
plot(node_red.desktop_time, node_red.material_io_ai6_relative_humidity_perc, '.b')
% Limits
yyaxis left
ylim([floor(min(node_red.material_io_ai7_ambient_temperature_c)-2), ceil(max(node_red.material_io_ai7_ambient_temperature_c)+2)])
yyaxis right
ylim([floor(min(node_red.material_io_ai6_relative_humidity_perc)-2), ceil(max(node_red.material_io_ai6_relative_humidity_perc)+2)])
% Labels
yyaxis left
ylabel('Ambient temperature [C]')
yyaxis right
ylabel('Relative humidity [%]')
% Legend
text1 = "Ambient temperature: " + round(mean_values.material_io_ai7_ambient_temperature_c*100)/100 + sprintf(' %s ', char(177)) + round(std_values.material_io_ai7_ambient_temperature_c*100)/100 + " C";
text2 = "Relative humidity: " + round(mean_values.material_io_ai6_relative_humidity_perc*100)/100 + sprintf(' %s ', char(177)) + round(std_values.material_io_ai6_relative_humidity_perc*100)/100 + " %";
legend(text1, text2, 'Location', 'NorthEast')
% Layout)
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
lib.save_figure(fig, 'ambient_temperature')

%% Mixer times ratio (flow prediction)
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
k = 8;
plot(times, runtimes./interval_times, '.k')
plot(times, movmean(runtimes./interval_times, [k 0]), '-k')
% Limits
ylim([0 0.4])
% Labels
ylabel('Run time / interval time')
% Legend
legend('Single run', sprintf('Moving mean k=%d', k), 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'mixer_times_ratio')

%% Mixer times (flow prediction)
fig = lib.figure_time_series(xticks, xlimits);
% Plot data
k = 8;
plot(times, interval_times, '.k')
plot(times, movmean(interval_times, [k 0]), '-k')
plot(times, runtimes, '.b')
plot(times, movmean(runtimes, [k 0]), '-b')
% Limits
ylim([0 120])
% Labels
ylabel('Mixer times [Seconds]')
% Legend
legend('Interval time', sprintf('Interval time mov. mean k=%d', k), 'Run time', sprintf('Run time mov. mean k=%d', k), 'Location', 'NorthEast')
% Write figure
lib.save_figure(fig, 'mixer_times')

%% Correlation between temperature and pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(node_red.material_coriolis_temperature_c(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([floor(min(node_red.pressure_gradient1_bar_m(index1:index2))*10-1)/10, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(node_red.material_coriolis_temperature_c(index1:index2))-1), ceil(max(node_red.material_coriolis_temperature_c(index1:index2))+1)])
% Labels
xlabel('Mortar temperature [C]')
ylabel('Pressure gradient [bar/m]')
% Write figure
lib.save_figure(fig, 'correlation_temp_pressure_gradient')

%% Correlation between viscocity and pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(node_red.material_coriolis_dynamic_viscocity_cp(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([floor(min(node_red.pressure_gradient1_bar_m(index1:index2))*10-1)/10, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(node_red.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500, ceil(max(node_red.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500])
% Labels
xlabel('Apparent dynamic viscocity [cP]')
ylabel('Pressure gradient [bar/m]')
% Write figure
lib.save_figure(fig, 'correlation_viscocity_pressure_gradient')

%% Correlation between density and pressure gradient
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Plot data
plot(node_red.material_coriolis_density_kg_m3(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
plot(node_red.material_coriolis_density_filtered_90s_kg_m3(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.b')
% Limits
ylim([floor(min(node_red.pressure_gradient1_bar_m(index1:index2))*10-1)/10, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(node_red.material_coriolis_density_kg_m3(index1:index2))/10)*10, ceil(max(node_red.material_coriolis_density_kg_m3(index1:index2))/10)*10])
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'SouthEast')
% Labels
xlabel('Density [kg/m^{3}]')
ylabel('Pressure gradient [bar/m]')
% Write figure
lib.save_figure(fig, 'correlation_density_pressure_gradient')

%% Run time
% Run time
time = hours(node_red.desktop_time);
dt = diff(time);
mixer_runtime = sum(dt.*node_red.mai_mixer_run_bool(2:end), 'omitnan');
pump_runtime = sum(dt.*node_red.mai_pump_run_bool(2:end), 'omitnan');
% Equivalent runtime: time * frequency / reference frequency
ref_frequency = 50; % Hz! 
equivalent_pump_runtime = sum((dt.*node_red.mai_pump_run_bool(2:end)) .* (node_red.mai_pump_speed_chz(2:end) ./ 100 / ref_frequency), 'omitnan');

%% Report generator
% Create empty table
column_names = {'Variable', 'Mean', 'Std', 'Min', 'Max'};
var_types = {'string', 'string', 'string', 'string', 'string'};
T = table('Size', [0, 5], 'VariableTypes', var_types, 'VariableNames', column_names);
% Add data: {name, decimal precision}
columns = {
    {'mai_pump_speed_chz', 0},...
    {'mai_pump_output_power_w', 0},...
    {'mai_water_temp_c', 2},...
    {'mai_water_temp_mixer_inlet_c', 2},...
    {'mai_pumping_chamber_mortar_temperature_c', 2},...
    {'mai_silo_dry_mortar_temperature_c', 2},...
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
        round(mean_values.(columns{i}{1}), columns{i}{2}),... 
        round(std_values.(columns{i}{1}), columns{i}{2}),... 
        round(min_values.(columns{i}{1}), columns{i}{2}),... 
        round(max_values.(columns{i}{1}), columns{i}{2})};
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
dom_table = BaseTable(T);
% Run time
runtime_list = UnorderedList();
time_item1 = ListItem(Paragraph(['Mixer runtime [h]: ', num2str(mixer_runtime)]));
time_item2 = ListItem(Paragraph(['Pump runtime [h]: ', num2str(pump_runtime)]));
time_item3 = ListItem(Paragraph(['Equivalent pump runtime [h x Hz]: ', num2str(equivalent_pump_runtime)]));
append(runtime_list, time_item1);
append(runtime_list, time_item2);
append(runtime_list, time_item3);
% Create an unordered list for the summary time window
time_list = UnorderedList();
time_item1 = ListItem(Paragraph(['Start time: ', char(window_start)]));
time_item2 = ListItem(Paragraph(['End time: ', char(window_end)]));
append(time_list, time_item1);
append(time_list, time_item2);
% Create an unordered list for the system lengths
length_list = UnorderedList();
length_item1 = ListItem(Paragraph(['System length 1 [m]: ', num2str(length1)]));
length_item2 = ListItem(Paragraph(['System length 2 [m]: ', num2str(length2)]));
length_item3 = ListItem(Paragraph(['System length 3 [m]: ', num2str(length3)]));
append(length_list, length_item1);
append(length_list, length_item2);
append(length_list, length_item3);
% Add the data to the report
add(report, " ")
add(report, "Runtimes:")
add(report, runtime_list);
add(report, "Time window used for table values:")
add(report, time_list);
add(report, "System length used to calculate pressure gradient:")
add(report, length_list);
add(report, PageBreak)
add(report, dom_table);
% Close the report to generate the PDF
close(report);
% View the report
rptview(report);

%% End
disp('End of script')
