<#**************************************************************************************************
Name: Install-TimerSet.ps1              Author: Brendan Furey                      Date: 27-Aug-2023

Component package in the Powershell Utilities module TimerSet. This module facilitates code timing
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

====================================================================================================
| Script (.ps1)      | Module (.psm1) |  Notes                                                     |
|==================================================================================================|
|                    |  ColGroup      |  Simple file-reading and group-counting class module       |
|  Show-ColGroup     |----------------|------------------------------------------------------------|
|--------------------|  TimerSet      |  TimerSet class module                                     |
|                    |----------------|------------------------------------------------------------|
|  Test-TimerSet     |  TrapitUtils   |  Trapit unit testing utility functions                     |                                                                                                                                                                                                                                                                                                                                                                                               
|                    |----------------|------------------------------------------------------------|                                                                                                                                                                                                                                                                               -------------------------------------------------------------|
|--------------------|  Utils         |  General utility functions                                 |
|                    |-----------------------------------------------------------------------------|
| *Install-TimerSet* |                   Install script copies module to Powershell path           |
====================================================================================================

This file contains the install script for the TimerSet module.

**************************************************************************************************#>
Import-Module ..\Utils\Utils.psm1
Install-Module $PSScriptRoot 'TimerSet'
Install-Module '..\Utils' 'Utils'
