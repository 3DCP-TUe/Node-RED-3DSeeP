%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under the terms 
of GNU General Public License as published by the Free Software Foundation. For more 
information and the LICENSE file, see <https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%% Clear and close
close all; clear; clc;

%% Settings
%Specify directory where the node-red files can be found. If left empty,
%files are searched in the folder where the Matlab script runs.
nodeRedFilePath = "D:\OneDrive - TU Eindhoven\VENI - Digital Fabrication with Concrete\04_Experiments\20240618_RILEM_DAY2\Data Node-Red";

%% Get file path
filepath=pwd;

%% Import data from node red
% All csv files in the current folder are assumed to be node-red logs. If
% multiple files are present, they are appended. If no files are present in the Matlab directory,
% the given filepath is used and all csv files are read from there. 

if nodeRedFilePath ==""
    curDirCSV=dir('*.csv');
    if isempty(curDirCSV)==1
        disp("ERROR: No .csv files found Matlab folder")
    end
else
    cd(nodeRedFilePath)
    curDirCSV=dir('*.csv');
    if isempty(curDirCSV)==1
        disp("ERROR: No .csv files found in specified folder")
    end
end

%Read files and append if multiple
nodeRed=[];
for i=1:length(curDirCSV)
    nodeRed=[nodeRed; readtable(curDirCSV(i).name)];
end

% Create and navigate to save folder
saveFolderName="Results_"+curDirCSV(1).name(1:end-3);
if ~exist(saveFolderName,'dir')
    mkdir(saveFolderName)
end
cd("Results_"+curDirCSV(1).name(end-3:end))

%% Get time in minutes and seconds
nodeRed.('seconds') = seconds(nodeRed.('desktop_time')) - seconds(nodeRed.('desktop_time')(1));
nodeRed.('minutes') = minutes(nodeRed.('desktop_time')) - minutes(nodeRed.('desktop_time')(1));

%% Calculations
% Differential pressure
k = 60; % ~6 seconds, 10 samples per second
filtered1 = movmean(nodeRed.('material_io_ai0_pressure_bar'), k, 'omitnan');
filtered2 = movmean(nodeRed.('material_io_ai1_pressure_bar'), k, 'omitnan');
nodeRed.('material_differential_pressure_bar') = filtered1 - filtered2;
% Filtered values from coriolis io
nodeRed.('material_coriolis_mass_flow_filtered_90s_kg_min') = (nodeRed.('material_io_ai4_ma') - 4) / 16 * 16;
nodeRed.('material_coriolis_density_filtered_90s_kg_m3') = (nodeRed.('material_io_ai5_ma') - 4) / 16 * 400 + 2000;
% Mixer timing
[times, intervalTimes, runTimes] = mixerTimes(nodeRed.('minutes'), nodeRed.('mai_mixer_run_bool'));
% Printhead pressure
if ~any(strcmp(nodeRed.Properties.VariableNames, 'printhead_pressure_bar'))
  nodeRed.('printhead_pressure_bar') = (nodeRed.('printhead_box1_io_ai0_ma') - 4) / 16 * 10;
end
% Temperature pumping chamber MAI MULTIMIX
nodeRed.('mai_temperature_pumping_chamber_c') = (nodeRed.('material_io_ai2_ma') - 4) / 16 * 100;

