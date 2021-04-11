<#**************************************************************************************************
Name: Install-TrapitUtils.ps1               Author: Brendan Furey                  Date: 05-Apr-2021

Component package in the Powershell Utilities module Trapit Utils. The module has utility functions
for unit testing following the Math Function Unit Testing design pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.

This utility module has two main entry point functions to facilitate the design pattern.

Write-UT_Template writes a template for the unit test scenarios JSON file based on two simple input
csv files holding the specific group/field structure for input and output groups. It performs the
'impure' reading and writing parts of the process, and calls a pure function, Get-UT_TemplateObject,
to do most of the logic. This was designed with the Functional Programming idea in mind that pure
functions are preferable to impure ones, and that we should try to organise our code accordingly. In
this way we can unit test the pure function more easily, while there is little complexity in the 
impure one, and it may not need explicit unit testing.

Test-Unit is a utility that is called as effectively the main function of any specific unit test
script. It reads the input JSON scenarios file, then loops over the scenarios making calls to a 
function passed in as a parameter from the calling script. The function acts as a 'pure' wrapper
around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic,
and interacts externally only via parameters and return value. Where the unit under test reads 
inputs from file the wrapper writes them based on its parameters, and where the unit under test 
writes outputs to file the wrapper reads them and passes them out in its return value. Any file
writing is reverted before exit. Test-Unit is called as part of any unit test driver script,
including the one that tests Get-UT_TemplateObject, and is considered to be thereby tested
implicitly.

There is a unit test script for the pure function  Get-UT_TemplateObject, and there is an example
script which uses the impure function that calls it, and creates the template JSON file for it.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://github.com/BrenPatF/trapit_nodejs_tester#trapit

====================================================================================================
| Script (.ps1)               | Module (.psm1) |  Notes                                            |
|==================================================================================================|
| *Install-TrapitUtils*       |                   Install script copies module to Powershell path  |
|-----------------------------|--------------------------------------------------------------------|
|  Show-Examples              |                |                                                   |
|-----------------------------|  Trapit-Utils  |  Trapit unit testing utility functions            |
|  Test-GetUT_TemplateObject  |----------------|---------------------------------------------------|
|                             |  Utils         |  General utility functions                        |
====================================================================================================

Install script

**************************************************************************************************#>
$psPathFirst = $env:psmodulepath.split(';')[0]
$module = 'Trapit-Utils'
"Installing $module in $psPathFirst"
$path = $psPathFirst + '\' + $module
if ( Test-Path $path) {
    "$path already exists"
} else {
    New-Item -ItemType Directory -Force -Path $path
}
Copy-Item ('..\' + $module + '.psm1') $path