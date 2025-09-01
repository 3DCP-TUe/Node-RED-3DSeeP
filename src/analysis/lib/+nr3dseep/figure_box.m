% SPDX-License-Identifier: GPL-3.0-or-later
% Node-RED-3DSeeP
% Project: https://github.com/3DCP-TUe/Node-RED-3DSeeP
%
% Copyright (c) 2024-2025 Eindhoven University of Technology
%
% Authors:
%   - Arjen Deetman (2024-2025)
%
% For license details, see the LICENSE file in the project root.

function fig = figure_box()
%FIGURE_BOX Creates a figure with predefined layout and styling
%
% This function generates a MATLAB figure with consistent formatting for 
% plotting. The figure is initialized with grid lines, boxed axes, large 
% font size, and black axis colors. Paper and figure size are set to 
% 4^(3/2) x 3^(3/2) inches for standardized export.
%
% Syntax: fig = figure_box() 
%
% Inputs:
%   (none)
%
% Outputs:
%   fig - MATLAB figure handle for the generated plot
%
% Notes:
%   - The figure dimensions are fixed for consistent appearance across plots.
%   - Units are set to inches to ensure correct sizing for publications.
 
%------------- BEGIN CODE --------------

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