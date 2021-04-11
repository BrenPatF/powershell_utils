<#**************************************************************************************************
Name: Install-Utils.ps1                     Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module Utils. The module has general utility functions
for pretty-printing etc.

    GitHub: https://github.com/BrenPatF/powershell_utils

There is an examples main script and a unit test script. The examples script makes calls to an
example class module that uses the pretty-printing functions, and calls other functions directly.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://github.com/BrenPatF/trapit_nodejs_tester#trapit

====================================================================================================
| Script (.ps1)    | Module (.psm1) |  Notes                                                       |
|==================================================================================================|
| *Install-Utils*  |                   Install script copies module to Powershell path             |
|------------------|-------------------------------------------------------------------------------|
|                  |  ColGroup      |  Simple file-reading and group-counting class module         |
|  Show-Examples   |----------------|--------------------------------------------------------------|
|                  |                |                                                              |
|------------------|  Utils         |  General utility functions                                   |
|                  |                |                                                              |
|  Test-Utils      |----------------|--------------------------------------------------------------|
|                  |  Trapit-Utils  |  Trapit unit testing utility functions                       |
====================================================================================================

Install script

**************************************************************************************************#>
$psPathFirst = $env:psmodulepath.split(';')[0]
$module = 'Utils'
"Installing $module in $psPathFirst"
$path = $psPathFirst + '\' + $module
if ( Test-Path $path) {
    "$path already exists"
} else {
    New-Item -ItemType Directory -Force -Path $path
}
Copy-Item ('..\' + $module + '.psm1') $path