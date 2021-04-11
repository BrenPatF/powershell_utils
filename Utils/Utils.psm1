<#**************************************************************************************************
Name: Utils.psm1                        Author: Brendan Furey                      Date: 05-Apr-2021

Component package in the Powershell Utilities module Utils. The module has general utility functions
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
|  Show-Examples   |----------------|--------------------------------------------------------------|
|                  |                |                                                              |
|------------------| *Utils*        |  General utility functions                                   |
|                  |                |                                                              |
|  Test-Utils      |----------------|--------------------------------------------------------------|
|                  |  Trapit-Utils  |  Trapit unit testing utility functions                       |
====================================================================================================

Utils package with functions called by Show-Examples and Test-Utils scripts

**************************************************************************************************#>

<#**************************************************************************************************

Write-Debug: Write message to the debug log file; pass $true on first call

**************************************************************************************************#>
function Write-Debug($msg,                        # message to write
                     $new = $false,               # overwrite if $true
                     $filename = '.\debug.log') { # debug log file

    if ($new) {
        'Debug starting, ' + (date) + ': ' + $msg > $filename
    } else {
        $msg >> $filename
    }
}
<#**************************************************************************************************

Get-ObjLisFromCsv: Import a csv file with headers into an array of objects

**************************************************************************************************#>
function Get-ObjLisFromCsv($csv,               # csv file
                           $delimiter = ',') { # delimiter

    $objLis = @()
    Import-CSV $csv -Delimiter $delimiter | %{ $objLis += $_ }
    $objLis
}
<#**************************************************************************************************

Get-Heading: Return a 2-element list of strings as a heading with double underlining

**************************************************************************************************#>
function Get-Heading($title, 
                     $indent) { # indent level

    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    "`n" + $sp + $title + "`n" + $sp + "="*("$title".length) + "`n"
}
<#**************************************************************************************************

Get-ColHeaders: Return a set of column headers, input as lists of values and length/justifications

**************************************************************************************************#>
function Get-ColHeaders($header2Lis, # lists of values and length/justifications
                        $indent) {   # indent level

    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    $header2Lis | %{ 
        $l1 = $l1 + "{0,$($_[1])}  " -f $_[0]
        $l2 = $l2 + '-'*[math]::Abs($($_[1])) + "  " 
    }
    ($sp + ("$l1" -replace ".{2}$") + "`n" + $sp + "$l2".trim() + "`n")
}
<#**************************************************************************************************

Get-2LisAsLine: Return a list of strings as one line, input as list of (string, length) tuples,
                and indent spaces
**************************************************************************************************#>
function Get-2LisAsLine($line2Lis, # list of (string, length) tuples
                        $indent) { # indent level

    if ($indent -gt 0) {
        $sp = " "*$indent
    }
    $l1 = ''
    $line2Lis | %{
        $l1 += "{0,$($_[1])}  " -f $_[0]
    }
    ($sp + ("$l1" -replace ".{2}$") + "`n")
}
<#**************************************************************************************************

Get-StrLisFromObjLis: Return a list of name, value strings from a list of objects, with simple 
                      string properties, usinmg a delimiter. Property names from first object first
**************************************************************************************************#>
function Get-StrLisFromObjLis($objLis,            # list of pscustomobjects
                              $delimiter = '|') { # delimiter
    $strLis = @()
    $first = $true
    foreach ($obj in $objLis) {
        $valStr = ''
        foreach ($o in $obj.PSObject.Properties) {
            if ($first) {
                $hdrStr += $o.name + $delimiter
            }
            $valStr += $o.value + $delimiter
        }
        if ($first) {
            $strLis += $hdrStr -replace ".{1}$"
            $first = $false
        }
        $strLis += $valStr -replace ".{1}$"
    }
    ,$strLis
}
