<#**************************************************************************************************
Name: ColGroup.psm1                     Author: Brendan Furey                      Date: 27-Aug-2023

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
|                    | *ColGroup*     |  Simple file-reading and group-counting class module       |
|  Show-ColGroup     |----------------|------------------------------------------------------------|
|--------------------|  TimerSet      |  TimerSet class module                                     |
|                    |----------------|------------------------------------------------------------|
|  Test-TimerSet     |  TrapitUtils   |  Trapit unit testing utility functions                     |                                                                                                                                                                                                                                                                                                                                                                                               
|                    |----------------|------------------------------------------------------------|                                                                                                                                                                                                                                                                               -------------------------------------------------------------|
|--------------------|  Utils         |  General utility functions                                 |
|                    |-----------------------------------------------------------------------------|
|  Install-TimerSet  |                   Install script copies module to Powershell path           |
====================================================================================================

This file has the ColGroup package which contains a class used as an example in the Show-ColGroup
script.

**************************************************************************************************#>
Import-Module Utils
<#**************************************************************************************************

readList: Private function returns the key-value map of (string, count)

**************************************************************************************************#>
function readList($file,  # csv file
                  $delim, # delimiter
                  $col) { # column header
    $objLis = Get-ObjLisFromCsv $file $delim
    $counter = @{}
    foreach ($o in $objLis) {
        $key = $o.$col
        $val = If ($counter.$key -eq $null) { 1 } Else { $counter.$key + 1 }
        $counter.$key = $val
    }
    $counter
}
Class ColGroup {

    [hashtable]$counter
    [int]$maxLen
    <#**************************************************************************************************
    ColGroup: Constructor sets the key-value map of (string, count), and the maximum key length 
    **************************************************************************************************#>
    ColGroup($file,  # csv file
             $delim, # delimiter
             $col) { # column header
        $this.counter = readList $file $delim $col
        $this.maxLen = ($this.counter.keys | measure-object -property length -maximum).maximum
    }
    <#**************************************************************************************************

    WriteList: Prints the key-value list of (string, count) sorted as specified

    **************************************************************************************************#>
    [String[]]WriteList($sortBy,                # sort by descriptor
                        [Object[]]$keyValues) { # list of key/value objects

        $strLis = Get-Heading ('Counts sorted by ' + $sortBy)
        $strLis += ((Get-ColHeaders @(@('Team', -$this.maxLen), @('#apps', 5))) + "`n")
        foreach ($kv in $keyValues) {

            $strLis += ((Get-2LisAsLine @(@($kv.name, -$this.maxLen), @($kv.value, 5))) + "`n")

        }
        return $strLis
    }
    <#**************************************************************************************************

    ListAsIs: Returns the key-value list of (string, count) unsorted

    **************************************************************************************************#>
    [Object[]]ListAsIs() {

        return $this.counter.getenumerator() | %{$_}
    }
    <#**************************************************************************************************

    SortByKey, SortByValue: Returns the key-value list of (string, count) sorted by key or value

    **************************************************************************************************#>
    [Object[]]SortByKey() {
        return $this.counter.getenumerator() | sort-object -property name
    }
    [Object[]]SortByValue() {
        return $this.counter.getenumerator() | sort-object -property value, name
    }
}