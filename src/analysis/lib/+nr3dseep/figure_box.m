%{
This file is part of Node-RED-3DSeeP. Node-RED-3DSeeP is licensed under 
the terms of GNU General Public License as published by the Free Software 
Foundation. For more information and the LICENSE file, see 
<https://github.com/3DCP-TUe/Node-RED-3DSeeP>.
%}

%FIGURE_BOX Creates a figure with predefined layout and styling
%   fig = figure_box() returns a figure handle with:
%       - grid and box on
%       - font size 24
%       - black axes lines
%       - paper and figure size set to 4^(3/2) x 3^(3/2) inches
function fig = figure_box()
    fig = figure;
    hold on
    grid on
    box on
    set(gca, 'FontSize', 24);
    set(gca,'YColor',[0,0,0])
    set(gca,'XColor',[0,0,0])
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'Units', 'inches');
    fig_width = 4^(3/2);
    fig_height = 3^(3/2);
    set(gcf, 'PaperPosition', [0 0 fig_width fig_height]); 
    set(gcf, 'PaperSize', [fig_width fig_height]); 
    set(gcf, 'Position', [1 1 fig_width, fig_height]);
end