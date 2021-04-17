<#**************************************************************************************************
Name: Test-GetUT_TemplateObject.ps1         Author: Brendan Furey                  Date: 05-Apr-2021

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
|  Install-TrapitUtils        |                   Install script copies module to Powershell path  |
|-----------------------------|--------------------------------------------------------------------|
|  Show-Examples              |                |                                                   |
|-----------------------------|  TrapitUtils   |  Trapit unit testing utility functions            |
| *Test-GetUT_TemplateObject* |----------------|---------------------------------------------------|
|                             |  Utils         |  General utility functions                        |
====================================================================================================

Unit test script following the Math Function Unit Testing design pattern. 

The script contains a function, purelyWrap-Unit, that takes a scenario input object containing a
list of records for each input group, formatted as delimited strings. The function makes calls to
the functions in the unit under test and returns an object containing a list of records for each
output group, formatted as delimited strings.

The function is 'externally pure' in the sense that it is deterministic, interacts externally via
paameters and return value, and any file output is reverted before exit.

The main section of the script is a call to a utility function, passing in the names of input and
output JSON files, and the function. The utility function reads the input file, calls the function
passed within a loop over the input scenarios, accumulating the output sacenarios containing both
expected and actual results, and finally writes the output JSON file.

A separate javascript program is used to read the output JSON file and produce formatted output in
text and HTML formats. This can be obtained from the GitHub project mentioned above, or from npm:

    $ npm install trapit

**************************************************************************************************#>
Import-Module TrapitUtils
$DELIM = ';'
<#**************************************************************************************************

getGroupFieldObjLis: Returns a list of objects from list of delimited group/field strings

**************************************************************************************************#>
function getGroupFieldObjLis($strLis) { # list of delimited group/field strings
    $objLis = @()
    foreach ($s in $strLis) {
        $fields = $s.Split($DELIM)
        $objLis += @{group = $fields[0]; field = $fields[1]}
    }
    $objLis
}
<#**************************************************************************************************

getGroupFieldStrLis: Returns a list of delimited group/field strings from an object with group name
                     for key, and lsit of fields names for value

**************************************************************************************************#>
function getGroupFieldStrLis($obj) { # object has a key and a value that is an array of strings
    $strLis = @()
    foreach ($o in $obj.PSObject.Properties) {
        foreach ($v in $o.value) {
            $strLis += $o.name + $DELIM + $v
        }
    }
    ,$strLis
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
function purelyWrap-Unit($inpGroups) { # input scenario groups

    $scalars = $inpGroups.'Scalars'
    if ($scalars.length -eq 0) { # either empty or contains a delimiter
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $inpGroups.'Input Group') (getGroupFieldObjLis $inpGroups.'Output Group')
    } else {
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $inpGroups.'Input Group') (getGroupFieldObjLis $inpGroups.'Output Group') $scalars[0]
    }
    #      Object key (group name)  Private function    Returned group object = key + list of strings
    [PSCustomObject]@{
          'Meta Input Group'      = getGroupFieldStrLis $utObj.meta.inp
          'Meta Output Group'     = getGroupFieldStrLis $utObj.meta.out
          'Scenario Input Group'  = getGroupFieldStrLis $utObj.scenarios.'scenario 1'.inp
          'Scenario Output Group' = getGroupFieldStrLis $utObj.scenarios.'scenario 1'.out
    }
}
# one line main section passing in input and output file names, and the local 'pure' function to unit test utility
Test-Unit '.\get_ut_template_object.json' '.\get_ut_template_object_out.json' ${function:purelyWrap-Unit}