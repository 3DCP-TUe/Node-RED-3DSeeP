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

%% Import data from node red
nodeRed = readtable('20240607_AlexIdil.csv');

%% Get time in minutes and seconds
nodeRed.('seconds') = seconds(nodeRed.('desktop_time')) - seconds(nodeRed.('desktop_time')(1));
nodeRed.('minutes') = minutes(nodeRed.('desktop_time')) - minutes(nodeRed.('desktop_time')(1));

%% Calculations
% Differential pressure
k = 60; % ~6 seconds, 10 samples per second
filterd1 = movmean(nodeRed.('material_io_ai0_pressure_bar'), k, 'omitnan');
filterd2 = movmean(nodeRed.('material_io_ai1_pressure_bar'), k, 'omitnan');
nodeRed.('material_differential_pressure_bar') = filterd1 - filterd2;
% Mixer timing
[times, intervalTimes, runTimes] = mixerTimes(nodeRed.('minutes'), nodeRed.('mai_mixer_run_bool'));
% Printhead pressure
if ~any(strcmp(nodeRed.Properties.VariableNames, 'printhead_pressure_bar'))
    nodeRed.('printhead_pressure_bar') = (nodeRed.('printhead_box1_io_ai0_ma') - 4) / 16 * 10;
end

%% Plot pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_io_ai0_pressure_bar'),  '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('material_io_ai1_pressure_bar'),  '.b', 'MarkerSize', 2)
% Limits
ylim([0 25])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'pressure', 'pdf')

%% Plot differential pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_differential_pressure_bar'),  '.k', 'MarkerSize', 2)
yyaxis right
plot(nodeRed.('minutes'), nodeRed.('printhead_pressure_bar'),  '.b', 'MarkerSize', 2)
% Limits
yyaxis left
ylim([0 1.2])
yyaxis right
ylim([0 1.2])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
yyaxis left
ylabel('Differential pressure [bar]')
yyaxis right
ylabel('Differential pressure [bar]')
% Legend
legend('Differential pressure coriolis', 'Differential pressure printhead', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'differential_pressure', 'pdf')

%% Plot viscocity
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_dynamic_viscocity_cp'),  '.k', 'MarkerSize', 2)
% Limits
ylim([0 6000])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Apparent dynamic viscocity [cP]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'viscocity', 'pdf')

%% Plot exciter current
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_exciter_current_1_ma'),  '.k', 'MarkerSize', 2)
% Limits
ylim([0 10])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Exciter current 1 [mA]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'exciter_current_1', 'pdf')

%% Plot temperature
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_temperature_c'),  '.k', 'MarkerSize', 2)
% Limits
ylim([28 36])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Mortar temperature [C]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mortar_temperature', 'pdf')

%% Plot density
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_coriolis_density_kg_m3'),  '.k', 'MarkerSize', 2)
% Limits
ylim([2320 2400])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Density [kg/m^{3}]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'density', 'pdf')

%% Plot pump frequency
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('mai_pump_speed_chz')./100,  '.k', 'MarkerSize', 2)
% Limits
ylim([0 50])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Pump frequency [Hz]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mortar_pump_frequency', 'pdf')

%% Plot pump output power
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('mai_pump_output_power_w'),  '.k', 'MarkerSize', 2)
% Limits
ylim([0 800])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Pump output power [W]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mortar_pump_output_power', 'pdf')

%% Plot water temperature
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('mai_water_temp_c'),  '.k', 'MarkerSize', 2)
% Limits
ylim([15 21])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Water temperature [C]')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'water_temperature', 'pdf')

%% Plot water flow
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('mai_water_flow_actual_lh'),  '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('mai_water_flow_set_lh'),  '.b', 'MarkerSize', 2)
% Limits
ylim([160 220])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Water flow [L/h]')
% Legend
legend('Actual', 'Setpoint', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'water_flow', 'pdf')

%% Plot water pump frequency
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('mai_waterpump_output_freq_chz')./100,  '.k', 'MarkerSize', 2)
plot(nodeRed.('minutes'), nodeRed.('mai_waterpump_ref_freq_chz')./100,  '.b', 'MarkerSize', 2)
% Limits
ylim([0 30])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Water pump freq. [Hz]')
% Legend
legend('Actual', 'Reference', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'water_pump_frequency', 'pdf')

%% Ambient temperature and relative humidity
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
plot(nodeRed.('minutes'), nodeRed.('material_io_ai7_ambient_temperature_c'),  '.k', 'MarkerSize', 2)
yyaxis right
plot(nodeRed.('minutes'), nodeRed.('material_io_ai6_relative_humidity_perc'),  '.b', 'MarkerSize', 2)
% Limits
yyaxis left
ylim([0 40])
yyaxis right
ylim([0 100])
xlim([0 180])
% Labels
xlabel('Time [Minutes]')
yyaxis left
ylabel('Ambient temperature [C]')
yyaxis right
ylabel('Relative humidity [%]')
% Legend
legend('Ambient temperature', 'Relative humidity', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
yyaxis left
set(gca, 'YColor','k')
yyaxis right
set(gca, 'YColor','k')
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'ambient_temperature', 'pdf')

%% Mixer times ratio (flow prediction)
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
k = 8;
plot(times, runTimes./intervalTimes,  '.k', 'MarkerSize', 2, 'LineWidth', 1.5)
plot(times, movmean(runTimes./intervalTimes, [k 0]),  '-k', 'MarkerSize', 2, 'LineWidth', 1.5)
% Limits
ylim([0 0.4])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Run time / interval time')
% Legend
legend('Single run', sprintf('Moving mean k=%d', k), 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mixer_times_ratio', 'pdf')

%% Mixer times (flow prediction)
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 24 8];
hold on
grid on
box on
% Plot data
k = 8;
plot(times, intervalTimes*60,  '.k', 'MarkerSize', 2)
plot(times, movmean(intervalTimes*60, [k 0]),  '-k', 'MarkerSize', 2, 'LineWidth', 1.5)
plot(times, runTimes*60,  '.b', 'MarkerSize', 2)
plot(times, movmean(runTimes*60, [k 0]),  '-b', 'MarkerSize', 2, 'LineWidth', 1.5)
% Limits
ylim([0 120])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Mixer times [Seconds]')
% Legend
legend('Interval time', sprintf('Interval time mov. mean k=%d', k), 'Run time', sprintf('Run time mov. mean k=%d', k), 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:15:1000))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mixer_times', 'pdf')

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