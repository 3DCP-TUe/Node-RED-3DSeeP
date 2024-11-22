# Node-RED 3DSeeP

General dashboard and data logger for the 3D concrete printer in the [Structures Laboratory](https://www.tue.nl/en/research/research-labs/structures-laboratory) at [Eindhoven University of Technology](https://www.tue.nl/en/). 

## Dependencies

Node-RED

- [Node-RED](https://nodered.org/) v3.1.9
- [Node.js](https://nodejs.org/en) v20.13.0

Nodes:

- [node-red-contrib-boolean-logic-ultimate](https://flows.nodered.org/node/node-red-contrib-boolean-logic-ultimate) v1.1.9
- [node-red-contrib-fs](https://flows.nodered.org/node/node-red-contrib-fs) v1.4.1
- [node-red-contrib-moment](https://flows.nodered.org/node/node-red-contrib-moment) v5.0.0
- [node-red-contrib-opcua](https://flows.nodered.org/node/node-red-contrib-opcua) v0.2.328
- [node-red-contrib-throttle](https://flows.nodered.org/node/node-red-contrib-throttle) v0.1.7
- [node-red-contrib-dashboard](https://flows.nodered.org/node/node-red-dashboard) v3.6.5

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
- Benedek Papp
- Martijn van der Horst
- Laurens Schaap

Technical support:
- Siemens Digital Industries

## Funding

This software could be developed and maintained with the financial support of the following projects:
- The project _"Parametric mortar design and control of system parameters"_ funded by [Saint-Gobain Weber Beamix](https://www.nl.weber/).
- The project _"Additive manufacturing of functional construction materials on-demand"_ (with project number 17895) of the research program _"Materialen NL: Challenges 2018"_ which is financed by the [Dutch Research Council](https://www.nwo.nl/en) (NWO).

## Contact information

If you have any questions or comments about this project, please open an issue on the repository’s issue page. This can include questions about the content, such as missing information, and the data structure. We encourage you to open an issue instead of sending us emails to help establish an open community. By keeping discussions open, everyone can contribute and see the feedback and questions of others. In addition to this, please see our open science statement below.

## Open science statement

We are committed to the principles of open science to ensure that our work can be reproduced and built upon by others. Our approach includes the following key points:

- Reproducibility: We strive to make our work reproducible by sharing detailed methodologies and data.
- Unique Resources and Data: We have equipment and facilities that are not available at other institutes. We generate data that other institutes cannot produce, and we share this data openly.
- Data and Software Sharing: We share our data and software and encourage others to do the same. If others use our data and software, they must also share their software and data under similar terms.

To support these principles, we license our software under the General Public License version 3 or later (free to use, with attribution, share with source code) and our data and documentation under CC BY-SA (free to use, with attribution, share-alike). By adhering to these principles, we aim to encourage an open and collaborative scientific community. We expect that if you use our resources, you will do the same. 

## License

Copyright (c) 2020-2024 [3D Concrete Printing Research Group at Eindhoven University of Technology](https://www.tue.nl/en/research/research-groups/structural-engineering-and-design/3d-concrete-printing)

Node-RED-3DSeeP is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License version 3.0 as published by the Free Software Foundation. 

Node-RED-3DSeeP is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Node-RED-3DSeeP; If not, see <http://www.gnu.org/licenses/>.

@license GPL-3.0 <https://www.gnu.org/licenses/gpl-3.0.html>
