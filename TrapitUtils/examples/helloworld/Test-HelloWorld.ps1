﻿<#**************************************************************************************************
Name: Test-HelloWorld.ps1                   Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module TrapitUtils. The project has utility functions
for unit testing following the Math Function Unit Testing design pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.
The output JSON file is processed by a JavaScript program that formats the results in HTML and text.

The core utility module, TrapitUtils, has two main entry point functions to facilitate the design
pattern, which is described here:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

Write-UT_Template writes a template for the unit test scenarios JSON file based on three input csv
files holding the specific group/field structure for input and output groups, and a scenarios list.
It performs the 'impure' reading and writing parts of the process, and calls a pure function, 
Get-UT_TemplateObject, to do most of the logic. This was designed with the Functional Programming
idea in mind that pure functions are preferable to impure ones, and that we should try to organise
our code accordingly. In this way we can unit test the pure function more easily, while there is
little complexity in the impure one, and it may not need explicit unit testing.

Test-Format is a utility that is called as the driver function of any specific unit test script. It
reads the input JSON scenarios file, then loops over the scenarios making calls to a function
passed in as a parameter from the calling script. The passed function acts as a 'pure' wrapper
around calls to the unit under test. It is 'externally pure' in the sense that it is deterministic,
and interacts externally only via parameters and return value. Where the unit under test reads
inputs from file the wrapper writes them based on its parameters, and where the unit under test
writes outputs to file the wrapper reads them and passes them out in its return value. Any file
writing is reverted before exit.

The utility function accumulates the output scenarios containing both expected and actual results,
writes them to an output JSON file and calls a Javascript program that reads this file and produces
output in text and HTML formats in a subfolder, returning a summary. Test-Format is called as part
of any unit test driver script, including the one that tests Get-UT_TemplateObject, and is
considered to be thereby tested implicitly.

The table shows the driver scripts for the relevant modules: There are two examples of use, with
main and test drivers; a test driver for the Get-UT_TemplateObject function; and an install script.

====================================================================================================
|  Script (.ps1)               | Module (.psm1)| Notes                                             |
|==================================================================================================|
|  Show-HelloWorld             |               | Simple Hello World program done as pure function  |
| *Test-HelloWorld*            |  HelloWorld   | to allow for unit testing as a simple edge case   |
|------------------------------|---------------|---------------------------------------------------|
|  Show-ColGroup               |               | File-reading / group-counting module, logging to  |
|  Test-ColGroup               |  ColGroup     | file. Shows testing of impure units with errors   |
|------------------------------|---------------|---------------------------------------------------|
|                              |  Utils        | General utility functions                         |
|  Test-Get-UT_TemplateObject  |---------------|---------------------------------------------------|
|                              |               | Trapit unit testing utility functions             |
|------------------------------|  TrapitUtils  |---------------------------------------------------|
|  Install-TrapitUtils         |               | Installer copies module to Powershell path        |
====================================================================================================

This file contains a unit test script for a simple Hello World program implemented as a pure
function to allow for unit testing as a simple edge case.

Unit test scripts contain a wrapper function that takes a scenario input object containing a list of
records for each input group, formatted as delimited strings. The function makes calls to the
unit under test and returns an object containing a list of records for each output group, formatted
as delimited strings. In this simple example the wrapper function is passed as a lambda expression.

The main section of the script is a call to a utility function, Test-Format, passing in the unit
test root folder, the parent folder of the JavaScript node_modules npm root folder, the input JSON
file name stem, and the wrapper function. The function creates a subfolder containing the formatted
unit test results files, and returns a summary of the results.

**************************************************************************************************#>
Using Module './HelloWorld.psm1'
Import-Module TrapitUtils
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../../TrapitUtils') 'helloworld' `
            { param($inpGroups) [PSCustomObject]@{'Group' = [String[]]@(Write-HelloWorld)} }