%% Plot pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_io_ai0_pressure_bar'), '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('material_io_ai1_pressure_bar'), '.b', 'MarkerSize', 2)
% Limits
ylim([0 25])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
ax1=gca;
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
plot(nodeRed.('minutes'), nodeRed.('material_differential_pressure_bar'), '.k', 'MarkerSize', 2)
yyaxis right
plot(nodeRed.('minutes'), nodeRed.('printhead_pressure_bar'), '.b', 'MarkerSize', 2)
% Limits
yyaxis left
ylim([0 1.4])
yyaxis right
ylim([0 1.4])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
yyaxis left
ylabel('Differential pressure [bar]')
yyaxis right
ylabel('Differential pressure [bar]')
% Legend
legend('Differential pressure coriolis', 'Differential pressure printhead', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_dynamic_viscocity_cp'), '.k', 'MarkerSize', 2)
% Limits
ylim([0 6000])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Apparent dynamic viscocity [cP]')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_exciter_current_1_ma'), '.k', 'MarkerSize', 2)
% Limits
ylim([0 10])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Exciter current 1 [mA]')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_mass_flow_kg_min'), '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_mass_flow_filtered_90s_kg_min'), '.b', 'MarkerSize', 2)
% Limits
ylim([0 12])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Mass flow rate [kg/min]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
corrieT=plot(nodeRed.('minutes'), nodeRed.material_coriolis_temperature_c, '-k', 'LineWidth',1.5);
mixT=plot(nodeRed.('minutes'), nodeRed.mai_temperature_pumping_chamber_c, '-b', 'LineWidth',1.5);
% Limits
ylim([26 36])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Mortar temperature [C]')
% Legend
legend([corrieT,mixT],["Coriolis sensor: " + round(mean(nodeRed.material_coriolis_temperature_c,'omitnan')*100)/100 + " $\pm$ " + round(std(nodeRed.material_coriolis_temperature_c,'omitnan')*100)/100, "Pumping chamber: " + round(mean(nodeRed.mai_temperature_pumping_chamber_c,'omitnan')*100)/100 + " $\pm$ " + round(std(nodeRed.mai_temperature_pumping_chamber_c,'omitnan')*100)/100], 'Location', 'NorthEast','FontSize',12,'Interpreter','latex')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_density_kg_m3'), '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_density_filtered_90s_kg_m3'), '.b', 'MarkerSize', 2)
% Limits
ylim([2320 2400])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Density [kg/m^{3}]')
% Legend
legend('Unfiltered', 'Filter E+H 90s', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('mai_pump_speed_chz')./100, '.k', 'MarkerSize', 2)
% Limits
ylim([0 50])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Pump frequency [Hz]')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('mai_pump_output_power_w'), '.k', 'MarkerSize', 2)
% Limits
ylim([0 800])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Pump output power [W]')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.minutes, nodeRed.mai_water_temp_c, '-k', 'LineWidth', 1.5);
% Limits
ylim([0.8*min(nodeRed.mai_water_temp_c),1.2*max(nodeRed.mai_water_temp_c)])
xlim([0 max(nodeRed.minutes)])
% Labels
xlabel('Time [Minutes]')
ylabel('Temperature [C]')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('mai_water_flow_actual_lh'), '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('mai_water_flow_set_lh'), '.b', 'MarkerSize', 2)
% Limits
ylim([160 220])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Water flow [L/h]')
% Legend
legend('Actual', 'Setpoint', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.('minutes'), nodeRed.('mai_waterpump_output_freq_chz')./100, '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('mai_waterpump_ref_freq_chz')./100, '.b', 'MarkerSize', 2)
% Limits
ylim([0 30])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Water pump freq. [Hz]')
% Legend
legend('Actual', 'Reference', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(nodeRed.minutes, nodeRed.material_io_ai7_ambient_temperature_c, '-k', 'LineWidth', 1.5)
yyaxis right
plot(nodeRed.minutes, nodeRed.material_io_ai6_relative_humidity_perc, '-b', 'LineWidth', 1.5)
% Limits
yyaxis left
ylim([0.8*min(nodeRed.material_io_ai7_ambient_temperature_c), 1.2*max(nodeRed.material_io_ai7_ambient_temperature_c)])
yyaxis right
ylim([0.8*min(nodeRed.material_io_ai6_relative_humidity_perc), 1.2*max(nodeRed.material_io_ai6_relative_humidity_perc)])
xlim([0 max(nodeRed.minutes)])
% Labels
xlabel('Time [Minutes]')
yyaxis left
ylabel('Ambient temperature [C]')
yyaxis right
ylabel('Relative humidity [%]')
% Legend
legend("Ambient temperature: " + round(mean(nodeRed.material_io_ai7_ambient_temperature_c,'omitnan')*100)/100+" $\pm$ " + round(std(nodeRed.material_io_ai7_ambient_temperature_c,'omitnan')*100)/100 + "C", "Relative humidity: " + round(mean(nodeRed.material_io_ai6_relative_humidity_perc,'omitnan')*100)/100+" $\pm$ " + round(std(nodeRed.material_io_ai6_relative_humidity_perc,'omitnan')*100)/100 + "\%", 'Location', 'NorthEast','FontSize',12,'Interpreter','latex')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(times, runTimes./intervalTimes, '.k', 'MarkerSize', 2, 'LineWidth', 1.5)
plot(times, movmean(runTimes./intervalTimes, [k 0]), '-k', 'MarkerSize', 2, 'LineWidth', 1.5)
% Limits
ylim([0 0.4])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Run time / interval time')
% Legend
legend('Single run', sprintf('Moving mean k=%d', k), 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
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
plot(times, intervalTimes*60, '.k', 'MarkerSize', 2)
plot(times, movmean(intervalTimes*60, [k 0]), '-k', 'MarkerSize', 2, 'LineWidth', 1.5)
plot(times, runTimes*60, '.b', 'MarkerSize', 2)
plot(times, movmean(runTimes*60, [k 0]), '-b', 'MarkerSize', 2, 'LineWidth', 1.5)
% Limits
ylim([0 120])
xlim([0 360])
% Labels
xlabel('Time [Minutes]')
ylabel('Mixer times [Seconds]')
% Legend
legend('Interval time', sprintf('Interval time mov. mean k=%d', k), 'Run time', sprintf('Run time mov. mean k=%d', k), 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:30:900))
% Write figure
saveFigure(fig, 'mixer_times')

%% Correlation between temperature and differential pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 11 8];
hold on
grid on
box on
% Window
windowStart = 60; % Minutes 
windowEnd = 270; % Minutes
[~, index1] = min(abs(nodeRed.('minutes')-windowStart));
[~, index2] = min(abs(nodeRed.('minutes')-windowEnd));
% Plot data
plot(nodeRed.('material_coriolis_temperature_c')(index1:index2), nodeRed.('material_differential_pressure_bar')(index1:index2), '.k', 'MarkerSize', 2)
% Limits
ylim([0 1.4])
xlim([30 36])
% Labels
xlabel('Mortar temperature [C]')
ylabel('Differential pressure [bar]')
% Write figure
saveFigure(fig, 'correlation_temp_dp')


%% End
disp('End of script')

%% Functions

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
    times = zeros(1, max_transitions);
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
                intervalTimes(intervalIndex) = timeFiltered(i) - startTime;
            end
        startTime = timeFiltered(i);
        % End of mixer run
        elseif (boolsFiltered(i-1) == 1 && boolsFiltered(i) == 0)
            runIndex = runIndex + 1;
            endTime = timeFiltered(i);
            runTimes(runIndex) = endTime - startTime;
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