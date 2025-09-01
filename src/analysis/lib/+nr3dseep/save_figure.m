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

function [] = save_figure(fig, name) 
%SAVE_FIGURE Save a figure as a PDF file
%
% This function saves the specified figure to a PDF file. The paper size 
% of the figure is automatically adjusted to match its on-screen 
% dimensions, ensuring that the exported PDF preserves the layout. 
%
% Syntax: save_figure(fig, name) 
%
% Inputs:
%   fig  - MATLAB figure handle to be saved
%   name - string or character vector specifying the name of the output 
%          PDF file (e.g., 'figure1.pdf')
%
% Outputs:
%   (none)
%
% Notes:
%   - The file is always saved in PDF format regardless of the extension 
%     provided in `name`.
%   - The paper size is set in inches to match the figure’s on-screen size.
%
% Example:
%   fig = figure; plot(1:10, rand(1,10));
%   save_figure(fig, 'my_plot.pdf');

%------------- BEGIN CODE --------------

    width = fig.Position(3);
    height = fig.Position(4);
    set(gcf, 'PaperPosition', [0 0 width height]);
    set(gcf, 'PaperSize', [width height]); 
    saveas(fig, name, 'pdf')
end