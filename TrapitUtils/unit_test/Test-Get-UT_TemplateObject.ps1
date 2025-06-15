<#************************************************************************************************************
Name: Test-Get-UT_TemplateObject.ps1         Author: Brendan Furey                           Date: 11-Mar-2023

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
|  Test-ColGroup                      |  ColGroup      |  logging to file. Example of testing impure     |
|                                     |                |  units, and failing test                        |
|-------------------------------------|------------------------------------------------------------------|
|                                     |  Utils         | General utility functions (separate module)     |
| *Test-Get-UT_TemplateObject*        |------------------------------------------------------------------|
|  Format-JSON-Get-UT_TemplateObject  |                |  Trapit unit testing utility functions          |
|                                     |                |                                                 |
|-------------------------------------|  TrapitUtils   |-------------------------------------------------|
|  Install-TrapitUtils                |                |  Installer copies package to Powershell path    |
==========================================================================================================

************************************************************************************************************#>
Import-Module ..\TrapitUtils.psm1
$DELIM = ';'
<#**************************************************************************************************

getGroupObjLis: Returns a list of objects from list of delimited group/field strings

**************************************************************************************************#>
function getGroupObjLis([String[]]$strLis) { # list of delimited group/field/value strings
    [PSCustomObject[]]$objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += [PSCustomObject]@{'group' = $fields[0]; 'field' = $fields[1]; 'value1' = $fields[2]; 'value2' = $fields[3]}
    }
    $objLis
}
<#**************************************************************************************************

getSceObjLis: Returns a list of objects from list of delimited Category Set/Scenario/Active strings

**************************************************************************************************#>
function getSceObjLis([String[]]$strLis) { # list of delimited Category Set/Scenario/Active strings
    [PSCustomObject[]]$objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += [PSCustomObject]@{'Category Set' = $fields[0]; 'Scenario' = $fields[1]; 'Active' = $fields[2]}
    }
    $objLis
}
<#**************************************************************************************************

getGroupFieldStrLis: Returns a list of delimited group/field strings from an object with group name
                     for key, and list of fields names for value

**************************************************************************************************#>
function getGroupFieldStrLis([PSCustomObject]$obj) { # object has a key and a value that is an array of strings
    [String[]]$strLis = @()
    foreach ($o in $obj.PSObject.Properties) {
        foreach ($v in $o.value) {
            $strLis += $o.name + $DELIM + $v
        }
    }
    $strLis
}
<#**************************************************************************************************

purelyWrap-Unit: Design pattern has the unit under test calls wrapped in a 'pure' function, called
                 once per scenario, with the output 'actuals' arrays including everything affected
                 by the uut, whether as output parameters, or files, etc. The inputs are also 
                 extended from the uut parameters to include any other effective inputs.

                 In this case, the wrapper function makes a call to the uut, passing in input and
                 output lists of objects constructed from the input lists of delimited strings, and
                 possibly delimiter. A local function turns nested object lists within the returned
                 object into lists of delimited strings.

                 These lists of delimited strings are assigned as values to an object with key as 
                 group name in each case, as the return value

**************************************************************************************************#>
function purelyWrap-Unit([PSCustomObject]$inpGroups) { # input scenario groups

    $scalars = $inpGroups.'Scalars'
    $delimiter, $title = $scalars.split($DELIM)
    $utObj = Get-UT_TemplateObject (getGroupObjLis $inpGroups.'Input Group') `
                                   (getGroupObjLis $inpGroups.'Output Group') `
                                   $delimiter `
                                   $title `
                                   (getSceObjLis $inpGroups.'Scenarios')
    [String[]]$inpLis = @()
    [String[]]$outLis = @()
    [String[]]$sceLis = @()
    foreach ($p in $utObj.scenarios.PsObject.Properties) {
        $inpLis += getGroupFieldStrLis $p.value.inp | %{$p.name + $DELIM + $_}
        $outLis += getGroupFieldStrLis $p.value.out | %{$p.name + $DELIM + $_}
        $sceLis += $p.value.category_set + $DELIM + $p.name + $DELIM + $p.value.active_yn
    }
    [String[]]$metaInpLis = @()                        # direct assignment can lead to null object
    $metaInpLis += getGroupFieldStrLis $utObj.meta.inp # iso empty array

    [String[]]$metaOutLis = @()
    $metaOutLis += getGroupFieldStrLis $utObj.meta.out
    #     Object key (group name)   group object value = list of strings
    [PSCustomObject]@{
          'Scalars'               = [String[]]$utObj.meta.title
          'Meta Input Group'      = $metaInpLis
          'Meta Output Group'     = $metaOutLis
          'Scenarios'             = $sceLis
          'Scenario Input Group'  = $inpLis
          'Scenario Output Group' = $outLis
    }
}
# one line main section passing in current root folder, npm parent folder, input JSON file name stem, and the local 'pure' function to unit test utility

Test-Format $PSScriptRoot ($PSScriptRoot + '/../../TrapitUtils') 'get_ut_template_object' ${function:purelyWrap-Unit}