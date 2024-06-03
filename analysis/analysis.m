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
nodeRed = readtable('20240507_Example.csv');

%% Get time in minutes and seconds
nodeRed.('Seconds') = seconds(nodeRed.('desktop_time')) - seconds(nodeRed.('desktop_time')(1));
nodeRed.('Minutes') = minutes(nodeRed.('desktop_time')) - minutes(nodeRed.('desktop_time')(1));

%% Plot pressure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 30 10];
hold on
grid on
box on
% Plot data
plot(nodeRed.('Minutes'), nodeRed.('material_io_ai0_pressure_bar'),  '.k', 'MarkerSize', 2)
plot(nodeRed.('Minutes'), nodeRed.('material_io_ai1_pressure_bar'),  '.b', 'MarkerSize', 2)
% Limits
ylim([0 25])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Pressure [bar]')
% Legend
legend('Pressure sensor 1', 'Pressure sensor 2', 'Location', 'NorthEast')
% Layout
set(gca,'XTick',(0:10:480))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mortar_pressure', 'pdf')

%% Plot viscocity
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 30 10];
hold on
grid on
box on
% Plot data
plot(nodeRed.('Minutes'), nodeRed.('material_coriolis_dynamic_viscocity_cp'),  '.k', 'MarkerSize', 2)
% Limits
ylim([0 6000])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Apparent dynamic viscocity [cP]')
% Layout
set(gca,'XTick',(0:10:480))
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
fig.Position = [1 14 30 10];
hold on
grid on
box on
% Plot data
plot(nodeRed.('Minutes'), nodeRed.('material_coriolis_exciter_current_1_ma'),  '.k', 'MarkerSize', 2)
% Limits
ylim([0 10])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Exciter current 1 [mA]')
% Layout
set(gca,'XTick',(0:10:480))
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
fig.Position = [1 14 30 10];
hold on
grid on
box on
% Plot data
plot(nodeRed.('Minutes'), nodeRed.('material_coriolis_temperature_c'),  '.k', 'MarkerSize', 2)
% Limits
ylim([28 36])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Mortar temperature [C]')
% Layout
set(gca,'XTick',(0:10:480))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'mortar_temperature', 'pdf')

%% Plot water temperature
fig = figure;
fig.Units = 'centimeters';
fig.Position = [1 14 30 10];
hold on
grid on
box on
% Plot data
plot(nodeRed.('Minutes'), nodeRed.('mai_water_temp_c'),  '.k', 'MarkerSize', 2)
% Limits
ylim([15 23])
xlim([0 240])
% Labels
xlabel('Time [Minutes]')
ylabel('Water temperature [C]')
% Layout
set(gca,'XTick',(0:10:480))
% Write figure
fig.Units = 'inches';
width = fig.Position(3);
height =  fig.Position(4);
set(gcf, 'PaperPosition', [0 0 width height]);
set(gcf, 'PaperSize', [width height]); 
saveas(fig, 'water_temperature', 'pdf')

%% End
disp('End of script')