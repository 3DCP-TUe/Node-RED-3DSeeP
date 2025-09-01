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

%% Clear and close

close all; 
clear; 
clc;

%% Get file path

path = mfilename('fullpath');
[filepath, name, ext] = fileparts(path);
cd(filepath);

%% Add lib

addpath('lib/');

%% Read file and set directory

% Read multiple files from custom directory
cd('D:\OneDrive - TU Eindhoven\_logs')
cd('20250213_Frankenstein')
directory = pwd;
node_red = nr3dseep.read_data(directory);

%% Folder to store figures and report

folder_name = fullfile(directory, "Results");
if ~exist(folder_name, 'dir' ), mkdir(folder_name), end
cd(folder_name)

%% Add and remove columns (clean-up)

% Add (missing from old version of the data logger)
node_red = nr3dseep.add_missing_columns(node_red);

% Remove unused
remove = startsWith(node_red.Properties.VariableNames, 'printhead_motor') | ...
         startsWith(node_red.Properties.VariableNames, 'material_bronkhorst') | ...
         startsWith(node_red.Properties.VariableNames, 'material_peristaltic') | ...
         startsWith(node_red.Properties.VariableNames, 'vertico') | ...
         startsWith(node_red.Properties.VariableNames, 'mai');
node_red(:, remove) = [];

%% Settings for layout

% X-axis
xtick = 60; % Interval of ticks on x-axis in minutes
xlimits = [nr3dseep.floor_to_nearest(node_red.desktop_time(1), xtick) ...
    nr3dseep.ceil_to_nearest(node_red.desktop_time(end), xtick)];
xticks = xlimits(1):minutes(xtick):xlimits(2);

% Set default marker size and line width
set(0, 'DefaultLineMarkerSize', 2);
set(0, 'DefaultLineLineWidth', 1.5);

%% Settings for analysis

% Window for correlations, mean, std, etc. 
window_start = duration(15, 30, 0); 
window_end = duration(18, 30, 0);

% Indices
[~, index1] = min(abs(node_red.desktop_time - window_start));
[~, index2] = min(abs(node_red.desktop_time - window_end));

%% Corrections: bug fix incorrect conversion analog inputs v0.4.0

applyCorrection = false;

if (applyCorrection == true)
    node_red = nr3dseep.correction_analog_inputs(node_red);
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
%length3 = (150 + 1013 + 95.5) / 1000;              %Printhead without temp
length3 = (150 + 1013 + 49.5 + 95.5) / 1000;        %Printhead with temp
%length3 = (150 + 1013 + 51 + 83 + 1099) / 1000;    %Printhead with 1 meter hose (id)
node_red.pressure_gradient1_bar_m = node_red.differential_pressure1_bar / length1;
node_red.pressure_gradient2_bar_m = node_red.differential_pressure2_bar / length2;
node_red.pressure_gradient3_bar_m = node_red.differential_pressure3_bar / length3;

% Filtered values from coriolis io (if connected)
%node_red.material_coriolis_mass_flow_filtered_90s_kg_min = (node_red.material_io_ai4_ma - 4) / 16 * 16;            % old conversion (till january 2025)
%node_red.material_coriolis_density_filtered_90s_kg_m3 = (node_red.material_io_ai5_ma - 4) / 16 * 400 + 2000;       % old conversion (till january 2025)
node_red.material_coriolis_mass_flow_filtered_90s_kg_min = (node_red.material_io_ai4_ma - 4) / 16 * 32;
node_red.material_coriolis_density_filtered_90s_kg_m3 = (node_red.material_io_ai5_ma - 4) / 16 * 3200;

% Mixer timing
mixer_data = nr3dseep.mixer_times(node_red.desktop_time, node_red.mtec_mixer_run_bool);

%% Get time in minutes and seconds

node_red.seconds = seconds(node_red.desktop_time) - seconds(node_red.desktop_time(1));
node_red.minutes = minutes(node_red.desktop_time) - minutes(node_red.desktop_time(1));

%% Calculate properties

properties_system = nr3dseep.calculate_timetable_properties(node_red, node_red.desktop_time, window_start, window_end);
properties_mixer = nr3dseep.calculate_timetable_properties(mixer_data, mixer_data.times, window_start, window_end);
properties = [properties_system; properties_mixer];

