<#**************************************************************************************************
Name: Format-JSON-Utils.ps1                 Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module Utils. The module has general utility functions
for pretty-printing etc.

    GitHub: https://github.com/BrenPatF/powershell_utils

There is an examples main script and a unit test script. The examples script makes calls to an
example class module that uses the pretty-printing functions, and calls other functions directly.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

This file contains a wrapper script that calls the TrapitUtils function Write-UT_Template to 
generate a template for the unit testing input JSON file, based on CSV files with stem 'ps_utils'.

**************************************************************************************************#>
Import-Module ..\..\TrapitUtils\TrapitUtils.psm1
Write-UT_Template 'ps_utils' '|'
