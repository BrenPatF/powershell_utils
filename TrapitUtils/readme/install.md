## Installation

### Install Prerequisites

The powershell package Utils is required. This is a subproject of the same GitHub project as TrapitUtils, so if you have downloaded it, you will already have it, and just need to install it. To do this open a powershell window in the install folder below Utils, and execute as follows:
```
$ .\Install-Utils
```
This will create a folder Utils under the first folder in your `psmodulepath` environment variable, and copy Utils.psm1 to it.

The JavaScript npm package [Trapit - JavaScript Unit Tester/Formatter](https://github.com/BrenPatF/trapit_nodejs_tester) is required to format the unit test output JSON file in HTML and/or text. The package is installed as part of the TrapitUtils installation (next section) but you need to have [Node.js](https://nodejs.org/en/download) installed to run it.

### Install TrapitUtils

To install TrapitUtils open a powershell window in the install folder below TrapitUtils, and execute as follows:
```
$ .\Install-TrapitUtils
```
This will create a folder TrapitUtils under the first folder in your `psmodulepath` environment variable, and copy TrapitUtils.psm1 to it.