%% Plot pressure

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_io_ai0_pressure_bar, '.k')
plot(node_red.desktop_time, node_red.material_io_ai1_pressure_bar, '.b')
plot(node_red.desktop_time, node_red.printhead_pressure_bar, '.r')
% Limits
ylim([0 25])
% Labels
ylabel('Pressure [bar]', 'interpreter', 'latex')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Pressure printhead', 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'pressure')

%% Plot pressure gradient

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.pressure_gradient1_bar_m, '.k')
plot(node_red.desktop_time, node_red.pressure_gradient2_bar_m, '.b')
plot(node_red.desktop_time, node_red.pressure_gradient3_bar_m, '.r')
% Limits
ylim([0 2.0])
% Labels
ylabel('Pressure gradient [bar/m]', 'interpreter', 'latex')
% Legend
legend('Coriolis', 'Hose', 'Printhead', 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'pressure_gradient')

%% Plot viscocity

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_dynamic_viscocity_cp, '.k')
% Limits
ylim([0 8000])
% Labels
ylabel('Apparent viscocity [cP]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'viscocity')

%% Plot exciter current

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_exciter_current_1_ma, '.k')
% Limits
ylim([0 10])
set(gca, 'YTick', 0:2:10)
% Labels
ylabel('Exciter current 1 [mA]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'exciter_current_1')

%% Plot mass flow rate

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_mass_flow_kg_min, '.k')
plot(node_red.desktop_time, node_red.material_coriolis_mass_flow_filtered_90s_kg_min, '.b')
% Limits
ylim([0 12])
set(gca, "YTick", 0:2:12)
% Labels
ylabel('Mass flow rate [kg/min]', 'interpreter', 'latex')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'mass_flow')

%% Plot temperature

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_temperature_c, '.k')
%plot(node_red.desktop_time, node_red.mtec_pumping_chamber_mortar_temperature_c, '.b')
plot(node_red.desktop_time, node_red.printhead_mortar_temperature_c, '.r')
% Limits
ylim([26 36])
% Labels
ylabel('Mortar temperature [$^\circ$C]', 'interpreter', 'latex')
% Legend
temp_coriolis = properties(strcmp(properties.variable, 'material_coriolis_temperature_c'), :);
%temp_pump = properties(strcmp(properties.variable, 'mtec_pumping_chamber_mortar_temperature_c'), :);
temp_head = properties(strcmp(properties.variable, 'printhead_mortar_temperature_c'), :);
text1 = "Coriolis sensor: " + round(temp_coriolis.mean*100)/100 + " $\pm$ "+ round(temp_coriolis.std*100)/100;
%text2 = "Pumping chamber: " + round(temp_pump.mean*100)/100 + " $\pm$ "+ round(temp_pump.std*100)/100;
text3 = "Printhead: " + round(temp_head.mean*100)/100 + " $\pm$ "+ round(temp_head.std*100)/100;
legend(text1, text3, 'Location', 'SouthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'mortar_temperature')

%% Plot density

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.material_coriolis_density_kg_m3, '.k')
plot(node_red.desktop_time, node_red.material_coriolis_density_filtered_90s_kg_m3, '.b')
% Limits
ylim([1800 2400])
% Labels
ylabel('Density [kg/m\textsuperscript{3}]', 'interpreter', 'latex')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'density')

%% Plot pump speed

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mtec_pump_speed_actual_rpm, '.k')
plot(node_red.desktop_time, node_red.mtec_pump_speed_set_rpm, '-r')
% Limits
ylim([0 200])
% Labels
ylabel('Pump speed [RPM]', 'interpreter', 'latex')
% Legend
legend('Actual', 'Setpoint (remote control)', 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'mortar_pump_speed')

