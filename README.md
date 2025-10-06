# Node-RED 3DSeeP

<p align="left"> 
  <img src="https://img.shields.io/github/v/release/3DCP-TUe/Node-RED-3DSeeP?label=stable">
  <img src="https://img.shields.io/github/v/release/3DCP-TUe/Node-RED-3DSeeP?label=latest&include_prereleases">
  <img src="https://img.shields.io/github/license/3DCP-TUe/Node-RED-3DSeeP?">
  <a href="https://zenodo.org/doi/10.5281/zenodo.17278615"><img src="https://zenodo.org/badge/DOI/10.5281/zenodo.17278615.svg" alt="DOI"></a>
</p>

Node-RED 3DSeeP is a dashboard and data logging platform for the modular 3D concrete printing system in the [Structures Laboratory](https://www.tue.nl/en/research/research-labs/structures-laboratory) at [Eindhoven University of Technology](https://www.tue.nl/en/). It provides real-time monitoring, visualization, and logging of system parameters, allowing researchers to track, analyze, and optimize the printing process. The platform also enables manual control through a user interface and automates certain control logics, such as synchronizing multiple dosing systems. Node-RED 3DSeeP primarily relies on the OPC Unified Architecture (OPC UA) framework to communicate with and collect data from the various OPC UA servers distributed across the system.

## Installation

Install Node-RED:

- [Node-RED](https://nodered.org/) v3.1.9
- [Node.js](https://nodejs.org/en) v20.13.0

Install the following packages:

- [node-red-contrib-boolean-logic-ultimate](https://flows.nodered.org/node/node-red-contrib-boolean-logic-ultimate) v1.1.9
- [node-red-contrib-fs](https://flows.nodered.org/node/node-red-contrib-fs) v1.4.1
- [node-red-contrib-moment](https://flows.nodered.org/node/node-red-contrib-moment) v5.0.0
- [node-red-contrib-opcua](https://flows.nodered.org/node/node-red-contrib-opcua) v0.2.328
- [node-red-contrib-throttle](https://flows.nodered.org/node/node-red-contrib-throttle) v0.1.7
- [node-red-contrib-dashboard](https://flows.nodered.org/node/node-red-dashboard) v3.6.5

You can start Node-RED by typing `node-red` in the command window and access it at:

- Flow management: http://localhost:1880/
- Dashboard view: http://localhost:1880/ui

Download **[flows.json](src/acquisition/flows.json)** from the **[src/acquisition/](src/acquisition/)** directory and import it via the Flow Manager in Node-RED to run the developed data logger and dashboard.

## Explanation of the files

### Data acquisition

Files related to data acquisition are located in the **[src/acquisition/](src/acquisition/)** directory and include the following files and folders:

- **[src/acquisition/flows.json](src/acquisition/flows.json)**: Contains the Node-RED flow configuration for the data logger and dashboard. Import this file into Node-RED to set up and used the developed flows. 
- **[src/acquisition/package.json](src/acquisition/package.json)**: Lists the Node-RED dependencies and versions required to run the developed flows. You can this file to install the required packages. 
- **[src/acquisition/function blocks](src/acquisition/function%20blocks)**: A collection of the larger Node-RED function blocks written in JavaScript. These are exported separately to improve readability, since reviewing them directly in the `flows.json` file is difficult.
 
### Data analysis

Files related to data analysis are located in the **[src/analysis/](src/analysis/)** directory and include the following files and folders:

- **[lib](src/analysis/lib):** Library with standard functions for analysis. 
- **[mai.m](src/analysis/mai.m):** This file primarily outputs time series data plots of the standard system layout for printing with the Weber 160-2 material and the MAI MULTIMIX combined with the sensing station.
- **[mtec.m](src/analysis/mtec.m):** This file primarily outputs time series data plots of the standard system layout for printing with the m-tec connect duomix 3dcp+ combined with the sensing station.

The analysis files provided in this folder should be considered as templates and are fully functional with the latest version of the CSV format. You can use these files for data analysis or to quickly gain insights into your data. Store these files together with your dataset and adjust them if needed. If you add new functionality or create new templates please push these updates to this repository so that others can also benefit from them.

## Version numbering

Node-RED-3DSeeP uses the following versioning scheme: 

```
0.x.x ---> MAJOR version: incompatible changes; for example, columns of the CSV file are removed or renamed. 
x.0.x ---> MINOR version: functionality added in a backward compatible manner; for example, columns are added to the CSV file. 
x.x.0 ---> PATCH version: small backward compatible changes; for example, the layout or controls on the dashboard were changed. 
```

Changes that change the data logger's CSV file result in at least a new minor release. 

## Credits

Authors: 
- [Arjen Deetman](https://research.tue.nl/en/persons/arjen-deetman)
- [Derk Bos](https://research.tue.nl/en/persons/derk-h-bos)

Contributors:
- Benedek Papp (as part of an internship project at Siemens Digital Industries)
- Martijn van der Horst (as part of an internship project at Siemens Digital Industries)

Technical support:
- Siemens Digital Industries

## Funding

This software could be developed and maintained with the financial support of the following projects:
- The project _"Parametric mortar design and control of system parameters"_ funded by [Saint-Gobain Weber Beamix](https://www.nl.weber/).
- The project _"Additive manufacturing of functional construction materials on-demand"_ (with project number 17895) of the research program _"Materialen NL: Challenges 2018"_ which is financed by the [Dutch Research Council](https://www.nwo.nl/en) (NWO).

## Contact information

If you have any questions or comments about this project, please open an issue on the repository’s issue page. This can include questions about the content, such as missing information, and the data structure. We encourage you to open an issue instead of sending us emails to help establish an open community. By keeping discussions open, everyone can contribute and see the feedback and questions of others. In addition to this, please see our open science statement below.

## Open science statement

We are committed to the principles of open science to ensure that our work can be reproduced and built upon by others, by sharing detailed methodologies, data, and results generated with the unique equipment that is available in our lab. To spread Open Science, we encourage others to do the same to create an (even more) open and collaborative scientific community. 
Since it took a lot of time and effort to make our data and software available, we license our software under the General Public License version 3 or later (free to use, with attribution, share with source code) and our data and documentation under CC BY-SA (free to use, with attribution, share-alike), which requires you to apply the same licenses if you use our resources and share its derivatives with others.

## License

Copyright (c) 2020-2025 [3D Concrete Printing Research Group at Eindhoven University of Technology](https://www.tue.nl/en/research/research-groups/structural-engineering-and-design/3d-concrete-printing)

Node-RED-3DSeeP is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3.0 as published by the Free Software Foundation. 

Node-RED-3DSeeP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Node-RED-3DSeeP; If not, see <http://www.gnu.org/licenses/>.

@license GPL-3.0 <https://www.gnu.org/licenses/gpl-3.0.html>
