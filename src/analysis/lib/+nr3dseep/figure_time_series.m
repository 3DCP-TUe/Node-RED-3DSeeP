%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%FIGURE_TIME_SERIES Creates a time-series figure with custom x-axis ticks
%   fig = figure_time_series(xticks, xlimits)
%       - xticks: array of datetime values for x-axis ticks
%       - xlimits: two-element datetime array defining x-axis limits
function fig = figure_time_series(xticks, xlimits)
    
    % Initialize figure
    fig = figure;
    hold on
    grid on
    box on
    set(gca, 'FontSize', 24);
    set(gca,'YColor',[0,0,0])
    set(gca,'XColor',[0,0,0])
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'Units', 'inches');
    fig_width = 3^(3/2)/7*18;
    fig_height = 3^(3/2); 
    set(gcf, 'PaperPosition', [0 0 fig_width fig_height]); 
    set(gcf, 'PaperSize', [fig_width fig_height]); 
    set(gcf, 'Position', [1 1 fig_width, fig_height]);
    
    % Layout x-axis
    % Dummy plot is needed since correct ticks (with clock time)
    % cannot be added on an empty axis. 
    dum = plot([xlimits(1)-duration(1,0,0), ...
        xlimits(2)+duration(1,0,0)], [0, 0]);
    set(gca, 'XTick',  xticks, 'XTickLabel', ...
        datestr(xticks, 'HH:MM'))
    xlim(xlimits)
    xlabel('Time', 'interpreter', 'latex')
    delete(dum);
end