%% Plot water temperature

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mtec_water_temp_c, '.k')
% Limits
ylim([floor(min(node_red.mtec_water_temp_c)-1), ceil(max(node_red.mtec_water_temp_c)+1)])
% Labels
ylabel('Water temperature [$^\circ$C]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'water_temperature')

%% Plot water flow

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
plot(node_red.desktop_time, node_red.mtec_water_water_valve_actual_perc, '.k')
yyaxis right
plot(node_red.desktop_time, node_red.mtec_water_flow_actual_l_h, '.b')
% Limits
yyaxis left
ylim([0 50])
set(gca, "Ytick", 0:10:500)
yyaxis right
ylim([0 500])
set(gca, "Ytick", 0:100:1000)
% Labels
yyaxis left
ylabel('Valve position [\%]', 'interpreter', 'latex')
yyaxis right
ylabel('Water flow [L/h]', 'interpreter', 'latex')
% Legend
legend('Valve position', 'Water flow', 'Location', 'NorthEast', 'interpreter', 'latex')
% Layout
set(gca,'YColor',[0,0,0])
% Write figure
nr3dseep.save_figure(fig, 'water_flow')

%% Ambient temperature and relative humidity

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
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
ylabel('Ambient temperature [$^\circ$C]', 'interpreter', 'latex')
yyaxis right
ylabel('Relative humidity [\%]', 'interpreter', 'latex')
% Legend
ambient = properties(strcmp(properties.variable, 'material_io_ai7_ambient_temperature_c'), :);
rh = properties(strcmp(properties.variable, 'material_io_ai6_relative_humidity_perc'), :);
text1 = "Ambient temperature: " + round(ambient.mean*100)/100 + " $\pm$ "+ round(ambient.std*100)/100 + " $^\circ$C";
text2 = "Relative humidity: " + round(rh.mean*100)/100 + " $\pm$ "+ round(ambient.std*100)/100 + " \%";
legend(text1, text2, 'Location', 'NorthEast', 'interpreter', 'latex')
% Layout)
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
nr3dseep.save_figure(fig, 'ambient_temperature')

%% Mixer times ratio (flow prediction)

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
k = 8;
plot(mixer_data.times, mixer_data.ratio, '.k')
plot(mixer_data.times, movmean(mixer_data.ratio, [k 0]), '-k')
% Limits
ylim([0 0.4])
% Labels
ylabel('Runtime / interval time', 'interpreter', 'latex')
% Legend
legend('Single run', sprintf('Moving mean k=%d', k), 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'mixer_times_ratio')

%% Mixer times (flow prediction)

% Initialize figure
fig = nr3dseep.figure_time_series(xticks, xlimits);
% Plot data
k = 8;
plot(mixer_data.times, mixer_data.interval_times, '.k')
plot(mixer_data.times, movmean(mixer_data.interval_times, [k 0]), '-k')
plot(mixer_data.times, mixer_data.runtimes, '.b')
plot(mixer_data.times, movmean(mixer_data.runtimes, [k 0]), '-b')
% Limits
ylim([0 120])
set(gca, "YTick", 0:20:120)
% Labels
ylabel('Mixer times [seconds]', 'interpreter', 'latex')
% Legend
legend('Interval time', sprintf('Interval time mov. mean k=%d', k), 'Runtime', sprintf('Runtime mov. mean k=%d', k), 'Location', 'NorthEast', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'mixer_times')

%% Correlation between temperature and pressure gradient

