<#**************************************************************************************************
Name: Test-GetUT_TemplateObject.ps1         Author: Brendan Furey                  Date: 05-Apr-2021

Component script in the Powershell Utilities module Trapit Utils. The module has utility functions
for unit testing following the Math Function Unit Testing design pattern.

    GitHub: https://github.com/BrenPatF/powershell_utils

The design pattern involves the use of JSON files for storing test scenario and metadata, with an
input file including expected results, and an output file that has the actual results merged in.

This utility module has four entry point functions, but only one of them is explicitly unit tested.
Two of the functions (Get-UT_TemplateObject and Test-Unit) are called as part of any unit test
driver script (including this one), and can be considered to be thereby tested implicitly.

The other two functions were designed with the Functional Programming idea in mind that pure
functions are preferable to impure ones, and that we should try to organise our code accordingly. To
that end the core logic for the remaining functionality was placed in a pure function, which is 
called from a wrapper function that reads an input file and writes to an output file. In this way we
can unit test the pure function more easily, while there is little complexity in the impure one, and
it may not need explicit unit testing.

The impure function reads input csv files containing the group structure for any particular unit to
be tested, and writes out a template JSON file in the correct format with a single scenario and 
placeholders for the test data, and the metadata.

There is a unit test script for the pure function, and there is an example script which uses that
pure function itself and creates the template JSON file for it.

The unit test script follows the Math Function Unit Testing design pattern, as described in:

    https://github.com/BrenPatF/trapit_nodejs_tester

====================================================================================================
| Main/Test (.ps1)            | Module (.psm1) |  Notes                                            |
|==================================================================================================|
|  Show-Examples              |                |                                                   |
|-----------------------------|  Trapit-Utils  |  Trapit unit testing utility functions            |
| *Test-GetUT_TemplateObject* |----------------|---------------------------------------------------|
|                             |  Utils         |  General utility functions                        |
====================================================================================================

Unit test script following the Math Function Unit Testing design pattern. 

The script has a function that takes an input scenario object, and returns an output scenario object
that has the actual results merged in with the expected results from the input object.

The main section of the script is a call to a utility function, passing in the names of input and
output JSON files, and the function. The utility function reads the input file, calls the function
passed within a loop over the input scenarios, accumulating the output sacenarios containing both
expected and actual results, and finally writes the output JSON file.

A separate javascript program is used to read the output JSON file and produce formatted output in
text and HTML formats. This can be obtained from the GitHub project mentioned above, or from npm:

$ npm install trapit

**************************************************************************************************#>
Import-Module Trapit-Utils
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
                 once per scenario, with the output 'actuals' array including everything affected by
                 the uut, whether as output parameters, or files, etc. The inputs are also extended 
                 from the uut parameters to include any other effective inputs.

                 In this case, the wrapper function makes a call to the uut, passing in input and
                 output lists of objects constructed from the input lists of delimited strings, and
                 possibly delimiter. A local function turns nested object lists within the returned
                 object into lists of delimited strings.

                 These lists of delimited strings are assigned as values to an object with key as 
                 group name in each case. This object is passed, with the input scenario, to a
                 utility function that returns a new scenario object that has the actual results 
                 merged in with the expected results from the input object

**************************************************************************************************#>
function purelyWrap-Unit($callScenario) { # input scenarion

    $scalars = $callScenario.inp.'Scalars'
    if ($scalars.length -eq 0) {
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $callScenario.inp.'Input Group') (getGroupFieldObjLis $callScenario.inp.'Output Group')
    } else {
        $utObj = Get-UT_TemplateObject (getGroupFieldObjLis $callScenario.inp.'Input Group') (getGroupFieldObjLis $callScenario.inp.'Output Group') $scalars[0]
    }
    #                Object key (group name)  Private function        Group value = list of input records
    $actObj = [PSCustomObject]@{
                    'Meta Input Group'      = getGroupFieldStrLis     $utObj.meta.inp
                    'Meta Output Group'     = getGroupFieldStrLis     $utObj.meta.out
                    'Scenario Input Group'  = getGroupFieldStrLis     $utObj.scenarios.'scenario 1'.inp
                    'Scenario Output Group' = getGroupFieldStrLis     $utObj.scenarios.'scenario 1'.out
              }
    # Utility takes input scenario plus the object with results by group and merges them to create the output object
    Get-UT_OutScenario $callScenario $actObj
}

# one line main section passing in input and output file names, and the local 'pure' function to unit test utility
Test-Unit '.\get_ut_template_object.json' '.\get_ut_template_object_out.json' ${function:purelyWrap-Unit}