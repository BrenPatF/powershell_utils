<#**************************************************************************************************
Name: Show-Examples.ps1                     Author: Brendan Furey                  Date: 05-Apr-2021

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
|  Install-Utils   |                   Install script copies module to Powershell path             |
|------------------|-------------------------------------------------------------------------------|
|                  |  ColGroup      |  Simple file-reading and group-counting class module         |
| *Show-Examples*  |----------------|--------------------------------------------------------------|
|                  |                |                                                              |
|------------------|  Utils         |  General utility functions                                   |
|                  |                |                                                              |
|  Test-Utils      |----------------|--------------------------------------------------------------|
|                  |  Trapit-Utils  |  Trapit unit testing utility functions                       |
====================================================================================================

Main script for the examples of use. It demonstrates directly calls to:
    - Write-Debug
    - Get-Heading
    - Get-StrLisFromObjLis

The ColGroup class demonstrate calls to::
    - Get-ColHeaders
    - Get-2LisAsLine

**************************************************************************************************#>
Using Module './ColGroup.psm1'
Import-Module Utils
$INPUT_FILE, $DELIM, $COL = './fantasy_premier_league_player_stats.csv', ',', 'team_name'

# Demonstrate initial call to Write-Debug...
Write-Debug 'Debug' $true

$grp = [ColGroup]::New($INPUT_FILE, $DELIM, $COL)

$meas = $grp.ListAsIs() | measure-object -property value -sum

# Demonstrate subsequent call to Write-Debug...
Write-Debug ('Counted ' + $meas.count + ' teams, with ' + $meas.sum + ' appearances')

$grp.WriteList('(as is)', $grp.ListAsIs())
$grp.WriteList('key',     $grp.SortByKey())
$grp.WriteList('value',   $grp.SortByValue())

Get-Heading 'Demonstrate call to Get-StrLisFromObjLis...'

$exampleObj1 = [PSCustomObject]@{key11 = 'a'; key12 = 'b'} # keys from first object are included as first record
$exampleObj2 = [PSCustomObject]@{key21 = 'c'; key22 = 'd'} # keys from subsequent objects are not included

Get-StrLisFromObjLis @($exampleObj1, $exampleObj2)