% Initialize figure
fig = nr3dseep.figure_box();
% Plot data
plot(node_red.material_coriolis_temperature_c(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([0, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(node_red.material_coriolis_temperature_c(index1:index2))-1), ceil(max(node_red.material_coriolis_temperature_c(index1:index2))+1)])
% Labels
xlabel('Mortar temperature [$^\circ$C]', 'interpreter', 'latex')
ylabel('Pressure gradient [bar/m]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'correlation_temp_pressure_gradient')

%% Correlation between viscocity and pressure gradient

% Initialize figure
fig = nr3dseep.figure_box();
% Plot data
plot(node_red.material_coriolis_dynamic_viscocity_cp(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
% Limits
ylim([0, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([0, ceil(max(node_red.material_coriolis_dynamic_viscocity_cp(index1:index2))/500)*500])
% Labels
xlabel('Apparent dynamic viscocity [cP]', 'interpreter', 'latex')
ylabel('Pressure gradient [bar/m]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'correlation_viscocity_pressure_gradient')

%% Correlation between density and pressure gradient

% Initialize figure
fig = nr3dseep.figure_box();
% Plot data
plot(node_red.material_coriolis_density_kg_m3(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.k')
plot(node_red.material_coriolis_density_filtered_90s_kg_m3(index1:index2), node_red.pressure_gradient1_bar_m(index1:index2), '.b')
% Limits
ylim([0, ceil(max(node_red.pressure_gradient1_bar_m(index1:index2))*10+1)/10])
xlim([floor(min(node_red.material_coriolis_density_kg_m3(index1:index2))/10)*10, ceil(max(node_red.material_coriolis_density_kg_m3(index1:index2))/10)*10])
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'SouthEast', 'interpreter', 'latex')
% Labels
xlabel('Density [kg/m\textsuperscript{3}]', 'interpreter', 'latex')
ylabel('Pressure gradient [bar/m]', 'interpreter', 'latex')
% Write figure
nr3dseep.save_figure(fig, 'correlation_density_pressure_gradient')

%% Runtime

% Runtime
time = hours(node_red.desktop_time);
dt = diff(time);
mixer_runtime = sum(dt.*node_red.mtec_mixer_run_bool(2:end), 'omitnan');
pump_runtime = sum(dt.*(node_red.mtec_pump_speed_actual_rpm(2:end)>10), 'omitnan');

% Equivalent runtime: time * frequency / reference frequency
ref_frequency = 100; % RPM!
equivalent_pump_runtime = sum((dt.*(node_red.mtec_pump_speed_actual_rpm(2:end)>10)) .* (node_red.mtec_pump_speed_actual_rpm(2:end) / ref_frequency), 'omitnan');

%% Report generator

% Create empty table
column_names = {'variable', 'mean', 'median', 'std', 'min', 'max'};
var_types = {'string', 'string', 'string', 'string', 'string', 'string'};
T = table('Size', [0, 6], 'VariableTypes', var_types, 'VariableNames', column_names);

% Add data: {name, decimal precision}
columns = {
    {'mtec_pump_speed_actual_rpm', 0},...
    {'mtec_water_temp_c', 2},...
    {'mtec_water_water_valve_actual_perc', 0},...
    {'mtec_water_flow_actual_l_h', 0},...
    {'material_io_ai0_pressure_bar', 2},...
    {'material_io_ai1_pressure_bar', 2},...
    {'material_coriolis_dynamic_viscocity_cp', 0},...
    {'material_coriolis_exciter_current_1_ma', 3},...
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
    {'interval_times', 1},...
    {'runtimes', 1},...
    {'ratio', 3}...
};

for i = 1:length(columns)
    % Extract column name and precision from columns list
    variable = columns{i}{1};
    precision = columns{i}{2};
    % Check if the column exists in the timetable
    if ismember(variable, properties.variable)
        row = properties(strcmp(properties.variable, variable), :);
        row.mean = round(row.mean, precision);
        row.median = round(row.median, precision);
        row.std = round(row.std, precision);
        row.min = round(row.min, precision);
        row.max = round(row.max, precision);
        T = [T; row];
    else
        warning('Column "%s" not found in timetable.', variable);
    end
end

% Import report generator
import mlreportgen.report.*
import mlreportgen.dom.*

% Create a PDF report
report = Report('report', 'pdf');
report.Layout.Landscape = true;

% Add a title to the report
title = Paragraph('Report 3DCP');
title.Style = {Bold(true), FontSize('14pt')};
add(report, title);

% Convert MATLAB table to a DOM table
dom_table = BaseTable(T);

% Runtime
runtime_list = UnorderedList();
time_item1 = ListItem(Paragraph(['Mixer runtime [h]: ', num2str(mixer_runtime)]));
time_item2 = ListItem(Paragraph(['Pump runtime [h]: ', num2str(pump_runtime)]));
time_item3 = ListItem(Paragraph(['Equivalent runtime [h x RPM]: ', num2str(equivalent_pump_runtime)]));
append(runtime_list, time_item1);
append(runtime_list, time_item2);
append(runtime_list, time_item3);

% Create an unordered list for the summary time window
timeList = UnorderedList();
time_item1 = ListItem(Paragraph(['Start time: ', char(window_start)]));
time_item2 = ListItem(Paragraph(['End time: ', char(window_end)]));
append(timeList, time_item1);
append(timeList, time_item2);

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
add(report, "Run times:")
add(report, runtime_list);
add(report, "Time window used for table values:")
add(report, timeList);
add(report, "System length used to calculate pressure gradient:")
add(report, length_list);
add(report, PageBreak)
add(report, dom_table);

% Close the report to generate the PDF
close(report);

% View the report
rptview(report);

%% Export data as CSV files

%{
% Path
cd(filepath);
cd('..\processed_data\')

% Mixer
writetable(mixer_data, 'mixer_data.csv');

% System data
writetable(node_red, 'system_data.csv');
writetable(properties, 'system_data_properties.csv');
%}

%% End
disp('End of script')
