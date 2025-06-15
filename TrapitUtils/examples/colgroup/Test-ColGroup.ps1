<#************************************************************************************************************
Name: Test-ColGroup.ps1                      Author: Brendan Furey                           Date: 05-Apr-2021

Component script in the 'Trapit - PowerShell Unit Testing Utilities' module, which facilitates unit testing in 
Oracle PL/SQL following 'The Math Function Unit Testing design pattern', as described here: 

    https://brenpatf.github.io/2023/06/05/the-math-function-unit-testing-design-pattern.html

GitHub project for PowerShell:

    https://github.com/BrenPatF/powershell_utils

At the heart of the design pattern there is a language-specific unit testing driver function. Thisnfunction
reads an input JSON scenarios file, then loops over the scenarios making calls to a function passed in as a 
parameter from the calling script. The passed function acts as a 'pure' wrapper around calls to the unit under
test. It is 'externally pure' in the sense that it is deterministic, and interacts externally only via
parameters and return value. Where the unit under test reads inputs from file the wrapper writes them based on
its parameters, and where the unit under test writes outputs to file the wrapper reads them and passes them
out in its return value. Any file writing is reverted before exit.

The driver function accumulates the output scenarios containing both expected and actual results in an object,
from which a JavaScript function writes the results in HTML and text formats.

In testing of non-JavaScript programs, the results object is written to a JSON file to be passed to the
JavaScript formatter. In Powershell, the entry-point API, Test-Format, calls Test-Unit to write the JSON file,
then calls the JavaScript formatter, format-external-file.js.

The core utility package, TrapitUtils, has three main entry point functions to facilitate the design pattern.

Write-UT_Template
-----------------
Writes a template for the unit test scenarios JSON file based on three input CSV files holding the specific
group/field structure for input and output groups, and a scenarios list. It performs the 'impure' reading and
writing parts of the process, and calls a pure function, Get-UT_TemplateObject, to do most of the logic. This
was designed with the Functional Programming idea in mind that pure functions are preferable to impure ones,
and that we should try to organise our code accordingly. In this way we can unit test the pure function more
easily, while there is little complexity in the impure one, and it may not need explicit unit testing.

Test-Format
-----------
Test-Format is the unit testing entry-point API mentioned above, and it calls Test-Unit to write the JSON
file, then calls the JavaScript formatter, format-external-file.js

Test-FormatDB
-------------
In Oracle PL/SQL, a PowerShell utility is used to automate the running of the PL/SQL function, 
Trapit_Run.Test_Output_Files to write the JSON files for a unit test group, then call the JavaScript
formatter, format-external-file.js.

The table shows the driver scripts for the relevant package: There are two examples of use, with main and test
drivers; a main script for Write-UT_Template and test script for the Get-UT_TemplateObject function; and an
install script.
==========================================================================================================
|  Script(.ps1)                       |  Package(.psm1)|  Notes                                          |
|========================================================================================================|
|  Show-HelloWorld                    |                |  Hello World program implemented as a pure      |
|  Test-HelloWorld                    |  HelloWorld    |  function to allow to allow for unit testing as |
|                                     |                |  case a simple edge                             |
|-------------------------------------|------------------------------------------------------------------|
|  Show-ColGroup                      |                |  File-reading and group-counting package, with  |
| *Test-ColGroup*                     |  ColGroup      |  logging to file. Example of testing impure     |
|                                     |                |  units, and failing test                        |
|-------------------------------------|------------------------------------------------------------------|
|                                     |  Utils         | General utility functions (separate module)     |
|  Test-Get-UT_TemplateObject         |------------------------------------------------------------------|
|  Format-JSON-Get-UT_TemplateObject  |                |  Trapit unit testing utility functions          |
|                                     |                |                                                 |
|-------------------------------------|  TrapitUtils   |-------------------------------------------------|
|  Install-TrapitUtils                |                |  Installer copies package to Powershell path    |
==========================================================================================================

************************************************************************************************************#>
Using Module './ColGroup.psm1'
Import-Module TrapitUtils

$INPUT_FILE,                       $LOG_FILE                             =
($PSScriptRoot + '/ut_group.csv'), ($PSScriptRoot + '/ut_group.csv.log')

$GRP_LOG, $GRP_SCA,  $GRP_LIN, $GRP_LAI,   $GRP_SBK,    $GRP_SBV,      $GRP_ERR        =
'Log',    'Scalars', 'Lines',  'listAsIs', 'sortByKey', 'sortByValue', 'Error Message'
$DELIM = '|'

function fromCSV($csv,  # string of delimited values
                 $col) { # 0-based column index
    $csv.Split($DELIM)[$col]
}
function setup($inpGroups) { # input scenario groups
    [String[]]$linesArr = @()
    $linesArr += $inpGroups.'Lines'
    $linesArr | Out-File -FilePath $INPUT_FILE -encoding utf8
    if ($inpGroups[$GRP_LOG].length -gt 0) {
        $inpGroups[$GRP_LOG].Join('`n') | Out-File -FilePath $LOG_FILE -encoding utf8
    }
    [ColGroup]::New($INPUT_FILE, (fromCSV $inpGroups.'Scalars'[0] 0), (fromCSV $inpGroups.'Scalars'[0] 1))
}
function teardown {
    Start-Sleep -Seconds 0.1 # to avoid locking issue
    Remove-Item $INPUT_FILE
    if (Test-Path -Path $LOG_FILE) {Remove-Item $LOG_FILE}
}
function purelyWrap-Unit($inpGroups) { # input scenario groups
    [string[]]$grpLog = @()
    [string[]]$grpLai = @()
    [string[]]$grpSbk = @()
    [string[]]$grpSbv = @()
    try {
        $colGroup  = setup $inpGroups
        $linesArr  = [string[]](Get-Content -path $LOG_FILE)
        $lastLine  = $linesArr[$linesArr.length - 1]
        $diffDate  = ((date) - [datetime]$lastLine.SubString(0,19)).TotalMilliseconds
        $grpLog = ($linesArr.length).ToString() + $DELIM + $diffDate.ToString() + $DELIM + ($lastLine -Replace "\\", "-")
        $len = $colGroup.ListAsIs().length
        $grpLai = $len.ToString()
        if ($len -ne 0) {
            $grpSbk = $colGroup.SortByKey() | %{$_.name + $DELIM + $_.value}
            $grpSbv = $colGroup.SortByValue() | %{$_.name + $DELIM + $_.value}
        }
        [PSCustomObject]@{
            $GRP_LOG = $grpLog
            $GRP_LAI = $grpLai
            $GRP_SBK = $grpSbk
            $GRP_SBV = $grpSbv
        }
    }
    finally {
        teardown
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../../TrapitUtils') 'colgroup' ${function:purelyWrap-Unit}
