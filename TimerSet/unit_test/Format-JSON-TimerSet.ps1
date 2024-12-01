<#**************************************************************************************************
Name: Format-JSON-TimerSet.ps1              Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module TimerSet. This module facilitates code timing
for instrumentation and other purposes, with very small footprint in both code and resource usage.

    GitHub: https://github.com/BrenPatF/powershell_utils

See 'Code Timing and Object Orientation and Zombies' for the original idea implemented in Oracle 
   PL/SQL, Perl and Java
   http://www.scribd.com/doc/43588788/Code-Timing-and-Object-Orientation-and-Zombies
   Brendan Furey, November 2010

There is an examples main script and a unit test script. The examples script makes calls to an
example class module, ColGroup.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

This file contains a wrapper script that calls the TrapitUtils function Write-UT_Template to 
generate a template for the unit testing input JSON file, based on CSV files with stem
'timerset_ps'.

**************************************************************************************************#>
Import-Module ..\..\TrapitUtils\TrapitUtils.psm1
Write-UT_Template 'timerset_ps' '|'
