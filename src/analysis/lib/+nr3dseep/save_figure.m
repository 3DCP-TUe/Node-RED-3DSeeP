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

function [] = save_figure(fig, name) 
% SAVE_FIGURE Save a figure as a PDF file
%
%   SAVE_FIGURE(fig, name) saves the specified figure to a PDF file with
%   the given filename. The figure's paper size is adjusted to match its
%   on-screen dimensions to preserve layout.
%
%   Input:
%       fig  - Handle to the figure to save
%       name - Name of the output PDF file (e.g., 'figure1.pdf')
%
%   Example:
%       fig = figure; plot(1:10, rand(1,10));
%       save_figure(fig, 'my_plot.pdf');

%------------- BEGIN CODE --------------

    width = fig.Position(3);
    height = fig.Position(4);
    set(gcf, 'PaperPosition', [0 0 width height]);
    set(gcf, 'PaperSize', [width height]); 
    saveas(fig, name, 'pdf')
end